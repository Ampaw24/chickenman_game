import 'dart:math';
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

// Randomly generated gaming names
const _randomNames = [
  'CrispyKing', 'FlameMaster', 'GoldenFry', 'SauceLord',
  'DrumstickX', 'SpicyAce', 'WingCommander', 'BurgerBoss',
  'ChickenKnight', 'GrillPhantom', 'SauceWizard', 'HotStreak',
  'ZestyViper', 'CrunchFury', 'TenderBlaze', 'Crispinator',
];

class NicknameScreen extends ConsumerStatefulWidget {
  const NicknameScreen({super.key});

  @override
  ConsumerState<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends ConsumerState<NicknameScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canContinue => _controller.text.trim().length >= 3;

  void _randomise() {
    HapticFeedback.lightImpact();
    final name = _randomNames[_rand.nextInt(_randomNames.length)];
    _controller.text = name;
    _controller.selection = TextSelection.collapsed(offset: name.length);
  }

  void _continue() {
    if (!_canContinue) return;
    HapticFeedback.mediumImpact();
    ref.read(onboardingProvider.notifier).setNickname(_controller.text);
    context.push(AppRoutes.avatar);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: GradientBackground(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.02),

                  // ── Top bar ─────────────────────────────────────────────
                  Row(
                    children: [
                      _BackButton(),
                      const Spacer(),
                      _StepIndicator(current: 1, total: 2),
                    ],
                  ).animate().fade(duration: 350.ms),

                  SizedBox(height: size.height * 0.05),

                  // ── Heading ─────────────────────────────────────────────
                  Text(
                    'What\'s your\nplayer name?',
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

                  SizedBox(height: size.height * 0.012),

                  Text(
                    'This is how other players will see you\nin the leaderboard.',
                    style: AppTextStyles.bodyLarge(
                      context,
                      color: AppColors.textSecondary,
                    ),
                  )
                      .animate()
                      .fade(delay: 250.ms, duration: 400.ms),

                  SizedBox(height: size.height * 0.05),

                  // ── Input field ─────────────────────────────────────────
                  _NicknameField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onRandomise: _randomise,
                  )
                      .animate()
                      .slideY(
                        begin: 0.3,
                        duration: 500.ms,
                        delay: 350.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .fade(delay: 350.ms, duration: 400.ms),

                  SizedBox(height: size.height * 0.018),

                  // ── Char count hint ─────────────────────────────────────
                  AnimatedOpacity(
                    duration: 250.ms,
                    opacity: _controller.text.isNotEmpty ? 1.0 : 0.0,
                    child: Row(
                      children: [
                        Icon(
                          _canContinue
                              ? HugeIcons.strokeRoundedCheckmarkCircle01
                              : HugeIcons.strokeRoundedAlertCircle,
                          color: _canContinue
                              ? AppColors.success
                              : AppColors.textMuted,
                          size: size.width * 0.038,
                        ),
                        SizedBox(width: size.width * 0.018),
                        Text(
                          _canContinue
                              ? 'Looks great!'
                              : 'Minimum 3 characters required',
                          style: AppTextStyles.bodySmall(
                            context,
                            color: _canContinue
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_controller.text.trim().length}/20',
                          style: AppTextStyles.bodySmall(
                            context,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Continue button ─────────────────────────────────────
                  _ContinueButton(
                    enabled: _canContinue,
                    onTap: _continue,
                  )
                      .animate()
                      .slideY(
                        begin: 0.5,
                        duration: 500.ms,
                        delay: 500.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .fade(delay: 500.ms, duration: 400.ms),

                  SizedBox(height: size.height * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nickname Input Field ───────────────────────────────────────────────────────

class _NicknameField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onRandomise;

  const _NicknameField({
    required this.controller,
    required this.focusNode,
    required this.onRandomise,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(size.width * 0.041),
        border: Border.all(
          color: focusNode.hasFocus
              ? AppColors.primary.withValues(alpha: 0.6)
              : AppColors.surfaceColor,
          width: 1.5,
        ),
        boxShadow: focusNode.hasFocus
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(width: size.width * 0.041),
          Icon(
            HugeIcons.strokeRoundedUser,
            color: AppColors.textMuted,
            size: size.width * 0.051,
          ),
          SizedBox(width: size.width * 0.028),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLength: 20,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z0-9_\-]')),
              ],
              style: AppTextStyles.titleMedium(
                context,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: 'EnterYourName',
                hintStyle: AppTextStyles.titleMedium(
                  context,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.symmetric(
                  vertical: size.height * 0.022,
                ),
              ),
            ),
          ),
          // Random dice button
          GestureDetector(
            onTap: onRandomise,
            child: Container(
              margin: EdgeInsets.all(size.width * 0.022),
              padding: EdgeInsets.all(size.width * 0.022),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(size.width * 0.026),
              ),
              child: Icon(
                HugeIcons.strokeRoundedDice,
                color: AppColors.secondary,
                size: size.width * 0.046,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Continue Button ────────────────────────────────────────────────────────────

class _ContinueButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _ContinueButton({required this.enabled, required this.onTap});

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton>
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
              Text(
                'NEXT',
                style: AppTextStyles.titleLarge(
                  context,
                  color: widget.enabled ? Colors.white : AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(width: size.width * 0.028),
              Icon(
                HugeIcons.strokeRoundedArrowRight01,
                color: widget.enabled ? Colors.white : AppColors.textMuted,
                size: size.width * 0.051,
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
