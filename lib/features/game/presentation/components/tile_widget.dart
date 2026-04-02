import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/tile_model.dart';
import '../../../../core/constants/app_colors.dart';

class TileWidget extends StatelessWidget {
  final TileModel tile;
  final bool isSelected;
  final double size;

  const TileWidget({
    super.key,
    required this.tile,
    required this.isSelected,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isMatched = tile.state == TileState.matched;
    final isNew = tile.state == TileState.new_;

    Widget tileBody = _TileBody(
      tile: tile,
      isSelected: isSelected,
      size: size,
    );

    if (isMatched) {
      tileBody = tileBody
          .animate()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.35, 1.35),
            duration: 150.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.35, 1.35),
            end: const Offset(0, 0),
            duration: 150.ms,
            curve: Curves.easeIn,
          )
          .fade(
            begin: 1,
            end: 0,
            duration: 150.ms,
          );
    } else if (isNew) {
      tileBody = tileBody
          .animate()
          .scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.elasticOut,
          )
          .fade(begin: 0, end: 1, duration: 200.ms);
    }

    return tileBody;
  }
}

class _TileBody extends StatelessWidget {
  final TileModel tile;
  final bool isSelected;
  final double size;

  const _TileBody({
    required this.tile,
    required this.isSelected,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final color = tile.type.color;
    final isMatched = tile.state == TileState.matched;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.18),
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Color.lerp(color, Colors.white, 0.25)!,
            color,
            Color.lerp(color, Colors.black, 0.2)!,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        border: Border.all(
          color: isSelected
              ? AppColors.tileSelected
              : isMatched
                  ? AppColors.tileMatchGlow
                  : color.withValues(alpha: 0.5),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.tileSelected.withValues(alpha: 0.5)
                : isMatched
                    ? AppColors.tileMatchGlow.withValues(alpha: 0.6)
                    : color.withValues(alpha: 0.3),
            blurRadius: isSelected ? 12 : isMatched ? 16 : 6,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          tile.type.emoji,
          style: TextStyle(
            fontSize: size * 0.52,
            height: 1,
          ),
        ),
      ),
    );
  }
}
