import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../gen/resources.dart';
import '../../../../app/router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _runLoadingSequence();
  }

  Future<void> _runLoadingSequence() async {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() => _progress = i / 10.0);
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) context.go(AppRoutes.auth);
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.backgroundMid,
              AppColors.backgroundLight,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Particle layer
            AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => CustomPaint(
                painter: _ParticlePainter(_particleController.value),
                size: Size.infinite,
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow pulse
                        Container(
                          width: size.width * 0.46,
                          height: size.width * 0.46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.3, 1.3),
                              duration: 1500.ms,
                              curve: Curves.easeInOut,
                            ),

                        // Logo — glassmorphic container
                        ClipRRect(
                          borderRadius: BorderRadius.circular(size.width * 0.09),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              width: size.width * 0.36,
                              height: size.width * 0.36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(size.width * 0.09),
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
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 32,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(size.width * 0.046),
                              child: Image.asset(
                                AppIcons.chickenmanlogo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0, 0),
                              end: const Offset(1, 1),
                              delay: 200.ms,
                              duration: 600.ms,
                              curve: Curves.elasticOut,
                            )
                            .fade(duration: 400.ms),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  Text(
                    'FOOD MATCH',
                    style: AppTextStyles.h2(
                      context,
                      color: AppColors.secondary,
                      letterSpacing: 8,
                    ),
                  )
                      .animate()
                      .slideY(
                        begin: 0.4,
                        end: 0,
                        delay: 650.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .fade(delay: 650.ms, duration: 500.ms),

                  SizedBox(height: size.height * 0.01),

                  Text(
                    'Match. Win. Eat.',
                    style: AppTextStyles.body(
                      context,
                      color: AppColors.textMuted,
                    ),
                  )
                      .animate()
                      .fade(delay: 900.ms, duration: 500.ms),

                  const Spacer(flex: 2),

                  // Loading bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(size.width * 0.02),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: size.height * 0.008,
                            backgroundColor: AppColors.surfaceColor,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.015),
                        Text(
                          _progress < 1.0
                              ? 'Loading... ${(_progress * 100).round()}%'
                              : 'Ready!',
                          style: AppTextStyles.bodySmall(context),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 1000.ms, duration: 400.ms),

                  SizedBox(height: size.height * 0.06),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Particle Painter ─────────────────────────────────────────────────────────

class _Particle {
  final double x, y, size, speed, angle;
  final Color color;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  static final _rand = Random(42);

  static final List<_Particle> _particles = List.generate(
    40,
    (i) => _Particle(
      x: _rand.nextDouble(),
      y: _rand.nextDouble(),
      size: _rand.nextDouble() * 3 + 1,
      speed: _rand.nextDouble() * 0.15 + 0.05,
      angle: _rand.nextDouble() * 2 * pi,
      color: [
        AppColors.primary,
        AppColors.secondary,
        AppColors.accent,
        Colors.white,
      ][_rand.nextInt(4)].withValues(alpha: _rand.nextDouble() * 0.4 + 0.1),
    ),
  );

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = (p.y + progress * p.speed) % 1.0;
      final x = p.x * size.width + sin(progress * 2 * pi * p.speed + p.angle) * 30;
      final y = t * size.height;
      canvas.drawCircle(
        Offset(x, y),
        p.size,
        Paint()..color = p.color,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
