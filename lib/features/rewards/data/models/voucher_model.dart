import 'package:equatable/equatable.dart';
import '../../../../core/constants/game_constants.dart';

enum VoucherStatus { active, redeemed, expired }

enum VoucherType { loyaltyPoints, discount5, freeDrink, freeFries, freeBurger }

extension VoucherTypeExt on VoucherType {
  String get title {
    switch (this) {
      case VoucherType.loyaltyPoints:
        return '+10 Loyalty Points';
      case VoucherType.discount5:
        return '5% Discount';
      case VoucherType.freeDrink:
        return 'Free Drink';
      case VoucherType.freeFries:
        return 'Free Fries';
      case VoucherType.freeBurger:
        return 'Free Burger';
    }
  }

  String get emoji {
    switch (this) {
      case VoucherType.loyaltyPoints:
        return '⭐';
      case VoucherType.discount5:
        return '🏷️';
      case VoucherType.freeDrink:
        return '🥤';
      case VoucherType.freeFries:
        return '🍟';
      case VoucherType.freeBurger:
        return '🍔';
    }
  }

  String get description {
    switch (this) {
      case VoucherType.loyaltyPoints:
        return 'Added to your loyalty balance';
      case VoucherType.discount5:
        return 'Get 5% off your next order';
      case VoucherType.freeDrink:
        return 'Redeem a free drink on your next visit';
      case VoucherType.freeFries:
        return 'Redeem free fries on your next visit';
      case VoucherType.freeBurger:
        return 'Rare reward! Free burger on your next visit';
    }
  }
}

class VoucherModel extends Equatable {
  final String id;
  final VoucherType type;
  final VoucherStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int scoreEarned;

  VoucherModel({
    required this.id,
    required this.type,
    this.status = VoucherStatus.active,
    required this.createdAt,
    required this.scoreEarned,
  }) : expiresAt = createdAt.add(
          const Duration(days: GameConstants.voucherExpiryDays),
        );

  VoucherModel copyWith({VoucherStatus? status}) {
    return VoucherModel(
      id: id,
      type: type,
      status: status ?? this.status,
      createdAt: createdAt,
      scoreEarned: scoreEarned,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => status == VoucherStatus.active && !isExpired;

  VoucherStatus get effectiveStatus {
    if (status == VoucherStatus.redeemed) return VoucherStatus.redeemed;
    if (isExpired) return VoucherStatus.expired;
    return VoucherStatus.active;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.index,
        'status': status.index,
        'createdAt': createdAt.toIso8601String(),
        'scoreEarned': scoreEarned,
      };

  factory VoucherModel.fromMap(Map<String, dynamic> map) => VoucherModel(
        id: map['id'] as String,
        type: VoucherType.values[_parseIntField(map['type'])],
        status: VoucherStatus.values[_parseIntField(map['status'])],
        createdAt: DateTime.parse(map['createdAt'] as String),
        scoreEarned: _parseIntField(map['scoreEarned']),
      );

  static int _parseIntField(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props => [id, type, status, createdAt];
}
