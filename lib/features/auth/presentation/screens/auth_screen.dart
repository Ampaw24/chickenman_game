import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../gen/resources.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _handleAuth(String provider) {
    ref.read(onboardingProvider.notifier).setAuthProvider(provider);
    context.push(AppRoutes.nickname);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            // Particle background
            AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => CustomPaint(
                painter: _AuthParticlePainter(_particleController.value),
                size: Size.infinite,
              ),
            ),

            // Radial glow top-center
            Positioned(
              top: -size.height * 0.08,
              left: size.width * 0.1,
              right: size.width * 0.1,
              child: Container(
                height: size.height * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.06),

                    // ── Logo ──────────────────────────────────────────────
                    _GlassLogo()
                        .animate()
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          duration: 700.ms,
                          curve: Curves.elasticOut,
                        )
                        .fade(duration: 400.ms),

                    SizedBox(height: size.height * 0.04),

                    // ── Heading ───────────────────────────────────────────
                    Text(
                      'JOIN THE GAME',
                      style: AppTextStyles.h1(
                        context,
                        letterSpacing: 3,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .slideY(
                          begin: 0.4,
                          duration: 550.ms,
                          delay: 250.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fade(delay: 250.ms, duration: 400.ms),

                    SizedBox(height: size.height * 0.012),

                    Text(
                      'Sign in to save your progress,\nrewards and climb the leaderboard.',
                      style: AppTextStyles.body(
                        context,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 400.ms, duration: 450.ms),

                    const Spacer(),

                    // ── Auth buttons ──────────────────────────────────────
                    _SocialAuthButton(
                      label: 'Continue with Google',
                      icon: HugeIcons.strokeRoundedGoogle,
                      isDark: false,
                      onTap: () => _handleAuth('google'),
                    )
                        .animate()
                        .slideY(
                          begin: 0.5,
                          duration: 500.ms,
                          delay: 550.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fade(delay: 550.ms, duration: 400.ms),

                    SizedBox(height: size.height * 0.018),

                    _SocialAuthButton(
                      label: 'Continue with Apple',
                      icon: HugeIcons.strokeRoundedApple,
                      isDark: true,
                      onTap: () => _handleAuth('apple'),
                    )
                        .animate()
                        .slideY(
                          begin: 0.5,
                          duration: 500.ms,
                          delay: 650.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fade(delay: 650.ms, duration: 400.ms),

                    SizedBox(height: size.height * 0.032),

                    // ── Divider row ───────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.surfaceColor,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.036),
                          child: Text(
                            'or',
                            style: AppTextStyles.caption(context),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.surfaceColor,
                          ),
                        ),
                      ],
                    ).animate().fade(delay: 750.ms, duration: 400.ms),

                    SizedBox(height: size.height * 0.032),

                    // ── Guest button ──────────────────────────────────────
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.home),
                      child: Container(
                        width: double.infinity,
                        height: size.height * 0.072,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.surfaceColor,
                            width: 1.5,
                          ),
                          borderRadius:
                              BorderRadius.circular(size.width * 0.038),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Play as Guest',
                          style: AppTextStyles.titleSmall(
                            context,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .slideY(
                          begin: 0.4,
                          duration: 500.ms,
                          delay: 800.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fade(delay: 800.ms, duration: 400.ms),

                    SizedBox(height: size.height * 0.028),

                    // ── Terms ─────────────────────────────────────────────
                    Text(
                      'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                      style: AppTextStyles.caption(
                        context,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 950.ms, duration: 400.ms),

                    SizedBox(height: size.height * 0.03),
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

// ── Glass Logo ─────────────────────────────────────────────────────────────────

class _GlassLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring pulse
        Container(
          width: size.width * 0.44,
          height: size.width * 0.44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.18),
                Colors.transparent,
              ],
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.25, 1.25),
              duration: 2000.ms,
              curve: Curves.easeInOut,
            ),

        // Inner glow ring
        Container(
          width: size.width * 0.36,
          height: size.width * 0.36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.secondary.withValues(alpha: 0.12),
                Colors.transparent,
              ],
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1.15, 1.15),
              end: const Offset(0.9, 0.9),
              duration: 2000.ms,
              curve: Curves.easeInOut,
            ),

        // Logo container
        ClipRRect(
          borderRadius: BorderRadius.circular(size.width * 0.082),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: size.width * 0.28,
              height: size.width * 0.28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * 0.082),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.06),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              padding: EdgeInsets.all(size.width * 0.030),
              child: Image.asset(
                AppIcons.pizzamanlogo,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Social Auth Button ─────────────────────────────────────────────────────────

class _SocialAuthButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _SocialAuthButton({
    required this.label,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_SocialAuthButton> createState() => _SocialAuthButtonState();
}

class _SocialAuthButtonState extends State<_SocialAuthButton>
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
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: widget.isDark
            ? _buildDarkButton(context, size)
            : _buildLightButton(context, size),
      ),
    );
  }

  Widget _buildLightButton(BuildContext context, Size size) {
    return Container(
      width: double.infinity,
      height: size.height * 0.072,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.038),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: Offset(0, size.height * 0.006),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: widget.icon,
            color: const Color(0xFF1A1A1A),
            size: size.width * 0.056,
          ),
          SizedBox(width: size.width * 0.028),
          Text(
            widget.label,
            style: AppTextStyles.titleSmall(
              context,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkButton(BuildContext context, Size size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size.width * 0.038),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          height: size.height * 0.072,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(size.width * 0.038),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: widget.icon,
                color: AppColors.textPrimary,
                size: size.width * 0.056,
              ),
              SizedBox(width: size.width * 0.028),
              Text(
                widget.label,
                style: AppTextStyles.titleSmall(
                  context,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Particle Painter ──────────────────────────────────────────────────────────

class _AuthParticle {
  final double x, y, size, speed, angle;
  final Color color;
  const _AuthParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.color,
  });
}

class _AuthParticlePainter extends CustomPainter {
  final double progress;
  static final _rand = Random(77);

  static final List<_AuthParticle> _particles = List.generate(
    30,
    (i) => _AuthParticle(
      x: _rand.nextDouble(),
      y: _rand.nextDouble(),
      size: _rand.nextDouble() * 2.5 + 0.8,
      speed: _rand.nextDouble() * 0.12 + 0.04,
      angle: _rand.nextDouble() * 2 * pi,
      color: [
        AppColors.primary,
        AppColors.secondary,
        AppColors.accent,
        Colors.white,
      ][_rand.nextInt(4)]
          .withValues(
        alpha: _rand.nextDouble() * 0.3 + 0.08,
      ),
    ),
  );

  _AuthParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = (p.y + progress * p.speed) % 1.0;
      final x =
          p.x * size.width + sin(progress * 2 * pi * p.speed + p.angle) * 25;
      final y = t * size.height;
      canvas.drawCircle(
        Offset(x, y),
        p.size,
        Paint()..color = p.color,
      );
    }
  }

  @override
  bool shouldRepaint(_AuthParticlePainter old) => old.progress != progress;
}
