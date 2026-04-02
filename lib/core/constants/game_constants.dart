abstract class GameConstants {
  // Board
  static const int gridRows = 6;
  static const int gridCols = 6;
  static const int minMatch = 3;

  // Scoring
  static const int scoreMatch3 = 30;
  static const int scoreMatch4 = 60;
  static const int scoreMatch5 = 120;
  static const double comboMultiplier = 1.2;
  static const int comboWindowSeconds = 2;

  // Timer
  static const int gameDurationSeconds = 60;

  // Energy / plays
  static const int freeDailyPlays = 3;
  static const double paidPlayCostGhs = 2.0;
  static const double extraPlayCostGhs = 1.0;
  static const double freePurchaseThresholdGhs = 40.0;

  // Reward thresholds
  static const int rewardTier1Score = 0;    // < 400
  static const int rewardTier2Score = 400;  // 5% discount
  static const int rewardTier3Score = 800;  // Free drink
  static const int rewardTier4Score = 1500; // Free fries
  static const int rewardTier5Score = 2500; // Free burger

  // Voucher
  static const int voucherExpiryDays = 7;

  // Animation durations (ms)
  static const int tileSwapDurationMs = 200;
  static const int tileExplodeDurationMs = 300;
  static const int tileFallDurationMs = 250;
  static const int comboShowDurationMs = 800;
}
