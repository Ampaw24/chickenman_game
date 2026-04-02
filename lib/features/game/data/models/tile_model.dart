import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum FoodType { burger, fries, drink, wings, sauce }

extension FoodTypeExt on FoodType {
  String get emoji {
    switch (this) {
      case FoodType.burger:
        return '🍔';
      case FoodType.fries:
        return '🍟';
      case FoodType.drink:
        return '🥤';
      case FoodType.wings:
        return '🍗';
      case FoodType.sauce:
        return '🫙';
    }
  }

  Color get color {
    switch (this) {
      case FoodType.burger:
        return const Color(0xFFFF6B35);
      case FoodType.fries:
        return const Color(0xFFFFD700);
      case FoodType.drink:
        return const Color(0xFF4FC3F7);
      case FoodType.wings:
        return const Color(0xFFFF7043);
      case FoodType.sauce:
        return const Color(0xFFEF5350);
    }
  }

  Color get glowColor {
    return color.withValues(alpha: 0.6);
  }

  String get name {
    switch (this) {
      case FoodType.burger:
        return 'Burger';
      case FoodType.fries:
        return 'Fries';
      case FoodType.drink:
        return 'Drink';
      case FoodType.wings:
        return 'Wings';
      case FoodType.sauce:
        return 'Sauce';
    }
  }
}

enum TileState { idle, selected, matched, falling, new_ }

class TileModel extends Equatable {
  final int row;
  final int col;
  final FoodType type;
  final TileState state;
  final String id;

  const TileModel({
    required this.row,
    required this.col,
    required this.type,
    this.state = TileState.idle,
    required this.id,
  });

  TileModel copyWith({
    int? row,
    int? col,
    FoodType? type,
    TileState? state,
    String? id,
  }) {
    return TileModel(
      row: row ?? this.row,
      col: col ?? this.col,
      type: type ?? this.type,
      state: state ?? this.state,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [row, col, type, state, id];
}
