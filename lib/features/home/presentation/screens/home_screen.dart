import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../app/router.dart';
import '../../../../shared/widgets/animated_button.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../rewards/presentation/providers/reward_provider.dart';
import '../../../../gen/resources.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(playerStatsProvider);
    final onboarding = ref.watch(onboardingProvider);
    final avatarIndex = onboarding.selectedAvatarIndex;
    final nickname = onboarding.nickname.isNotEmpty ? onboarding.nickname : 'Player';
    final avatarPath = avatarIndex >= 0 && avatarIndex < kAvatarOptions.length
        ? kAvatarOptions[avatarIndex].assetPath
        : null;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.051,
              vertical: size.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Top bar ──────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PlayerChip(name: nickname, points: stats.loyaltyPoints, avatarPath: avatarPath),
                    IconButton(
                      icon: Icon(
                        HugeIcons.strokeRoundedSettings01,
                        color: AppColors.textSecondary,
                        size: size.width * 0.056,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ).animate().fade(duration: 400.ms),

                SizedBox(height: size.height * 0.03),

                // ── Logo & title ─────────────────────────────────────────
                _Logo()
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 700.ms,
                      curve: Curves.elasticOut,
                    )
                    .fade(duration: 400.ms),

                SizedBox(height: size.height * 0.04),

                // ── Daily plays card ─────────────────────────────────────
                _DailyPlaysCard(
                  remaining: stats.remainingPlays,
                  onBuy: () => ref.read(playerStatsProvider.notifier).addPlays(3),
                )
                    .animate()
                    .slideY(begin: 0.3, duration: 500.ms, delay: 200.ms)
                    .fade(delay: 200.ms, duration: 400.ms),

                SizedBox(height: size.height * 0.03),

                // ── Play button ──────────────────────────────────────────
                AnimatedButton(
                  label: AppStrings.play,
                  width: double.infinity,
                  icon: HugeIcons.strokeRoundedPlayCircle,
                  gradient: AppColors.primaryGradient,
                  onTap: stats.remainingPlays > 0
                      ? () => context.push(AppRoutes.game)
                      : null,
                  enabled: stats.remainingPlays > 0,
                )
                    .animate()
                    .slideY(begin: 0.3, duration: 500.ms, delay: 300.ms)
                    .fade(delay: 300.ms, duration: 400.ms),

                SizedBox(height: size.height * 0.02),

                // ── Secondary actions ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _MenuCard(
                        label: AppStrings.myRewards,
                        subtitle: '${ref.watch(voucherProvider).where((v) => v.isActive).length} active',
                        onTap: () => context.push(AppRoutes.wallet),
                        hugeIcon: HugeIcons.strokeRoundedTicket01,
                      ),
                    ),
                    SizedBox(width: size.width * 0.031),
                    Expanded(
                      child: _MenuCard(
                        label: AppStrings.profile,
                        subtitle: '${stats.totalGames} games',
                        onTap: () => context.push(AppRoutes.profile),
                        avatarPath: avatarPath,
                        hugeIcon: HugeIcons.strokeRoundedUser,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .slideY(begin: 0.3, duration: 500.ms, delay: 400.ms)
                    .fade(delay: 400.ms, duration: 400.ms),

                SizedBox(height: size.height * 0.015),

                _MenuCard(
                  icon: '🏆',
                  label: AppStrings.leaderboard,
                  subtitle: AppStrings.comingSoon,
                  onTap: null,
                  fullWidth: true,
                )
                    .animate()
                    .slideY(begin: 0.3, duration: 500.ms, delay: 500.ms)
                    .fade(delay: 500.ms, duration: 400.ms),

                SizedBox(height: size.height * 0.02),

                if (stats.bestScore > 0)
                  _BestScoreStrip(score: stats.bestScore)
                      .animate()
                      .fade(delay: 600.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size.width * 0.082),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: size.width * 0.31,
              height: size.width * 0.31,
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
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: EdgeInsets.all(size.width * 0.041),
              child: Image.asset(
                AppIcons.chickenmanlogo,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Text(
          'FOOD MATCH',
          style: AppTextStyles.h2(context, color: AppColors.secondary, letterSpacing: 6),
        ),
      ],
    );
  }
}

