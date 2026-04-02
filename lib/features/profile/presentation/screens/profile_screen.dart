import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/helpers.dart';
import '../../../rewards/presentation/providers/reward_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(playerStatsProvider);
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.051),
            child: Column(
              children: [
                // App bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.021),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(size.width * 0.031),
                        ),
                        child: Icon(
                          HugeIcons.strokeRoundedArrowLeft01,
                          color: AppColors.textSecondary,
                          size: size.width * 0.046,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.031),
                    Text(
                      AppStrings.myProfile,
                      style: AppTextStyles.h2(context, color: AppColors.textPrimary),
                    ),
                  ],
                ).animate().fade(duration: 400.ms),

                SizedBox(height: size.height * 0.04),

                // Avatar
                const _AvatarSection()
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .fade(duration: 400.ms),

                SizedBox(height: size.height * 0.04),

                // Stats grid
                _StatsGrid(stats: stats)
                    .animate()
                    .slideY(begin: 0.3, duration: 500.ms, delay: 300.ms)
                    .fade(delay: 300.ms, duration: 400.ms),

                SizedBox(height: size.height * 0.025),

                // Loyalty card
                _LoyaltyCard(points: stats.loyaltyPoints)
                    .animate()
                    .slideY(begin: 0.3, duration: 500.ms, delay: 500.ms)
                    .fade(delay: 500.ms, duration: 400.ms),

                SizedBox(height: size.height * 0.025),

                // Progress to next reward
                _NextRewardProgress(score: stats.bestScore)
                    .animate()
                    .slideY(begin: 0.3, duration: 500.ms, delay: 700.ms)
                    .fade(delay: 700.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Avatar Section ───────────────────────────────────────────────────────────

class _AvatarSection extends ConsumerWidget {
  const _AvatarSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final onboarding = ref.watch(onboardingProvider);
    final avatarIndex = onboarding.selectedAvatarIndex;
    final nickname = onboarding.nickname.isNotEmpty ? onboarding.nickname : 'Player';
    final avatarPath = avatarIndex >= 0 && avatarIndex < kAvatarOptions.length
        ? kAvatarOptions[avatarIndex].assetPath
        : null;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: size.width * 0.256,
              height: size.width * 0.256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipOval(
                child: avatarPath != null
                    ? Image.asset(
                        avatarPath,
                        width: size.width * 0.256,
                        height: size.width * 0.256,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(
                          HugeIcons.strokeRoundedUser,
                          color: Colors.white,
                          size: size.width * 0.124,
                        ),
                      ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(size.width * 0.015),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                HugeIcons.strokeRoundedPencilEdit01,
                color: Colors.black,
                size: size.width * 0.036,
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.02),
        Text(
          nickname,
          style: AppTextStyles.h1(context, color: AppColors.textPrimary),
        ),
        SizedBox(height: size.height * 0.005),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.036,
            vertical: size.height * 0.005,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(size.width * 0.051),
          ),
          child: Text(
            '🍔 Food Fanatic',
            style: AppTextStyles.label(context, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

// ─── Stats Grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final PlayerStatsState stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: size.width * 0.031,
      mainAxisSpacing: size.width * 0.031,
      childAspectRatio: 1.4,
      children: [
        _StatTile(
          icon: '🎮',
          label: AppStrings.totalGames,
          value: '${stats.totalGames}',
          color: AppColors.primary,
        ),
        _StatTile(
          icon: '🏆',
          label: AppStrings.bestScore,
          value: Helpers.formatScore(stats.bestScore),
          color: AppColors.secondary,
        ),
        _StatTile(
          icon: '⭐',
          label: AppStrings.totalPoints,
          value: '${stats.loyaltyPoints}',
          color: AppColors.accent,
        ),
        _StatTile(
          icon: '🎟️',
          label: AppStrings.totalVouchers,
          value: '${stats.totalGames}',
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.041,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(size.width * 0.041),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(icon, style: TextStyle(fontSize: size.width * 0.062)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.h2(context, color: color),
              ),
              Text(
                label,
                style: AppTextStyles.caption(context, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Loyalty Card ─────────────────────────────────────────────────────────────

class _LoyaltyCard extends StatelessWidget {
  final int points;

  const _LoyaltyCard({required this.points});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.051),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(size.width * 0.051),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Text('⭐', style: TextStyle(fontSize: size.width * 0.103)),
          SizedBox(width: size.width * 0.041),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOYALTY POINTS',
                  style: AppTextStyles.label(context, color: Colors.black54),
                ),
                Text(
                  '$points pts',
                  style: AppTextStyles.h1(context, color: Colors.black),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.031,
              vertical: size.height * 0.0075,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(size.width * 0.031),
            ),
            child: Text(
              'REDEEM',
              style: AppTextStyles.label(context, color: Colors.black)
                  .copyWith(letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Next Reward Progress ─────────────────────────────────────────────────────

class _NextRewardProgress extends StatelessWidget {
  final int score;

  const _NextRewardProgress({required this.score});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final thresholds = [400, 800, 1500, 2500];
    final labels = ['5% Discount', 'Free Drink', 'Free Fries', 'Free Burger'];
    final emojis = ['🏷️', '🥤', '🍟', '🍔'];

    int nextIndex = thresholds.indexWhere((t) => score < t);
    if (nextIndex == -1) nextIndex = thresholds.length - 1;

    final nextThreshold = thresholds[nextIndex];
    final prevThreshold = nextIndex > 0 ? thresholds[nextIndex - 1] : 0;
    final progress =
        ((score - prevThreshold) / (nextThreshold - prevThreshold)).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(size.width * 0.051),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(size.width * 0.051),
        border: Border.all(color: AppColors.surfaceColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NEXT REWARD',
                style: AppTextStyles.label(context, color: AppColors.textMuted),
              ),
              Text(
                '${emojis[nextIndex]} ${labels[nextIndex]}',
                style: AppTextStyles.bodySmall(context, color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),
          ClipRRect(
            borderRadius: BorderRadius.circular(size.width * 0.021),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: size.height * 0.013,
              backgroundColor: AppColors.surfaceColor,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${Helpers.formatScore(score)} pts',
                style: AppTextStyles.bodySmall(context, color: AppColors.primary),
              ),
              Text(
                '${Helpers.formatScore(nextThreshold)} pts needed',
                style: AppTextStyles.bodySmall(context, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
