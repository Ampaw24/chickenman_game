import '../../data/models/tile_model.dart';
import '../../../../core/constants/game_constants.dart';

/// Detects matches on the 6×6 board.
/// Returns a set of (row,col) positions that form valid matches.
class MatchDetector {
  /// Scans the entire grid and returns all matched positions.
  Set<String> findAllMatches(List<List<TileModel?>> grid) {
    final matched = <String>{};
    matched.addAll(_scanHorizontal(grid));
    matched.addAll(_scanVertical(grid));
    return matched;
  }

  Set<String> _scanHorizontal(List<List<TileModel?>> grid) {
    final matched = <String>{};
    for (int r = 0; r < GameConstants.gridRows; r++) {
      int start = 0;
      while (start < GameConstants.gridCols) {
        final tile = grid[r][start];
        if (tile == null) {
          start++;
          continue;
        }
        int end = start + 1;
        while (end < GameConstants.gridCols &&
            grid[r][end]?.type == tile.type) {
          end++;
        }
        if (end - start >= GameConstants.minMatch) {
          for (int c = start; c < end; c++) {
            matched.add(_key(r, c));
          }
        }
        start = end;
      }
    }
    return matched;
  }

  Set<String> _scanVertical(List<List<TileModel?>> grid) {
    final matched = <String>{};
    for (int c = 0; c < GameConstants.gridCols; c++) {
      int start = 0;
      while (start < GameConstants.gridRows) {
        final tile = grid[start][c];
        if (tile == null) {
          start++;
          continue;
        }
        int end = start + 1;
        while (end < GameConstants.gridRows &&
            grid[end][c]?.type == tile.type) {
          end++;
        }
        if (end - start >= GameConstants.minMatch) {
          for (int r = start; r < end; r++) {
            matched.add(_key(r, c));
          }
        }
        start = end;
      }
    }
    return matched;
  }

  /// Returns how many tiles are in the largest contiguous match group
  /// for a given set of matched positions (used for scoring).
  Map<String, int> getMatchSizes(
    List<List<TileModel?>> grid,
    Set<String> matched,
  ) {
    final sizes = <String, int>{};
    // For each matched position, find its run length
    for (final key in matched) {
      final parts = key.split(',');
      final r = int.parse(parts[0]);
      final c = int.parse(parts[1]);
      // Find horizontal run size
      int hSize = 1;
      int left = c - 1;
      while (left >= 0 && matched.contains(_key(r, left))) {
        hSize++;
        left--;
      }
      int right = c + 1;
      while (right < GameConstants.gridCols && matched.contains(_key(r, right))) {
        hSize++;
        right++;
      }
      // Find vertical run size
      int vSize = 1;
      int up = r - 1;
      while (up >= 0 && matched.contains(_key(up, c))) {
        vSize++;
        up--;
      }
      int down = r + 1;
      while (down < GameConstants.gridRows && matched.contains(_key(down, c))) {
        vSize++;
        down++;
      }
      sizes[key] = hSize > vSize ? hSize : vSize;
    }
    return sizes;
  }

  bool isAdjacent(int r1, int c1, int r2, int c2) {
    return (r1 == r2 && (c1 - c2).abs() == 1) ||
        (c1 == c2 && (r1 - r2).abs() == 1);
  }

  String _key(int r, int c) => '$r,$c';
}