class _PlayerChip extends StatelessWidget {
  final String name;
  final int points;
  final String? avatarPath;

  const _PlayerChip({
    required this.name,
    required this.points,
    this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.036,
        vertical: size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(size.width * 0.062),
        border: Border.all(color: AppColors.surfaceColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: avatarPath != null
                ? Image.asset(
                    avatarPath!,
                    width: size.width * 0.082,
                    height: size.width * 0.082,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: size.width * 0.082,
                    height: size.width * 0.082,
                    color: AppColors.primary.withValues(alpha: 0.3),
                    child: Icon(
                      HugeIcons.strokeRoundedUser,
                      color: AppColors.primary,
                      size: size.width * 0.046,
                    ),
                  ),
          ),
          SizedBox(width: size.width * 0.021),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: AppTextStyles.bodySmall(context, color: AppColors.textPrimary),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(HugeIcons.strokeRoundedStar, color: AppColors.secondary, size: size.width * 0.031),
                  SizedBox(width: size.width * 0.01),
                  Text(
                    '$points pts',
                    style: AppTextStyles.caption(context, color: AppColors.secondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyPlaysCard extends StatelessWidget {
  final int remaining;
  final VoidCallback onBuy;

  const _DailyPlaysCard({required this.remaining, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: EdgeInsets.all(size.width * 0.051),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(size.width * 0.051),
        border: Border.all(
          color: remaining > 0
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: List.generate(
              3,
              (i) => Padding(
                padding: EdgeInsets.only(right: size.width * 0.01),
                child: Icon(
                  HugeIcons.strokeRoundedFavourite,
                  color: i < remaining ? AppColors.error : AppColors.textMuted,
                  size: size.width * 0.072,
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.041),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.dailyPlays,
                  style: AppTextStyles.label(context, color: AppColors.textSecondary),
                ),
                Text(
                  '$remaining ${AppStrings.playsLeft}',
                  style: AppTextStyles.titleMedium(
                    context,
                    color: remaining > 0 ? AppColors.textPrimary : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          if (remaining == 0)
            TextButton(
              onPressed: onBuy,
              child: Text(
                'Buy',
                style: AppTextStyles.body(context, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final bool fullWidth;
  final String? avatarPath;
  final IconData? hugeIcon;

  const _MenuCard({
    this.icon = '',
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.fullWidth = false,
    this.avatarPath,
    this.hugeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final iconSize = size.width * 0.072;

    Widget iconWidget;
    if (avatarPath != null) {
      iconWidget = ClipOval(
        child: Image.asset(
          avatarPath!,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.cover,
        ),
      );
    } else if (hugeIcon != null) {
      iconWidget = Icon(hugeIcon, color: AppColors.textSecondary, size: iconSize);
    } else {
      iconWidget = Text(icon, style: TextStyle(fontSize: iconSize));
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.all(size.width * 0.041),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(size.width * 0.041),
          border: Border.all(color: AppColors.surfaceColor),
        ),
        child: Row(
          mainAxisAlignment: fullWidth
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            iconWidget,
            SizedBox(width: size.width * 0.031),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body(context, color: AppColors.textPrimary),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption(context, color: AppColors.textMuted),
                ),
              ],
            ),
            if (fullWidth) ...[
              const Spacer(),
              Icon(
                onTap != null
                    ? HugeIcons.strokeRoundedArrowRight01
                    : HugeIcons.strokeRoundedLockPassword,
                color: AppColors.textMuted,
                size: size.width * 0.036,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BestScoreStrip extends StatelessWidget {
  final int score;

  const _BestScoreStrip({required this.score});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.051,
        vertical: size.height * 0.015,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(size.width * 0.031),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(HugeIcons.strokeRoundedAward01, color: AppColors.secondary, size: size.width * 0.051),
          SizedBox(width: size.width * 0.021),
          Text(
            'Best Score: ',
            style: AppTextStyles.body(context, color: AppColors.textSecondary),
          ),
          Text(
            '$score',
            style: AppTextStyles.titleMedium(context, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}
