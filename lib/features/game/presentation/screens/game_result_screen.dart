import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../shared/widgets/animated_button.dart';
import '../../../../app/router.dart';
import '../../../rewards/presentation/providers/reward_provider.dart';

class GameResultScreen extends ConsumerStatefulWidget {
  final int score;
  final String reward;
  final int loyaltyPoints;

  const GameResultScreen({
    super.key,
    required this.score,
    required this.reward,
    required this.loyaltyPoints,
  });

  @override
  ConsumerState<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends ConsumerState<GameResultScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    if (widget.score > 500) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _confetti.play();
        AudioService.instance.playWin();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 500),
          AudioService.instance.playLose);
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String get _rewardEmoji {
    if (widget.score >= GameConstants.rewardTier5Score) return '🍔';
    if (widget.score >= GameConstants.rewardTier4Score) return '🍟';
    if (widget.score >= GameConstants.rewardTier3Score) return '🥤';
    if (widget.score >= GameConstants.rewardTier2Score) return '🏷️';
    return '⭐';
  }

  Color get _tierColor {
    if (widget.score >= GameConstants.rewardTier5Score) return AppColors.rewardDiamond;
    if (widget.score >= GameConstants.rewardTier4Score) return AppColors.rewardGold;
    if (widget.score >= GameConstants.rewardTier3Score) return AppColors.rewardSilver;
    if (widget.score >= GameConstants.rewardTier2Score) return AppColors.rewardBronze;
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(playerStatsProvider);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.backgroundDark,
                  AppColors.backgroundMid,
                  AppColors.backgroundLight,
                ],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                AppColors.accent,
                Colors.white,
                Color(0xFFE040FB),
              ],
              gravity: 0.3,
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(size.width * 0.062),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.02),

                  // Title
                  Text(
                    AppStrings.greatJob,
                    style: AppTextStyles.display(context,
                        color: AppColors.textPrimary, letterSpacing: 1),
                  )
                      .animate()
                      .fade(duration: 500.ms)
                      .slideY(begin: -0.3, duration: 500.ms),

                  SizedBox(height: size.height * 0.04),

                  // Score card
                  _ScoreCard(score: widget.score, tierColor: _tierColor)
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 600.ms,
                        delay: 200.ms,
                        curve: Curves.elasticOut,
                      )
                      .fade(delay: 200.ms, duration: 400.ms),

                  SizedBox(height: size.height * 0.03),

                  // Reward card
                  _RewardCard(
                    emoji: _rewardEmoji,
                    title: widget.reward,
                    loyaltyPoints: widget.loyaltyPoints,
                    tierColor: _tierColor,
                  )
                      .animate()
                      .slideY(begin: 0.3, duration: 500.ms, delay: 500.ms)
                      .fade(delay: 500.ms, duration: 400.ms),

                  SizedBox(height: size.height * 0.02),

                  // Stats row
                  _StatsRow(
                    totalGames: stats.totalGames,
                    bestScore: stats.bestScore,
                    loyaltyPoints: stats.loyaltyPoints,
                  )
                      .animate()
                      .slideY(begin: 0.3, duration: 500.ms, delay: 700.ms)
                      .fade(delay: 700.ms, duration: 400.ms),

                  SizedBox(height: size.height * 0.04),

                  // Play again
                  AnimatedButton(
                    label: AppStrings.playAgain,
                    icon: HugeIcons.strokeRoundedReload,
                    width: double.infinity,
                    gradient: AppColors.primaryGradient,
                    onTap: () => context.pushReplacement(AppRoutes.game),
                  )
                      .animate()
                      .slideY(begin: 0.3, duration: 400.ms, delay: 800.ms)
                      .fade(delay: 800.ms, duration: 400.ms),

                  SizedBox(height: size.height * 0.015),

                  Row(
                    children: [
                      Expanded(
                        child: _OutlineButton(
                          label: AppStrings.viewRewards,
                          icon: HugeIcons.strokeRoundedGiftCard,
                          onTap: () => context.go(AppRoutes.wallet),
                        ),
                      ),
                      SizedBox(width: size.width * 0.031),
                      Expanded(
                        child: _OutlineButton(
                          label: AppStrings.goHome,
                          icon: HugeIcons.strokeRoundedHome01,
                          onTap: () => context.go(AppRoutes.home),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .slideY(begin: 0.3, duration: 400.ms, delay: 900.ms)
                      .fade(delay: 900.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  final int score;
  final Color tierColor;

  const _ScoreCard({required this.score, required this.tierColor});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.072),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(size.width * 0.062),
        border: Border.all(color: tierColor.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppStrings.yourScore,
            style: AppTextStyles.label(context,
                color: AppColors.textMuted, letterSpacing: 2),
          ),
          SizedBox(height: size.height * 0.01),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [tierColor, Colors.white],
            ).createShader(bounds),
            child: Text(
              Helpers.formatScore(score),
              style: AppTextStyles.scoreHero(context, color: Colors.white),
            ),
          ),
          SizedBox(height: size.height * 0.01),
          _ScoreTierLabel(score: score, color: tierColor),
        ],
      ),
    );
  }
}

