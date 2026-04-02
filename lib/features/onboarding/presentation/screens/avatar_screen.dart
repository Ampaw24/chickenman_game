import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../providers/onboarding_provider.dart';
import '../../../../core/services/audio_service.dart';

class AvatarScreen extends ConsumerStatefulWidget {
  const AvatarScreen({super.key});

  @override
  ConsumerState<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends ConsumerState<AvatarScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _select(int index) {
    HapticFeedback.mediumImpact();
    AudioService.instance.playTap();
    ref.read(onboardingProvider.notifier).setAvatarIndex(index);
  }

  void _start() {
    final state = ref.read(onboardingProvider);
    if (state.selectedAvatarIndex < 0) return;
    HapticFeedback.heavyImpact();
    AudioService.instance.playTap();
    context.go(AppRoutes.gameSelect);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final selected = ref.watch(onboardingProvider).selectedAvatarIndex;
    final hasSelection = selected >= 0;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.07,
                  vertical: size.height * 0.02,
                ),
                child: Row(
                  children: [
                    _BackButton(),
                    const Spacer(),
                    _StepIndicator(current: 2, total: 2),
                  ],
                ).animate().fade(duration: 350.ms),
              ),

              // ── Heading ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose your\navatar',
                      style: AppTextStyles.display(
                        context,
                        color: AppColors.textPrimary,
                      ),
                    )
                        .animate()
                        .slideY(
                          begin: 0.4,
                          duration: 500.ms,
                          delay: 100.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fade(delay: 100.ms, duration: 400.ms),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      'Pick the avatar that represents you\nin every match.',
                      style: AppTextStyles.bodyLarge(
                        context,
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fade(delay: 250.ms, duration: 400.ms),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.03),

              // ── Selected preview ─────────────────────────────────────────
              AnimatedSwitcher(
                duration: 400.ms,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: hasSelection
                    ? _SelectedPreview(
                        key: ValueKey(selected),
                        avatar: kAvatarOptions[selected],
                        glowController: _glowController,
                      )
                    : _EmptyPreview(key: const ValueKey('empty')),
              ).animate().fade(delay: 300.ms, duration: 400.ms),

              SizedBox(height: size.height * 0.028),

              // ── Avatar grid ──────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: kAvatarOptions.length,
                    itemBuilder: (context, index) {
                      return _AvatarCard(
                        avatar: kAvatarOptions[index],
                        index: index,
                        isSelected: selected == index,
                        onTap: () => _select(index),
                        delay: Duration(milliseconds: 80 * index),
                      );
                    },
                  ),
                ),
              ),

              // ── CTA button ───────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.07,
                  vertical: size.height * 0.024,
                ),
                child: _StartButton(
                  enabled: hasSelection,
                  onTap: _start,
                )
                    .animate()
                    .slideY(
                      begin: 0.6,
                      duration: 500.ms,
                      delay: 600.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .fade(delay: 600.ms, duration: 400.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Selected Preview ───────────────────────────────────────────────────────────

class _SelectedPreview extends StatelessWidget {
  final AvatarOption avatar;
  final AnimationController glowController;

  const _SelectedPreview({
    super.key,
    required this.avatar,
    required this.glowController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return AnimatedBuilder(
      animation: glowController,
      builder: (_, __) {
        final glow = (glowController.value * 0.25) + 0.15;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow ring
            Container(
              width: size.width * 0.32,
              height: size.width * 0.32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: glow),
                    blurRadius: size.width * 0.12,
                    spreadRadius: size.width * 0.02,
                  ),
                ],
              ),
            ),
            // Avatar circle
            ClipOval(
              child: SizedBox(
                width: size.width * 0.24,
                height: size.width * 0.24,
                child: Image.asset(
                  avatar.assetPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Label tag
            Positioned(
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.036,
                  vertical: size.height * 0.006,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(size.width * 0.041),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Text(
                  avatar.label.toUpperCase(),
                  style: AppTextStyles.labelSmall(
                    context,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Empty Preview ──────────────────────────────────────────────────────────────

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      width: size.width * 0.24,
      height: size.width * 0.24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardBackground,
        border: Border.all(
          color: AppColors.surfaceColor,
          width: 2,
        ),
      ),
      child: Icon(
        HugeIcons.strokeRoundedUser,
        color: AppColors.textMuted,
        size: size.width * 0.082,
      ),
    );
  }
}

// ── Avatar Card ────────────────────────────────────────────────────────────────

class _AvatarCard extends StatefulWidget {
  final AvatarOption avatar;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration delay;

  const _AvatarCard({
    required this.avatar,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<_AvatarCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0,
      upperBound: 0.05,
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Padding(
      padding: EdgeInsets.all(size.width * 0.022),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: ScaleTransition(
          scale: _pressScale,
          child: AnimatedContainer(
            duration: 280.ms,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size.width * 0.051),
              color: widget.isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.cardBackground,
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary
                    : AppColors.surfaceColor,
                width: widget.isSelected ? 2.5 : 1.5,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                // Avatar image
                ClipRRect(
                  borderRadius: BorderRadius.circular(size.width * 0.046),
                  child: SizedBox.expand(
                    child: Image.asset(
                      widget.avatar.assetPath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Overlay gradient for label
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(size.width * 0.046),
                      bottomRight: Radius.circular(size.width * 0.046),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.028,
                          vertical: size.height * 0.01,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.72),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          widget.avatar.label,
                          style: AppTextStyles.body(
                            context,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Checkmark badge when selected
                if (widget.isSelected)
                  Positioned(
                    top: size.width * 0.022,
                    right: size.width * 0.022,
                    child: Container(
                      padding: EdgeInsets.all(size.width * 0.015),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedCheckmarkCircle01,
                        color: Colors.white,
                        size: size.width * 0.038,
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0, 0),
                          duration: 300.ms,
                          curve: Curves.elasticOut,
                        )
                        .fade(duration: 200.ms),
                  ),
              ],
            ),
          ),
        ),
      )
          .animate(delay: widget.delay)
          .scale(
            begin: const Offset(0.7, 0.7),
            duration: 450.ms,
            curve: Curves.easeOutBack,
          )
          .fade(duration: 350.ms),
    );
  }
}

// ── Start Button ───────────────────────────────────────────────────────────────

class _StartButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _StartButton({required this.enabled, required this.onTap});

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0,
      upperBound: 0.05,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _ctrl.forward() : null,
      onTapUp: widget.enabled
          ? (_) {
              _ctrl.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: 250.ms,
          width: double.infinity,
          height: size.height * 0.078,
          decoration: BoxDecoration(
            gradient: widget.enabled ? AppColors.primaryGradient : null,
            color: widget.enabled ? null : AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(size.width * 0.041),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 22,
                      offset: Offset(0, size.height * 0.008),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                HugeIcons.strokeRoundedPlayCircle,
                color: widget.enabled ? Colors.white : AppColors.textMuted,
                size: size.width * 0.056,
              ),
              SizedBox(width: size.width * 0.028),
              Text(
                "LET'S PLAY!",
                style: AppTextStyles.titleLarge(
                  context,
                  color: widget.enabled ? Colors.white : AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Back Button ────────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.028),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(size.width * 0.031),
          border: Border.all(color: AppColors.surfaceColor),
        ),
        child: Icon(
          HugeIcons.strokeRoundedArrowLeft01,
          color: AppColors.textSecondary,
          size: size.width * 0.046,
        ),
      ),
    );
  }
}

// ── Step Indicator ─────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i + 1 == current;
        final done = i + 1 < current;
        return AnimatedContainer(
          duration: 300.ms,
          margin: EdgeInsets.only(left: i > 0 ? size.width * 0.018 : 0),
          width: active ? size.width * 0.072 : size.width * 0.028,
          height: size.width * 0.028,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : done
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(size.width * 0.014),
          ),
        );
      }),
    );
  }
}
