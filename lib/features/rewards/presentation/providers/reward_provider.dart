import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/voucher_model.dart';
import '../../domain/reward_engine.dart';
import '../../../../core/services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// ─── Voucher List State ────────────────────────────────────────────────────────

class VoucherNotifier extends StateNotifier<List<VoucherModel>> {
  final StorageService _storage;

  VoucherNotifier(this._storage) : super([]) {
    _loadVouchers();
  }

  void _loadVouchers() {
    final maps = _storage.getVouchers();
    state = maps.map(VoucherModel.fromMap).toList();
  }

  void addVoucher(VoucherModel voucher) {
    _storage.saveVoucher(voucher.toMap());
    state = [voucher, ...state];
  }

  void redeemVoucher(String id) {
    _storage.redeemVoucher(id);
    state = state.map((v) {
      if (v.id == id) return v.copyWith(status: VoucherStatus.redeemed);
      return v;
    }).toList();
  }

  List<VoucherModel> get activeVouchers =>
      state.where((v) => v.isActive).toList();

  List<VoucherModel> get allVouchers => state;
}

final voucherProvider =
    StateNotifierProvider<VoucherNotifier, List<VoucherModel>>(
  (ref) => VoucherNotifier(ref.read(storageServiceProvider)),
);

// ─── Player Stats Provider ─────────────────────────────────────────────────────

class PlayerStatsState {
  final int remainingPlays;
  final int totalGames;
  final int bestScore;
  final int loyaltyPoints;
  final String playerName;

  const PlayerStatsState({
    required this.remainingPlays,
    required this.totalGames,
    required this.bestScore,
    required this.loyaltyPoints,
    required this.playerName,
  });
}

class PlayerStatsNotifier extends StateNotifier<PlayerStatsState> {
  final StorageService _storage;

  PlayerStatsNotifier(this._storage)
      : super(PlayerStatsState(
          remainingPlays: 0,
          totalGames: 0,
          bestScore: 0,
          loyaltyPoints: 0,
          playerName: 'Player',
        )) {
    _refresh();
  }

  void _refresh() {
    state = PlayerStatsState(
      remainingPlays: _storage.getRemainingPlays(),
      totalGames: _storage.getTotalGames(),
      bestScore: _storage.getBestScore(),
      loyaltyPoints: _storage.getLoyaltyPoints(),
      playerName: _storage.getPlayerName(),
    );
  }

  void recordGame(int score) {
    _storage.consumePlay();
    _storage.recordGameResult(score);
    _refresh();
  }

  void addLoyaltyPoints(int points) {
    _storage.addLoyaltyPoints(points);
    _refresh();
  }

  void updatePlayerName(String name) {
    _storage.setPlayerName(name);
    _refresh();
  }

  void addPlays(int count) {
    _storage.addPlays(count);
    _refresh();
  }
}

final playerStatsProvider =
    StateNotifierProvider<PlayerStatsNotifier, PlayerStatsState>(
  (ref) => PlayerStatsNotifier(ref.read(storageServiceProvider)),
);

// ─── Post-game reward processing ──────────────────────────────────────────────

final rewardResultProvider = StateProvider<RewardResult?>((ref) => null);
