import '../../../../core/constants/game_constants.dart';

class ScoreCalculator {
  /// Calculates base score from a match of [matchSize] tiles.
  int baseScore(int matchSize) {
    if (matchSize >= 5) return GameConstants.scoreMatch5;
    if (matchSize == 4) return GameConstants.scoreMatch4;
    return GameConstants.scoreMatch3;
  }

  /// Applies the combo multiplier if the last match was within the window.
  int applyCombo(int score, DateTime? lastMatchTime) {
    if (lastMatchTime == null) return score;
    final elapsed = DateTime.now().difference(lastMatchTime).inSeconds;
    if (elapsed <= GameConstants.comboWindowSeconds) {
      return (score * GameConstants.comboMultiplier).round();
    }
    return score;
  }

  /// Full score calculation for a set of matched positions, considering combos.
  ///
  /// Scores every distinct run independently by identifying each run's
  /// canonical head tile (leftmost for horizontal, topmost for vertical).
  int calculateMatchScore(
    Map<String, int> matchSizes,
    DateTime? lastMatchTime,
  ) {
    if (matchSizes.isEmpty) return 0;

    final keys = matchSizes.keys.toSet();
    String k(int r, int c) => '$r,$c';

    int total = 0;

    for (final key in keys) {
      final parts = key.split(',');
      final r = int.parse(parts[0]);
      final c = int.parse(parts[1]);

      // Score horizontal run only from its leftmost tile.
      if (!keys.contains(k(r, c - 1))) {
        int len = 0;
        int cc = c;
        while (keys.contains(k(r, cc))) {
          len++;
          cc++;
        }
        if (len >= 3) total += baseScore(len);
      }

      // Score vertical run only from its topmost tile.
      if (!keys.contains(k(r - 1, c))) {
        int len = 0;
        int rr = r;
        while (keys.contains(k(rr, c))) {
          len++;
          rr++;
        }
        if (len >= 3) total += baseScore(len);
      }
    }

    return applyCombo(total, lastMatchTime);
  }
}
