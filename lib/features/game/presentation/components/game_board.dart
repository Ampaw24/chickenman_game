import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_constants.dart';
import 'tile_widget.dart';

class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({super.key});

  @override
  ConsumerState<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard>
    with SingleTickerProviderStateMixin {
  // Swipe tracking
  int? _dragStartRow;
  int? _dragStartCol;
  Offset? _dragStartPosition;
  bool _swipeCommitted = false;

  // Which tile is currently being touched (shows highlight while finger is down).
  int? _pressedRow;
  int? _pressedCol;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    if (!mounted) return; // guard: listener may fire after dispose
    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final grid = ref.watch(gameProvider.select((s) => s.grid));
    final showCombo = ref.watch(gameProvider.select((s) => s.showCombo));
    final comboCount = ref.watch(gameProvider.select((s) => s.comboCount));

    ref.listen<int>(
      gameProvider.select((s) => s.matchedPositions.length),
      (prev, next) {
        if (next >= 5 && (prev == null || prev < 5)) {
          _triggerShake();
        }
      },
    );

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (_, child) => Transform.translate(
        offset: Offset(_shakeAnimation.value, 0),
        child: child,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardSize = constraints.maxWidth;
          final boardPadding = boardSize * 0.01;
          final tileSize = (boardSize - boardPadding * 2) / GameConstants.gridCols;
          final gap = tileSize * 0.06;
          final actualTileSize = tileSize - gap;

          return Container(
            width: boardSize,
            height: boardSize,
            padding: EdgeInsets.all(boardPadding),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(boardSize * 0.051),
              border: Border.all(
                color: AppColors.surfaceColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Grid background — static, never needs to rebuild
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: GameConstants.gridCols,
                    mainAxisSpacing: gap,
                    crossAxisSpacing: gap,
                  ),
                  itemCount: GameConstants.gridRows * GameConstants.gridCols,
                  itemBuilder: (_, index) {
                    final row = index ~/ GameConstants.gridCols;
                    final col = index % GameConstants.gridCols;
                    final isEven = (row + col) % 2 == 0;
                    return Container(
                      decoration: BoxDecoration(
                        color: isEven
                            ? AppColors.surfaceColor.withValues(alpha: 0.3)
                            : AppColors.backgroundLight.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(actualTileSize * 0.18),
                      ),
                    );
                  },
                ),

                // Tiles — single GestureDetector handles all swipe gestures.
                GestureDetector(
                  onPanStart: (d) => _onPanStart(d, tileSize),
                  onPanUpdate: (d) => _onPanUpdate(d, tileSize),
                  onPanEnd: (_) => _onPanEnd(),
                  onPanCancel: _onPanEnd,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: GameConstants.gridCols,
                      mainAxisSpacing: gap,
                      crossAxisSpacing: gap,
                    ),
                    itemCount: GameConstants.gridRows * GameConstants.gridCols,
                    itemBuilder: (_, index) {
                      final row = index ~/ GameConstants.gridCols;
                      final col = index % GameConstants.gridCols;
                      final tile = grid[row][col];
                      final isPressed =
                          _pressedRow == row && _pressedCol == col;

                      return TileWidget(
                        key: ValueKey(tile.id),
                        tile: tile,
                        isSelected: isPressed,
                        size: actualTileSize,
                      );
                    },
                  ),
                ),

                // Combo overlay
                if (showCombo)
                  Center(child: _ComboOverlay(count: comboCount)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Gesture handlers ────────────────────────────────────────────────────────

  void _onPanStart(DragStartDetails details, double tileSize) {
    final pos = details.localPosition;
    final col = (pos.dx / tileSize).floor().clamp(0, GameConstants.gridCols - 1);
    final row = (pos.dy / tileSize).floor().clamp(0, GameConstants.gridRows - 1);
    setState(() {
      _dragStartRow = row;
      _dragStartCol = col;
      _dragStartPosition = pos;
      _swipeCommitted = false;
      _pressedRow = row;
      _pressedCol = col;
    });
  }

  /// Fires the swap as soon as the finger moves far enough in one direction.
  /// Using displacement (not velocity) makes the response feel immediate.
  void _onPanUpdate(DragUpdateDetails details, double tileSize) {
    if (_dragStartRow == null || _swipeCommitted) return;

    final delta = details.localPosition - _dragStartPosition!;
    // Require ~20 % of a tile before committing — avoids accidental triggers.
    final threshold = tileSize * 0.20;

    if (delta.dx.abs() < threshold && delta.dy.abs() < threshold) return;

    int targetRow = _dragStartRow!;
    int targetCol = _dragStartCol!;

    if (delta.dx.abs() > delta.dy.abs()) {
      targetCol = delta.dx > 0
          ? (_dragStartCol! + 1).clamp(0, GameConstants.gridCols - 1)
          : (_dragStartCol! - 1).clamp(0, GameConstants.gridCols - 1);
    } else {
      targetRow = delta.dy > 0
          ? (_dragStartRow! + 1).clamp(0, GameConstants.gridRows - 1)
          : (_dragStartRow! - 1).clamp(0, GameConstants.gridRows - 1);
    }

    if (targetRow == _dragStartRow && targetCol == _dragStartCol) return;

    _swipeCommitted = true;
    ref.read(gameProvider.notifier).swipeTile(
          _dragStartRow!,
          _dragStartCol!,
          targetRow,
          targetCol,
        );
  }

  void _onPanEnd() {
    setState(() {
      _dragStartRow = null;
      _dragStartCol = null;
      _dragStartPosition = null;
      _swipeCommitted = false;
      _pressedRow = null;
      _pressedCol = null;
    });
  }
}

// ─── Combo Overlay ─────────────────────────────────────────────────────────────

class _ComboOverlay extends StatelessWidget {
  final int count;

  const _ComboOverlay({required this.count});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return IgnorePointer(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.051,
          vertical: size.height * 0.013,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.comboGradient,
          borderRadius: BorderRadius.circular(size.width * 0.077),
          boxShadow: [
            BoxShadow(
              color: AppColors.tileComboGlow.withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Text(
          '🔥 COMBO ×$count',
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.056,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      )
          .animate()
          .scale(
            begin: const Offset(0.3, 0.3),
            end: const Offset(1.1, 1.1),
            duration: 200.ms,
            curve: Curves.elasticOut,
          )
          .then()
          .scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(1, 1),
            duration: 100.ms,
          )
          .fade(begin: 0, end: 1, duration: 150.ms),
    );
  }
}
