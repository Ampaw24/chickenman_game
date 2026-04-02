import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../gen/resources.dart';
import '../providers/onboarding_provider.dart';

class GameSelectScreen extends ConsumerStatefulWidget {
  const GameSelectScreen({super.key});

  @override
  ConsumerState<GameSelectScreen> createState() => _GameSelectScreenState();
}

class _GameSelectScreenState extends ConsumerState<GameSelectScreen>
    with TickerProviderStateMixin {
  late final AnimationController _particleCtrl;
  late final AnimationController _floatCtrl;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Play intro sound once the screen entrance animation has settled.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) AudioService.instance.playIntroSelect();
    });
  }

  @override
  void dispose() {
    _particleCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _onSelectGame(int index) {
    HapticFeedback.heavyImpact();
    AudioService.instance.playTap();
    if (index == 0) {
      context.go(AppRoutes.home);
    } else {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                MediaQuery.sizeOf(context).width * 0.031),
            side: const BorderSide(color: AppColors.surfaceColor),
          ),
          content: Row(
            children: [
              const Icon(HugeIcons.strokeRoundedClock01,
                  color: AppColors.secondary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Food Bucket coming soon — stay tuned!',
                style: AppTextStyles.body(
                  context,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final onboardingState = ref.watch(onboardingProvider);
    final nickname = onboardingState.nickname.isEmpty
        ? 'Player'
        : onboardingState.nickname;
    final avatarIndex = onboardingState.selectedAvatarIndex;
    final hasAvatar =
        avatarIndex >= 0 && avatarIndex < kAvatarOptions.length;

    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            // ── Ambient particle layer ───────────────────────────────────
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                painter: _GSParticlePainter(_particleCtrl.value),
                size: Size.infinite,
              ),
            ),

            // ── Top radial glow ──────────────────────────────────────────
            Positioned(
              top: -size.height * 0.06,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: size.width * 0.9,
                  height: size.width * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom radial glow ───────────────────────────────────────
            Positioned(
              bottom: -size.height * 0.08,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: size.width * 0.8,
                  height: size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.058),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.024),

                    // ── Welcome header ─────────────────────────────────
                    _WelcomeHeader(
                      nickname: nickname,
                      avatarPath:
                          hasAvatar ? kAvatarOptions[avatarIndex].assetPath : null,
                      floatController: _floatCtrl,
                    )
                        .animate()
                        .slideY(
                          begin: -0.3,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fade(duration: 500.ms),

                    SizedBox(height: size.height * 0.038),

                    // ── Section label ──────────────────────────────────
                    Row(
                      children: [
                        Container(
                          width: size.width * 0.01,
                          height: size.height * 0.028,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius:
                                BorderRadius.circular(size.width * 0.01),
                          ),
                        ),
                        SizedBox(width: size.width * 0.028),
                        Text(
                          'SELECT YOUR GAME',
                          style: AppTextStyles.label(
                            context,
                            color: AppColors.textSecondary,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fade(delay: 300.ms, duration: 450.ms)
                        .slideX(
                          begin: -0.2,
                          delay: 300.ms,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    SizedBox(height: size.height * 0.022),

                    // ── Game cards ─────────────────────────────────────
                    Expanded(
                      child: Column(
                        children: [
                          // Food Match
                          Expanded(
                            child: _GameCard(
                              index: 0,
                              title: 'FOOD MATCH',
                              subtitle:
                                  'Match tiles, earn rewards\nand climb the leaderboard.',
                              iconAsset: AppIcons.updateFoodMatchIcon,
                              gradientColors: const [
                                Color(0xFF2A0A0F),
                                Color(0xFF1A0A0A),
                              ],
                              accentColor: AppColors.primary,
                              badgeLabel: 'AVAILABLE',
                              badgeColor: AppColors.success,
                              isComingSoon: false,
                              isHovered: _hoveredIndex == 0,
                              onTap: () => _onSelectGame(0),
                              onHoverChange: (v) =>
                                  setState(() => _hoveredIndex = v ? 0 : null),
                              delay: const Duration(milliseconds: 420),
                            ),
                          ),

                          SizedBox(height: size.height * 0.018),

                          // Food Bucket
                          Expanded(
                            child: _GameCard(
                              index: 1,
                              title: 'FOOD BUCKET',
                              subtitle:
                                  'Catch the falling food before\ntime runs out.',
                              iconAsset: AppIcons.updatedFoodBacketIcon,
                              gradientColors: const [
                                Color(0xFF1A1400),
                                Color(0xFF0F0F00),
                              ],
                              accentColor: AppColors.secondary,
                              badgeLabel: 'COMING SOON',
                              badgeColor: AppColors.secondary,
                              isComingSoon: true,
                              isHovered: _hoveredIndex == 1,
                              onTap: () => _onSelectGame(1),
                              onHoverChange: (v) =>
                                  setState(() => _hoveredIndex = v ? 1 : null),
                              delay: const Duration(milliseconds: 560),
                            ),
                          ),

                          SizedBox(height: size.height * 0.028),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Welcome Header ─────────────────────────────────────────────────────────────

class _WelcomeHeader extends StatelessWidget {
  final String nickname;
  final String? avatarPath;
  final AnimationController floatController;

  const _WelcomeHeader({
    required this.nickname,
    required this.avatarPath,
    required this.floatController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Row(
      children: [
        // Avatar bubble with float animation
        AnimatedBuilder(
          animation: floatController,
          builder: (_, child) {
            final offset = (floatController.value - 0.5) * size.height * 0.012;
            return Transform.translate(
              offset: Offset(0, offset),
              child: child,
            );
          },
          child: Stack(
            children: [
              // Glow ring
              Container(
                width: size.width * 0.16,
                height: size.width * 0.16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: size.width * 0.06,
                      spreadRadius: size.width * 0.006,
                    ),
                  ],
                ),
              ),
              // Avatar image
              ClipOval(
                child: Container(
                  width: size.width * 0.16,
                  height: size.width * 0.16,
                  color: AppColors.cardBackground,
                  child: avatarPath != null
                      ? Image.asset(avatarPath!, fit: BoxFit.cover)
                      : Icon(
                          HugeIcons.strokeRoundedUser,
                          color: AppColors.textMuted,
                          size: size.width * 0.072,
                        ),
                ),
              ),
              // Online indicator dot
              Positioned(
                bottom: size.width * 0.004,
                right: size.width * 0.004,
                child: Container(
                  width: size.width * 0.036,
                  height: size.width * 0.036,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.backgroundDark,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: size.width * 0.038),

        // Text greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'WELCOME BACK,',
                    style: AppTextStyles.labelSmall(
                      context,
                      color: AppColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(width: size.width * 0.015),
                  Text('👋',
                      style: TextStyle(fontSize: size.width * 0.036)),
                ],
              ),
              SizedBox(height: size.height * 0.004),
              Text(
                nickname,
                style: AppTextStyles.h1(
                  context,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: size.height * 0.004),
              Text(
                'Ready for a challenge?',
                style: AppTextStyles.bodySmall(
                  context,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),

        // Settings icon
        Container(
          padding: EdgeInsets.all(size.width * 0.026),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(size.width * 0.028),
            border: Border.all(color: AppColors.surfaceColor),
          ),
          child: Icon(
            HugeIcons.strokeRoundedSettings01,
            color: AppColors.textMuted,
            size: size.width * 0.046,
          ),
        ),
      ],
    );
  }
}

// ── Game Card ──────────────────────────────────────────────────────────────────

class _GameCard extends StatefulWidget {
  final int index;
  final String title;
  final String subtitle;
  final String iconAsset;
  final List<Color> gradientColors;
  final Color accentColor;
  final String badgeLabel;
  final Color badgeColor;
  final bool isComingSoon;
  final bool isHovered;
  final VoidCallback onTap;
  final ValueChanged<bool> onHoverChange;
  final Duration delay;

  const _GameCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.gradientColors,
    required this.accentColor,
    required this.badgeLabel,
    required this.badgeColor,
    required this.isComingSoon,
    required this.isHovered,
    required this.onTap,
    required this.onHoverChange,
    required this.delay,
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0,
      upperBound: 0.05,
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.965).animate(
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

    return GestureDetector(
      onTapDown: (_) {
        _pressCtrl.forward();
        widget.onHoverChange(true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onHoverChange(false);
        widget.onTap();
      },
      onTapCancel: () {
        _pressCtrl.reverse();
        widget.onHoverChange(false);
      },
      child: ScaleTransition(
        scale: _pressScale,
        child: AnimatedContainer(
          duration: 250.ms,
          curve: Curves.easeOutCubic,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size.width * 0.056),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradientColors,
            ),
            border: Border.all(
              color: widget.isHovered
                  ? widget.accentColor.withValues(alpha: 0.7)
                  : widget.accentColor.withValues(alpha: 0.2),
              width: widget.isHovered ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(
                    alpha: widget.isHovered ? 0.32 : 0.14),
                blurRadius: widget.isHovered
                    ? size.width * 0.1
                    : size.width * 0.05,
                spreadRadius: widget.isHovered ? 2 : 0,
                offset: Offset(0, size.height * 0.006),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size.width * 0.056),
            child: Stack(
              children: [
                // ── Noise texture overlay ──────────────────────────
                Positioned.fill(
                  child: CustomPaint(
                    painter: _NoiseOverlayPainter(widget.accentColor),
                  ),
                ),

                // ── Diagonal accent line ───────────────────────────
                Positioned(
                  right: -size.width * 0.1,
                  top: -size.width * 0.1,
                  child: Container(
                    width: size.width * 0.6,
                    height: size.width * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.accentColor.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Main content ───────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.058,
                    vertical: size.height * 0.022,
                  ),
                  child: Row(
                    children: [
                      // Game icon with floating glow
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.028,
                                vertical: size.height * 0.005,
                              ),
                              decoration: BoxDecoration(
                                color: widget.badgeColor
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                    size.width * 0.031),
                                border: Border.all(
                                  color: widget.badgeColor
                                      .withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.badgeLabel,
                                style: AppTextStyles.badge(
                                  context,
                                  color: widget.badgeColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),

                            SizedBox(height: size.height * 0.014),

                            // Title
                            Text(
                              widget.title,
                              style: AppTextStyles.h2(
                                context,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),

                            SizedBox(height: size.height * 0.008),

                            // Subtitle
                            Text(
                              widget.subtitle,
                              style: AppTextStyles.bodySmall(
                                context,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),

                            SizedBox(height: size.height * 0.018),

                            // Play / Coming soon CTA
                            if (!widget.isComingSoon)
                              _PlayChip(accentColor: widget.accentColor)
                            else
                              _ComingSoonChip(),
                          ],
                        ),
                      ),

                      SizedBox(width: size.width * 0.028),

                      // Icon side
                      Expanded(
                        flex: 4,
                        child: _FloatingGameIcon(
                          assetPath: widget.iconAsset,
                          accentColor: widget.accentColor,
                          isHovered: widget.isHovered,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: widget.delay)
        .slideY(
          begin: 0.5,
          duration: 550.ms,
          curve: Curves.easeOutBack,
        )
        .fade(duration: 400.ms);
  }
}

// ── Floating Game Icon ─────────────────────────────────────────────────────────

class _FloatingGameIcon extends StatefulWidget {
  final String assetPath;
  final Color accentColor;
  final bool isHovered;

  const _FloatingGameIcon({
    required this.assetPath,
    required this.accentColor,
    required this.isHovered,
  });

  @override
  State<_FloatingGameIcon> createState() => _FloatingGameIconState();
}

class _FloatingGameIconState extends State<_FloatingGameIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (_, child) {
        final yOffset =
            (_floatCtrl.value - 0.5) * size.height * 0.018;
        return Transform.translate(
          offset: Offset(0, yOffset),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow halo
          AnimatedContainer(
            duration: 250.ms,
            width: size.width * 0.36,
            height: size.width * 0.36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withValues(
                      alpha: widget.isHovered ? 0.35 : 0.16),
                  blurRadius:
                      widget.isHovered ? size.width * 0.14 : size.width * 0.07,
                  spreadRadius: widget.isHovered ? size.width * 0.018 : 0,
                ),
              ],
            ),
          ),
          // Frosted disc behind icon
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: AnimatedContainer(
                duration: 250.ms,
                width: size.width * 0.28,
                height: size.width * 0.28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.accentColor.withValues(
                          alpha: widget.isHovered ? 0.22 : 0.1),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                  ),
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          // Icon image
          AnimatedScale(
            scale: widget.isHovered ? 1.08 : 1.0,
            duration: 250.ms,
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: size.width * 0.22,
              height: size.width * 0.22,
              child: Image.asset(
                widget.assetPath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Play Chip ──────────────────────────────────────────────────────────────────

class _PlayChip extends StatelessWidget {
  final Color accentColor;
  const _PlayChip({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.038,
        vertical: size.height * 0.009,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, accentColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(size.width * 0.031),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            HugeIcons.strokeRoundedPlayCircle,
            color: Colors.white,
            size: size.width * 0.036,
          ),
          SizedBox(width: size.width * 0.018),
          Text(
            'PLAY NOW',
            style: AppTextStyles.labelSmall(
              context,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coming Soon Chip ───────────────────────────────────────────────────────────

class _ComingSoonChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.038,
        vertical: size.height * 0.009,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(size.width * 0.031),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            HugeIcons.strokeRoundedClock01,
            color: AppColors.textMuted,
            size: size.width * 0.036,
          ),
          SizedBox(width: size.width * 0.018),
          Text(
            'COMING SOON',
            style: AppTextStyles.labelSmall(
              context,
              color: AppColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Noise Overlay Painter ──────────────────────────────────────────────────────

class _NoiseOverlayPainter extends CustomPainter {
  final Color accentColor;
  static final _rand = Random(12);

  _NoiseOverlayPainter(this.accentColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.025)
      ..strokeWidth = 1;

    for (int i = 0; i < 80; i++) {
      final x = _rand.nextDouble() * size.width;
      final y = _rand.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), _rand.nextDouble() * 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(_NoiseOverlayPainter old) => false;
}

// ── Particle Painter ───────────────────────────────────────────────────────────

class _GSParticle {
  final double x, y, size, speed, angle;
  final Color color;
  const _GSParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.color,
  });
}

class _GSParticlePainter extends CustomPainter {
  final double progress;
  static final _rand = Random(99);

  static final List<_GSParticle> _particles = List.generate(
    28,
    (i) => _GSParticle(
      x: _rand.nextDouble(),
      y: _rand.nextDouble(),
      size: _rand.nextDouble() * 2 + 0.6,
      speed: _rand.nextDouble() * 0.1 + 0.03,
      angle: _rand.nextDouble() * 2 * pi,
      color: [
        AppColors.primary,
        AppColors.secondary,
        AppColors.accent,
        Colors.white,
      ][_rand.nextInt(4)]
          .withValues(alpha: _rand.nextDouble() * 0.25 + 0.06),
    ),
  );

  _GSParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = (p.y + progress * p.speed) % 1.0;
      final x = p.x * size.width +
          sin(progress * 2 * pi * p.speed + p.angle) * 22;
      final y = t * size.height;
      canvas.drawCircle(
        Offset(x, y),
        p.size,
        Paint()..color = p.color,
      );
    }
  }

  @override
  bool shouldRepaint(_GSParticlePainter old) => old.progress != progress;
}
