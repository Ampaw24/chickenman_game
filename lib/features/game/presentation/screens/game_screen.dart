import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';
import '../../../../core/services/audio_service.dart';
import '../components/game_board.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../app/router.dart';
import '../../../rewards/domain/reward_engine.dart';
import '../../../rewards/presentation/providers/reward_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only watch `status` here — it changes on game start/over, not every tick.
    final gameStatus = ref.watch(gameProvider.select((s) => s.status));
    final size = MediaQuery.sizeOf(context);

    // Listen for game-over without triggering a rebuild on every state change.
    ref.listen<bool>(
      gameProvider.select((s) => s.isGameOver),
      (prev, isOver) {
        if (isOver && prev != true) {
          final score = ref.read(gameProvider).score;
          _onGameOver(score);
        }
      },
    );

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // ── HUD ───────────────────────────────────────────────────
              // _GameHUD watches only its own fields via select — no param needed.
              const _GameHUD(),

              SizedBox(height: size.height * 0.015),

              // ── Board ─────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.031),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: gameStatus == GameStatus.idle
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            : const GameBoard(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom tip ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.all(size.width * 0.031),
                child: Text(
                  AppStrings.swapTiles,
                  style: AppTextStyles.bodySmall(context, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onGameOver(int score) {
    final reward = RewardEngine.evaluate(score);

    ref.read(playerStatsProvider.notifier).recordGame(score);
    ref.read(playerStatsProvider.notifier).addLoyaltyPoints(reward.loyaltyPoints);

    if (reward.isVoucher) {
      final voucher = RewardEngine.buildVoucher(reward, score);
      ref.read(voucherProvider.notifier).addVoucher(voucher);
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        context.pushReplacement(AppRoutes.result, extra: {
          'score': score,
          'reward': reward.title,
          'loyaltyPoints': reward.loyaltyPoints,
        });
      }
    });
  }
}

// ─── HUD ──────────────────────────────────────────────────────────────────────

class _GameHUD extends ConsumerWidget {
  const _GameHUD();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final avatarIndex = ref.watch(onboardingProvider.select((s) => s.selectedAvatarIndex));
    final nickname = ref.watch(onboardingProvider.select((s) => s.nickname.isNotEmpty ? s.nickname : 'Player'));
    final avatarPath = avatarIndex >= 0 && avatarIndex < kAvatarOptions.length
        ? kAvatarOptions[avatarIndex].assetPath
        : null;

    // Watch only the three values the HUD needs — the avatar/nickname row never
    // rebuilds due to a timer tick, and score/combo rebuild only when they change.
    final score = ref.watch(gameProvider.select((s) => s.score));
    final timeLeft = ref.watch(gameProvider.select((s) => s.timeLeft));
    final comboCount = ref.watch(gameProvider.select((s) => s.comboCount));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.041,
        size.height * 0.01,
        size.width * 0.041,
        0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Row 1: Back + Player info + Mute ──────────────────────────
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => context.pop(),
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

              // Player avatar + name
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.031,
                    vertical: size.height * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(size.width * 0.031),
                    border: Border.all(color: AppColors.surfaceColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar circle
                      ClipRRect(
                        borderRadius: BorderRadius.circular(size.width * 0.05),
                        child: avatarPath != null
                            ? Image.asset(
                                avatarPath,
                                width: size.width * 0.08,
                                height: size.width * 0.08,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: size.width * 0.08,
                                height: size.width * 0.08,
                                color: AppColors.primary.withValues(alpha: 0.3),
                                child: Icon(
                                  HugeIcons.strokeRoundedUser,
                                  color: AppColors.primary,
                                  size: size.width * 0.046,
                                ),
                              ),
                      ),
                      SizedBox(width: size.width * 0.021),
                      Flexible(
                        child: Text(
                          nickname,
                          style: AppTextStyles.bodySmall(
                            context,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: size.width * 0.021),

              // Mute button
              const _MuteButton(),
            ],
          ),

          SizedBox(height: size.height * 0.01),

          // ── Row 2: Score + Timer + Combo ───────────────────────────────
          Row(
            children: [
              // Score
              Expanded(
                child: _HUDCard(
                  label: AppStrings.score,
                  value: Helpers.formatScore(score),
                  color: AppColors.secondary,
                ),
              ),

              SizedBox(width: size.width * 0.021),

              // Timer
              Expanded(
                child: _TimerCard(timeLeft: timeLeft),
              ),

              SizedBox(width: size.width * 0.021),

              // Combo count
              Expanded(
                child: _HUDCard(
                  label: AppStrings.combo,
                  value: '×$comboCount',
                  color: AppColors.tileComboGlow,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: -0.3, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

class _HUDCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HUDCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.021,
        vertical: size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(size.width * 0.031),
        border: Border.all(color: AppColors.surfaceColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.tiny(context, color: AppColors.textMuted),
          ),
          Text(
            value,
            style: AppTextStyles.titleMedium(context, color: color),
          ),
        ],
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  final int timeLeft;

  const _TimerCard({required this.timeLeft});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isUrgent = timeLeft <= 10;
    final color = isUrgent ? AppColors.error : AppColors.accent;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.021,
        vertical: size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(size.width * 0.031),
        border: Border.all(
          color: isUrgent
              ? AppColors.error.withValues(alpha: 0.6)
              : AppColors.surfaceColor,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.timeLeft,
            style: AppTextStyles.tiny(context, color: AppColors.textMuted),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: isUrgent
                ? AppTextStyles.h2(context, color: color)
                : AppTextStyles.titleMedium(context, color: color),
            child: Text(Helpers.formatTimer(timeLeft)),
          ),
        ],
      ),
    );
  }
}

// ─── Mute Button ──────────────────────────────────────────────────────────────

class _MuteButton extends StatefulWidget {
  const _MuteButton();

  @override
  State<_MuteButton> createState() => _MuteButtonState();
}

class _MuteButtonState extends State<_MuteButton> {
  bool _muted = false;

  void _toggle() {
    AudioService.instance.toggleMute();
    setState(() => _muted = AudioService.instance.isMuted);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.021),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(size.width * 0.031),
        ),
        child: Icon(
          _muted
              ? HugeIcons.strokeRoundedVolumeOff
              : HugeIcons.strokeRoundedVolumeHigh,
          color: AppColors.textSecondary,
          size: size.width * 0.046,
        ),
      ),
    );
  }
}
