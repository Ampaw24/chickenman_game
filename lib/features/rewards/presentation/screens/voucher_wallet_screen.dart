import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/helpers.dart';
import '../../data/models/voucher_model.dart';
import '../providers/reward_provider.dart';

class VoucherWalletScreen extends ConsumerWidget {
  const VoucherWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vouchers = ref.watch(voucherProvider);
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
          child: Column(
            children: [
              // App bar
              Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.041,
                  size.height * 0.015,
                  size.width * 0.041,
                  0,
                ),
                child: Row(
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
                      AppStrings.voucherWallet,
                      style: AppTextStyles.h2(context, color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.031,
                        vertical: size.height * 0.0075,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(size.width * 0.051),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        '${vouchers.where((v) => v.isActive).length} active',
                        style: AppTextStyles.label(context, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(duration: 400.ms),

              SizedBox(height: size.height * 0.02),

              // List
              Expanded(
                child: vouchers.isEmpty
                    ? _EmptyState()
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.041,
                          vertical: size.height * 0.01,
                        ),
                        itemCount: vouchers.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: size.height * 0.015),
                        itemBuilder: (context, index) {
                          final voucher = vouchers[index];
                          return _VoucherCard(
                            voucher: voucher,
                            onRedeem: voucher.isActive
                                ? () => ref
                                    .read(voucherProvider.notifier)
                                    .redeemVoucher(voucher.id)
                                : null,
                          )
                              .animate()
                              .slideX(
                                begin: 0.3,
                                duration: 400.ms,
                                delay: (index * 80).ms,
                              )
                              .fade(
                                delay: (index * 80).ms,
                                duration: 300.ms,
                              );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Voucher Card ─────────────────────────────────────────────────────────────

class _VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final VoidCallback? onRedeem;

  const _VoucherCard({required this.voucher, required this.onRedeem});

  Color get _statusColor {
    switch (voucher.effectiveStatus) {
      case VoucherStatus.active:
        return AppColors.success;
      case VoucherStatus.redeemed:
        return AppColors.textMuted;
      case VoucherStatus.expired:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isActive = voucher.isActive;
    final type = voucher.type;

    return Opacity(
      opacity: isActive ? 1.0 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(size.width * 0.051),
          border: Border.all(
            color: isActive
                ? _statusColor.withValues(alpha: 0.4)
                : AppColors.surfaceColor,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _statusColor.withValues(alpha: 0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Left emoji strip
            Container(
              width: size.width * 0.185,
              height: size.width * 0.226,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isActive
                      ? [
                          _statusColor.withValues(alpha: 0.2),
                          _statusColor.withValues(alpha: 0.05),
                        ]
                      : [
                          AppColors.surfaceColor,
                          AppColors.cardBackground,
                        ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size.width * 0.051),
                  bottomLeft: Radius.circular(size.width * 0.051),
                ),
              ),
              child: Center(
                child: Text(
                  type.emoji,
                  style: TextStyle(fontSize: size.width * 0.093),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.036),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.title,
                      style: AppTextStyles.titleSmall(context, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: size.height * 0.0025),
                    Text(
                      type.description,
                      style: AppTextStyles.caption(context, color: AppColors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: size.height * 0.0075),
                    Text(
                      Helpers.daysUntilExpiry(voucher.expiresAt),
                      style: AppTextStyles.labelSmall(context, color: _statusColor),
                    ),
                  ],
                ),
              ),
            ),

            // Redeem button / status badge
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.036),
              child: _StatusBadge(
                status: voucher.effectiveStatus,
                onRedeem: onRedeem,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final VoucherStatus status;
  final VoidCallback? onRedeem;

  const _StatusBadge({required this.status, required this.onRedeem});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    if (status == VoucherStatus.active && onRedeem != null) {
      return GestureDetector(
        onTap: onRedeem,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.031,
            vertical: size.height * 0.01,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(size.width * 0.031),
          ),
          child: Text(
            AppStrings.redeem,
            style: AppTextStyles.label(context, color: Colors.white)
                .copyWith(letterSpacing: 1),
          ),
        ),
      );
    }

    final label = status == VoucherStatus.redeemed
        ? AppStrings.redeemed
        : AppStrings.expired;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.026,
        vertical: size.height * 0.0075,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(size.width * 0.026),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(context, color: AppColors.textMuted),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🎟️', style: TextStyle(fontSize: size.width * 0.186))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1200.ms,
              ),
          SizedBox(height: size.height * 0.025),
          Text(
            AppStrings.noVouchers,
            style: AppTextStyles.titleSmall(context, color: AppColors.textMuted)
                .copyWith(height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
