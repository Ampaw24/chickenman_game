import 'package:uuid/uuid.dart';
import '../data/models/voucher_model.dart';
import '../../../core/constants/game_constants.dart';

class RewardResult {
  final VoucherType type;
  final String title;
  final String description;
  final String emoji;
  final int loyaltyPoints;
  final bool isVoucher;

  const RewardResult({
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.loyaltyPoints,
    required this.isVoucher,
  });
}

class RewardEngine {
  static const _uuid = Uuid();

  /// Determine reward based on score.
  static RewardResult evaluate(int score) {
    if (score >= GameConstants.rewardTier5Score) {
      return RewardResult(
        type: VoucherType.freeBurger,
        title: 'FREE BURGER! 🎉',
        description: 'Incredible! You\'ve earned a free burger!',
        emoji: '🍔',
        loyaltyPoints: 50,
        isVoucher: true,
      );
    } else if (score >= GameConstants.rewardTier4Score) {
      return RewardResult(
        type: VoucherType.freeFries,
        title: 'FREE FRIES!',
        description: 'Amazing! Enjoy free fries on us!',
        emoji: '🍟',
        loyaltyPoints: 30,
        isVoucher: true,
      );
    } else if (score >= GameConstants.rewardTier3Score) {
      return RewardResult(
        type: VoucherType.freeDrink,
        title: 'FREE DRINK!',
        description: 'Great score! Grab a free drink!',
        emoji: '🥤',
        loyaltyPoints: 20,
        isVoucher: true,
      );
    } else if (score >= GameConstants.rewardTier2Score) {
      return RewardResult(
        type: VoucherType.discount5,
        title: '5% DISCOUNT',
        description: 'Nice! Enjoy 5% off your next order.',
        emoji: '🏷️',
        loyaltyPoints: 10,
        isVoucher: true,
      );
    } else {
      return RewardResult(
        type: VoucherType.loyaltyPoints,
        title: '+10 LOYALTY POINTS',
        description: 'Keep playing to unlock better rewards!',
        emoji: '⭐',
        loyaltyPoints: 10,
        isVoucher: false,
      );
    }
  }

  /// Build a VoucherModel from a reward result.
  static VoucherModel buildVoucher(RewardResult result, int score) {
    return VoucherModel(
      id: _uuid.v4(),
      type: result.type,
      createdAt: DateTime.now(),
      scoreEarned: score,
    );
  }
}
