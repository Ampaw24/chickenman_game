import 'package:flutter/material.dart';

// Chickenman brand palette — red · white · flame gold
abstract class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary     = Color(0xFFE8192C); // Chickenman red
  static const Color primaryDark = Color(0xFFC0141F); // deep red
  static const Color primaryLight = Color(0xFFFF3346); // bright red
  static const Color secondary   = Color(0xFFFFD000); // flame gold
  static const Color accent      = Color(0xFFFF6B6B); // soft coral red

  // ── Backgrounds (modern dark) ──────────────────────────────────────────────
  static const Color backgroundDark  = Color(0xFF0A0A0F); // near-black
  static const Color backgroundMid   = Color(0xFF111118); // dark slate
  static const Color backgroundLight = Color(0xFF1A1A25); // deep navy-dark
  static const Color cardBackground  = Color(0xFF1E1E2C); // dark card
  static const Color surfaceColor    = Color(0xFF2A2A3A); // elevated surface

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF); // pure white
  static const Color textSecondary = Color(0xFFB0B0C8); // soft lavender-white
  static const Color textMuted     = Color(0xFF6B6B85); // muted slate

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFD000);
  static const Color error   = Color(0xFFE8192C);
  static const Color info    = Color(0xFFFF6B6B);

  // ── Tile colors ────────────────────────────────────────────────────────────
  static const Color burgerTile = Color(0xFFE8192C); // brand red
  static const Color friesTile  = Color(0xFFFFD000); // flame gold
  static const Color drinkTile  = Color(0xFF4FC3F7); // cool blue contrast
  static const Color wingsTile  = Color(0xFFFF7043); // warm orange
  static const Color sauceTile  = Color(0xFFC62828); // deep crimson

  // ── Tile effects ───────────────────────────────────────────────────────────
  static const Color tileSelected  = Color(0xFFFFFFFF);
  static const Color tileMatchGlow = Color(0xFFFFD000);
  static const Color tileComboGlow = Color(0xFFE8192C);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDark, backgroundMid, backgroundLight],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8192C), Color(0xFFFF3346)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD000), Color(0xFFFFB300)],
  );

  // Combo gradient — deep red fire
  static const LinearGradient comboGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8192C), Color(0xFF8B0000)],
  );

  // ── Reward tier colours ────────────────────────────────────────────────────
  static const Color rewardBronze   = Color(0xFFCD7F32);
  static const Color rewardSilver   = Color(0xFFC0C0C0);
  static const Color rewardGold     = Color(0xFFFFD000);
  static const Color rewardPlatinum = Color(0xFFE8192C);
  static const Color rewardDiamond  = Color(0xFFFF6B6B);
}
