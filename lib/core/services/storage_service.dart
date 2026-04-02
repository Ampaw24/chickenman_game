import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _playerBox = 'player_box';
  static const String _voucherBox = 'voucher_box';

  // Player keys
  static const String _keyDailyPlays = 'daily_plays';
  static const String _keyLastPlayDate = 'last_play_date';
  static const String _keyTotalGames = 'total_games';
  static const String _keyBestScore = 'best_score';
  static const String _keyLoyaltyPoints = 'loyalty_points';
  static const String _keyTotalVouchers = 'total_vouchers';
  static const String _keyPlayerName = 'player_name';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_playerBox);
    await Hive.openBox<Map>(_voucherBox);
  }

  Box get _player => Hive.box(_playerBox);
  Box<Map> get _vouchers => Hive.box<Map>(_voucherBox);

  // --- Daily Plays ---

  int getRemainingPlays() {
    _resetPlaysIfNewDay();
    return _safeInt(_player.get(_keyDailyPlays), 3);
  }

  void consumePlay() {
    final remaining = getRemainingPlays();
    if (remaining > 0) {
      _player.put(_keyDailyPlays, remaining - 1);
    }
  }

  void addPlays(int count) {
    final current = getRemainingPlays();
    _player.put(_keyDailyPlays, current + count);
  }

  void _resetPlaysIfNewDay() {
    final lastDate = _player.get(_keyLastPlayDate, defaultValue: '') as String;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastDate != today) {
      _player.put(_keyDailyPlays, 3);
      _player.put(_keyLastPlayDate, today);
    }
  }

  // --- Stats ---

  int getTotalGames() => _safeInt(_player.get(_keyTotalGames), 0);
  int getBestScore() => _safeInt(_player.get(_keyBestScore), 0);
  int getLoyaltyPoints() => _safeInt(_player.get(_keyLoyaltyPoints), 0);
  int getTotalVouchers() => _safeInt(_player.get(_keyTotalVouchers), 0);
  String getPlayerName() {
    final v = _player.get(_keyPlayerName, defaultValue: 'Player');
    return v is String ? v : 'Player';
  }

  void setPlayerName(String name) => _player.put(_keyPlayerName, name);

  void recordGameResult(int score) {
    final games = getTotalGames();
    _player.put(_keyTotalGames, games + 1);
    if (score > getBestScore()) {
      _player.put(_keyBestScore, score);
    }
  }

  void addLoyaltyPoints(int points) {
    final current = getLoyaltyPoints();
    _player.put(_keyLoyaltyPoints, current + points);
  }

  void incrementVoucherCount() {
    final count = getTotalVouchers();
    _player.put(_keyTotalVouchers, count + 1);
  }

  // --- Vouchers ---

  void saveVoucher(Map<String, dynamic> voucher) {
    _vouchers.add(voucher);
    incrementVoucherCount();
  }

  List<Map<String, dynamic>> getVouchers() {
    return _vouchers.values
        .map((v) => Map<String, dynamic>.from(v))
        .toList()
      ..sort((a, b) => (b['createdAt'] as String).compareTo(a['createdAt'] as String));
  }

  int _safeInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  void redeemVoucher(String id) {
    for (int i = 0; i < _vouchers.length; i++) {
      final v = _vouchers.getAt(i);
      if (v != null && v['id'] == id) {
        final updated = Map<String, dynamic>.from(v);
        updated['status'] = 'redeemed';
        _vouchers.putAt(i, updated);
        return;
      }
    }
  }
}
