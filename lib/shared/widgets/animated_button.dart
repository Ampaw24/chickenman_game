import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class AnimatedButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final IconData? icon;
  final double? width;
  final bool enabled;

  const AnimatedButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradient,
    this.icon,
    this.width,
    this.enabled = true,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    if (widget.enabled) widget.onTap?.call();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gradient = widget.gradient ?? AppColors.primaryGradient;
    final height = size.height * 0.082;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.width,
          height: height,
          decoration: BoxDecoration(
            gradient: widget.enabled ? gradient : null,
            color: widget.enabled ? null : Colors.grey.shade700,
            borderRadius: BorderRadius.circular(size.width * 0.041),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: Offset(0, size.height * 0.008),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: size.width * 0.064),
                SizedBox(width: size.width * 0.021),
              ],
              Text(
                widget.label,
                style: AppTextStyles.titleLarge(context, color: Colors.white, letterSpacing: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