class _ScoreTierLabel extends StatelessWidget {
  final int score;
  final Color color;

  const _ScoreTierLabel({required this.score, required this.color});

  String get _tier {
    if (score >= GameConstants.rewardTier5Score) return '🔥 LEGENDARY';
    if (score >= GameConstants.rewardTier4Score) return '⚡ EPIC';
    if (score >= GameConstants.rewardTier3Score) return '✨ GREAT';
    if (score >= GameConstants.rewardTier2Score) return '👍 GOOD';
    return '💪 KEEP TRYING';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.041,
        vertical: size.height * 0.0075,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size.width * 0.051),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _tier,
        style: AppTextStyles.label(context, color: color, letterSpacing: 2),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String emoji;
  final String title;
  final int loyaltyPoints;
  final Color tierColor;

  const _RewardCard({
    required this.emoji,
    required this.title,
    required this.loyaltyPoints,
    required this.tierColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.051),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tierColor.withValues(alpha: 0.2),
            AppColors.cardBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(size.width * 0.051),
        border: Border.all(color: tierColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: size.width * 0.124)),
          SizedBox(width: size.width * 0.041),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.rewardEarned,
                  style: AppTextStyles.label(context, color: AppColors.textMuted),
                ),
                SizedBox(height: size.height * 0.0025),
                Text(
                  title,
                  style: AppTextStyles.titleMedium(context, color: tierColor),
                ),
                Text(
                  '+$loyaltyPoints loyalty pts',
                  style: AppTextStyles.bodySmall(context, color: AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int totalGames;
  final int bestScore;
  final int loyaltyPoints;

  const _StatsRow({
    required this.totalGames,
    required this.bestScore,
    required this.loyaltyPoints,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Row(
      children: [
        _StatChip(label: 'Games', value: '$totalGames', icon: '🎮'),
        SizedBox(width: size.width * 0.021),
        _StatChip(label: 'Best', value: Helpers.formatScore(bestScore), icon: '🏆'),
        SizedBox(width: size.width * 0.021),
        _StatChip(label: 'Points', value: '$loyaltyPoints', icon: '⭐'),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatChip({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(size.width * 0.036),
          border: Border.all(color: AppColors.surfaceColor),
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: size.width * 0.051)),
            SizedBox(height: size.height * 0.005),
            Text(
              value,
              style: AppTextStyles.body(context, color: AppColors.textPrimary),
            ),
            Text(
              label,
              style: AppTextStyles.tiny(context, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size.height * 0.068,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(size.width * 0.036),
          border: Border.all(color: AppColors.surfaceColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: size.width * 0.046),
            SizedBox(width: size.width * 0.015),
            Text(
              label,
              style: AppTextStyles.bodySmall(context, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
