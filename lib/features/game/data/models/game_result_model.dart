import 'package:equatable/equatable.dart';

class GameResultModel extends Equatable {
  final int score;
  final int timeBonus;
  final int totalScore;
  final String rewardTitle;
  final String rewardDescription;
  final int loyaltyPoints;
  final bool hasVoucher;
  final DateTime playedAt;

  const GameResultModel({
    required this.score,
    this.timeBonus = 0,
    required this.totalScore,
    required this.rewardTitle,
    required this.rewardDescription,
    required this.loyaltyPoints,
    required this.hasVoucher,
    required this.playedAt,
  });

  @override
  List<Object?> get props => [score, totalScore, rewardTitle, playedAt];
}
