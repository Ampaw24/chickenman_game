import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/tile_model.dart';
import '../../domain/use_cases/match_detector.dart';
import '../../domain/use_cases/score_calculator.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../core/services/audio_service.dart';

// ─── State ────────────────────────────────────────────────────────────────────

enum GameStatus { idle, playing, paused, processingMatch, gameOver }

class GameState {
  final List<List<TileModel>> grid;
  final int score;
  final int timeLeft;
  final GameStatus status;
  final Set<String> matchedPositions;
  final double comboMultiplier;
  final int comboCount;
  final DateTime? lastMatchTime;
  final bool showCombo;

  const GameState({
    required this.grid,
    this.score = 0,
    this.timeLeft = GameConstants.gameDurationSeconds,
    this.status = GameStatus.idle,
    this.matchedPositions = const {},
    this.comboMultiplier = 1.0,
    this.comboCount = 0,
    this.lastMatchTime,
    this.showCombo = false,
  });

  bool get isPlaying => status == GameStatus.playing;
  bool get isGameOver => status == GameStatus.gameOver;

  GameState copyWith({
    List<List<TileModel>>? grid,
    int? score,
    int? timeLeft,
    GameStatus? status,
    Set<String>? matchedPositions,
    double? comboMultiplier,
    int? comboCount,
    DateTime? lastMatchTime,
    bool? showCombo,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      status: status ?? this.status,
      matchedPositions: matchedPositions ?? this.matchedPositions,
      comboMultiplier: comboMultiplier ?? this.comboMultiplier,
      comboCount: comboCount ?? this.comboCount,
      lastMatchTime: lastMatchTime ?? this.lastMatchTime,
      showCombo: showCombo ?? this.showCombo,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class GameNotifier extends StateNotifier<GameState> {
  final _matchDetector = MatchDetector();
  final _scoreCalc = ScoreCalculator();
  final _uuid = const Uuid();
  final _rand = Random();

  Timer? _timer;
  Timer? _comboHideTimer;

  GameNotifier() : super(GameState(grid: _emptyGrid()));

  // ── Initialise ─────────────────────────────────────────────────────────────

  static List<List<TileModel>> _emptyGrid() =>
      List.generate(GameConstants.gridRows, (r) =>
        List.generate(GameConstants.gridCols, (c) => TileModel(
          row: r, col: c,
          type: FoodType.values[0],
          id: '',
        )));

  void startGame() {
    _timer?.cancel();
    final grid = _generateGrid();
    state = GameState(
      grid: grid,
      timeLeft: GameConstants.gameDurationSeconds,
      status: GameStatus.playing,
    );
    _startTimer();
    AudioService.instance.playGameStart();
  }

  List<List<TileModel>> _generateGrid() {
    List<List<TileModel>> grid;
    do {
      grid = List.generate(
        GameConstants.gridRows,
        (r) => List.generate(
          GameConstants.gridCols,
          (c) => TileModel(
            row: r,
            col: c,
            type: FoodType.values[_rand.nextInt(FoodType.values.length)],
            id: _uuid.v4(),
          ),
        ),
      );
      // Remove initial matches so board starts clean
      _clearInitialMatches(grid);
    } while (!_hasPossibleMove(grid));
    return grid;
  }

  void _clearInitialMatches(List<List<TileModel>> grid) {
    bool hadMatches;
    do {
      hadMatches = false;
      final nullableGrid = grid.map((r) => r.map<TileModel?>(
        (t) => t).toList()).toList();
      final matches = _matchDetector.findAllMatches(nullableGrid);
      if (matches.isNotEmpty) {
        hadMatches = true;
        for (final key in matches) {
          final parts = key.split(',');
          final r = int.parse(parts[0]);
          final c = int.parse(parts[1]);
          grid[r][c] = grid[r][c].copyWith(
            type: FoodType.values[_rand.nextInt(FoodType.values.length)],
            id: _uuid.v4(),
          );
        }
      }
    } while (hadMatches);
  }

  bool _hasPossibleMove(List<List<TileModel>> grid) {
    // Build the nullable wrapper once; refresh only the two touched cells.
    final nullableGrid = grid
        .map((row) => row.map<TileModel?>((t) => t).toList())
        .toList();

    for (int r = 0; r < GameConstants.gridRows; r++) {
      for (int c = 0; c < GameConstants.gridCols; c++) {
        if (c + 1 < GameConstants.gridCols) {
          _swap(grid, r, c, r, c + 1);
          nullableGrid[r][c] = grid[r][c];
          nullableGrid[r][c + 1] = grid[r][c + 1];
          final hasMatch = _matchDetector.findAllMatches(nullableGrid).isNotEmpty;
          _swap(grid, r, c, r, c + 1);
          nullableGrid[r][c] = grid[r][c];
          nullableGrid[r][c + 1] = grid[r][c + 1];
          if (hasMatch) return true;
        }
        if (r + 1 < GameConstants.gridRows) {
          _swap(grid, r, c, r + 1, c);
          nullableGrid[r][c] = grid[r][c];
          nullableGrid[r + 1][c] = grid[r + 1][c];
          final hasMatch = _matchDetector.findAllMatches(nullableGrid).isNotEmpty;
          _swap(grid, r, c, r + 1, c);
          nullableGrid[r][c] = grid[r][c];
          nullableGrid[r + 1][c] = grid[r + 1][c];
          if (hasMatch) return true;
        }
      }
    }
    return false;
  }

  void _swap(List<List<TileModel>> grid, int r1, int c1, int r2, int c2) {
    final temp = grid[r1][c1];
    grid[r1][c1] = grid[r2][c2].copyWith(row: r1, col: c1);
    grid[r2][c2] = temp.copyWith(row: r2, col: c2);
  }

  // ── Swipe Swap ─────────────────────────────────────────────────────────────

  Future<void> swipeTile(int r1, int c1, int r2, int c2) async {
    if (!state.isPlaying) return;
    if (state.status == GameStatus.processingMatch) return;
    if (!_matchDetector.isAdjacent(r1, c1, r2, c2)) return;
    await _attemptSwap(r1, c1, r2, c2);
  }

  Future<void> _attemptSwap(int r1, int c1, int r2, int c2) async {
    state = state.copyWith(
      status: GameStatus.processingMatch,
    );

    final newGrid = _copyGrid(state.grid);
    _swap(newGrid, r1, c1, r2, c2);

    final nullableGrid = newGrid.map((r) => r.map<TileModel?>(
      (t) => t).toList()).toList();
    final matches = _matchDetector.findAllMatches(nullableGrid);

    if (matches.isEmpty) {
      // Invalid swap — animate back
      AudioService.instance.playInvalid();
      await Future.delayed(
        const Duration(milliseconds: GameConstants.tileSwapDurationMs),
      );
      if (!mounted || state.isGameOver) return;
      state = state.copyWith(status: GameStatus.playing);
      return;
    }

    AudioService.instance.playSwap();
    state = state.copyWith(grid: newGrid);
    await _processMatches(newGrid, matches);
  }

  /// Processes one or more cascade rounds iteratively (no recursion) so the
  /// Dart call stack never deepens regardless of how many cascades occur.
  /// Guards at every await point prevent stale writes after game-over or dispose.
  Future<void> _processMatches(
    List<List<TileModel>> initialGrid,
    Set<String> initialMatches,
  ) async {
    var currentGrid = initialGrid;
    var currentMatches = initialMatches;

    while (currentMatches.isNotEmpty) {
      if (!mounted || state.isGameOver) return;

      // ── Highlight ──────────────────────────────────────────────────────────
      final highlighted = _markMatched(currentGrid, currentMatches);
      final nullableHighlighted = highlighted
          .map((r) => r.map<TileModel?>((t) => t).toList())
          .toList();
      final sizes = _matchDetector.getMatchSizes(nullableHighlighted, currentMatches);
      final points = _scoreCalc.calculateMatchScore(sizes, state.lastMatchTime);

      final now = DateTime.now();
      final isCombo = state.lastMatchTime != null &&
          now.difference(state.lastMatchTime!).inSeconds <=
              GameConstants.comboWindowSeconds;
      final newCombo = isCombo ? state.comboCount + 1 : 1;

      if (isCombo) {
        AudioService.instance.playCombo();
      } else {
        AudioService.instance.playMatch();
      }

      state = state.copyWith(
        grid: highlighted,
        matchedPositions: currentMatches,
        score: state.score + points,
        lastMatchTime: now,
        comboCount: newCombo,
        showCombo: isCombo,
      );

      await Future.delayed(
        const Duration(milliseconds: GameConstants.tileExplodeDurationMs),
      );
      if (!mounted || state.isGameOver) return;

      // ── Collapse + refill ─────────────────────────────────────────────────
      final collapsed = _collapseGrid(highlighted, currentMatches);
      final refilled = _refillGrid(collapsed);

      state = state.copyWith(
        grid: refilled,
        matchedPositions: {},
        showCombo: false,
      );

      await Future.delayed(
        const Duration(milliseconds: GameConstants.tileFallDurationMs),
      );
      if (!mounted || state.isGameOver) return;

      // ── Check for cascades ────────────────────────────────────────────────
      final nullableRefilled = refilled
          .map((r) => r.map<TileModel?>((t) => t).toList())
          .toList();
      currentMatches = _matchDetector.findAllMatches(nullableRefilled);
      currentGrid = refilled;
    }

    if (mounted && !state.isGameOver) {
      state = state.copyWith(status: GameStatus.playing);
    }
  }

  List<List<TileModel>> _markMatched(
    List<List<TileModel>> grid,
    Set<String> matches,
  ) {
    final newGrid = _copyGrid(grid);
    for (final key in matches) {
      final parts = key.split(',');
      final r = int.parse(parts[0]);
      final c = int.parse(parts[1]);
      newGrid[r][c] = newGrid[r][c].copyWith(state: TileState.matched);
    }
    return newGrid;
  }

  List<List<TileModel>> _collapseGrid(
    List<List<TileModel>> grid,
    Set<String> matches,
  ) {
    final newGrid = _copyGrid(grid);
    for (int c = 0; c < GameConstants.gridCols; c++) {
      // Remove matched tiles from column (keep non-matched, pack to bottom)
      final column = <TileModel>[];
      for (int r = 0; r < GameConstants.gridRows; r++) {
        final key = '$r,$c';
        if (!matches.contains(key)) {
          column.add(newGrid[r][c]);
        }
      }
      // Fill from bottom up
      int fillRow = GameConstants.gridRows - 1;
      for (int i = column.length - 1; i >= 0; i--) {
        newGrid[fillRow][c] = column[i].copyWith(
          row: fillRow,
          state: TileState.falling,
        );
        fillRow--;
      }
      // Mark empty slots (will be filled by refill)
      while (fillRow >= 0) {
        newGrid[fillRow][c] = TileModel(
          row: fillRow, col: c, type: FoodType.burger,
          state: TileState.new_, id: '',
        );
        fillRow--;
      }
    }
    return newGrid;
  }

  List<List<TileModel>> _refillGrid(List<List<TileModel>> grid) {
    final newGrid = _copyGrid(grid);
    for (int r = 0; r < GameConstants.gridRows; r++) {
      for (int c = 0; c < GameConstants.gridCols; c++) {
        if (newGrid[r][c].id.isEmpty) {
          newGrid[r][c] = TileModel(
            row: r,
            col: c,
            type: FoodType.values[_rand.nextInt(FoodType.values.length)],
            state: TileState.new_,
            id: _uuid.v4(),
          );
        }
      }
    }
    return newGrid;
  }

  List<List<TileModel>> _copyGrid(List<List<TileModel>> grid) {
    return grid.map((row) => List<TileModel>.from(row)).toList();
  }

  // ── Timer ──────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return; // already-queued tick after dispose
      final remaining = state.timeLeft - 1;
      if (remaining <= 0) {
        state = state.copyWith(timeLeft: 0, status: GameStatus.gameOver);
        _timer?.cancel();
        AudioService.instance.playGameOver();
      } else {
        state = state.copyWith(timeLeft: remaining);
      }
    });
  }

  void pauseGame() {
    if (!state.isPlaying) return;
    _timer?.cancel();
    state = state.copyWith(status: GameStatus.paused);
  }

  void resumeGame() {
    if (state.status != GameStatus.paused) return;
    state = state.copyWith(status: GameStatus.playing);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _comboHideTimer?.cancel();
    super.dispose();
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) => GameNotifier(),
);
