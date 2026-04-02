import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralised gaming typography system.
///
/// Two fonts:
///   • Orbitron  — futuristic display / titles / score numbers
///   • Rajdhani  — semi-condensed body / labels / descriptions
///
/// All sizes are proportional to [MediaQuery.sizeOf(context).width] so the
/// visual scale is identical across every screen size and density.
///
/// Usage:
///   Text('FOOD MATCH', style: AppTextStyles.display(context))
///   Text('Hello', style: AppTextStyles.body(context, color: AppColors.textMuted))
abstract class AppTextStyles {
  AppTextStyles._();

  // ─── Scale reference ──────────────────────────────────────────────────────
  //  scoreHero   → 0.160  Orbitron  w900   giant score card number
  //  display     → 0.082  Orbitron  w900   main screen heading
  //  h1          → 0.072  Orbitron  w800   section / page title
  //  h2          → 0.058  Orbitron  w700   sub-section heading
  //  titleLarge  → 0.051  Rajdhani  w800   card titles, big CTA labels
  //  titleMedium → 0.046  Rajdhani  w700   HUD values, button labels
  //  titleSmall  → 0.042  Rajdhani  w700   prominent secondary labels
  //  bodyLarge   → 0.038  Rajdhani  w500   descriptions / subtitles
  //  body        → 0.034  Rajdhani  w500   general body copy
  //  bodySmall   → 0.031  Rajdhani  w400   secondary body, HUD labels
  //  label       → 0.031  Rajdhani  w700   uppercase spaced labels
  //  labelSmall  → 0.028  Rajdhani  w600   small uppercase labels
  //  caption     → 0.028  Rajdhani  w400   muted captions / hints
  //  tiny        → 0.026  Rajdhani  w400   micro labels (HUD)
  //  badge       → 0.024  Rajdhani  w700   badge / chip text
  // ─────────────────────────────────────────────────────────────────────────

  // ── Display ──────────────────────────────────────────────────────────────

  /// Giant score number — Orbitron w900 ~16 % width.
  static TextStyle scoreHero(
    BuildContext context, {
    Color? color,
    double? letterSpacing,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.orbitron(
      fontSize: w * 0.160,
      fontWeight: FontWeight.w900,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing ?? -1,
      height: 1.0,
    );
  }

  /// Main screen heading — Orbitron w900 ~8 % width.
  static TextStyle display(
    BuildContext context, {
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.orbitron(
      fontSize: w * 0.082,
      fontWeight: FontWeight.w900,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing ?? -0.5,
      height: height ?? 1.1,
    );
  }

  /// Page / section title — Orbitron w800 ~7.2 % width.
  static TextStyle h1(
    BuildContext context, {
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.orbitron(
      fontSize: w * 0.072,
      fontWeight: FontWeight.w800,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing ?? -0.3,
      height: height ?? 1.15,
    );
  }

  /// Sub-section heading — Orbitron w700 ~5.8 % width.
  static TextStyle h2(
    BuildContext context, {
    Color? color,
    double? letterSpacing,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.orbitron(
      fontSize: w * 0.058,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing ?? 0,
      height: 1.2,
    );
  }

  // ── Titles ────────────────────────────────────────────────────────────────

  /// Card title / big CTA label — Rajdhani w800 ~5.1 % width.
  static TextStyle titleLarge(
    BuildContext context, {
    Color? color,
    double? letterSpacing,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.rajdhani(
      fontSize: w * 0.051,
      fontWeight: FontWeight.w800,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing ?? 0.5,
      height: 1.2,
    );
  }

  /// HUD values / primary button label — Rajdhani w700 ~4.6 % width.
  static TextStyle titleMedium(
    BuildContext context, {
    Color? color,
    double? letterSpacing,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.rajdhani(
      fontSize: w * 0.046,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing ?? 0.3,
      height: 1.2,
    );
  }

  /// Prominent secondary label — Rajdhani w700 ~4.2 % width.
  static TextStyle titleSmall(
    BuildContext context, {
    Color? color,
    double? letterSpacing,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.rajdhani(
      fontSize: w * 0.042,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing ?? 0.3,
      height: 1.2,
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  /// Description / subtitle — Rajdhani w500 ~3.8 % width.
  static TextStyle bodyLarge(
    BuildContext context, {
    Color? color,
    double? height,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.rajdhani(
      fontSize: w * 0.038,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.textSecondary,
      height: height ?? 1.5,
    );
  }

  /// General body text — Rajdhani w500 ~3.4 % width.
  static TextStyle body(
    BuildContext context, {
    Color? color,
    double? height,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.rajdhani(
      fontSize: w * 0.034,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.textSecondary,
      height: height ?? 1.5,
    );
  }

  /// Secondary body — Rajdhani w400 ~3.1 % width.
  static TextStyle bodySmall(
    BuildContext context, {
    Color? color,
    double? height,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.rajdhani(
      fontSize: w * 0.031,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.textMuted,
      height: height ?? 1.4,
    );
  }

  // ── Labels ────────────────────────────────────────────────────────────────

  /// Uppercase spaced label — Rajdhani w700 ~3.1 % width, ls 1.5.
  static TextStyle label(
    BuildContext context, {
    Color? color,
    double? letterSpacing,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.rajdhani(
      fontSize: w * 0.031,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.textSecondary,
      letterSpacing: letterSpacing ?? 1.5,
      height: 1.2,
    );
  }

  /// Small uppercase label — Rajdhani w600 ~2.8 % width, ls 1.
  static TextStyle labelSmall(
    BuildContext context, {
    Color? color,
    double? letterSpacing,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.rajdhani(
      fontSize: w * 0.028,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.textSecondary,
      letterSpacing: letterSpacing ?? 1.0,
      height: 1.2,
    );
  }

  /// Muted caption / hint — Rajdhani w400 ~2.8 % width.
  static TextStyle caption(
    BuildContext context, {
    Color? color,
    double? height,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.rajdhani(
      fontSize: w * 0.028,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.textMuted,
      height: height ?? 1.4,
    );
  }

  /// Micro label — Rajdhani w400 ~2.6 % width, ls 1.
  static TextStyle tiny(
    BuildContext context, {
    Color? color,
    double? letterSpacing,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.rajdhani(
      fontSize: w * 0.026,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.textMuted,
      letterSpacing: letterSpacing ?? 1.0,
      height: 1.2,
    );
  }

  /// Badge / chip text — Rajdhani w700 ~2.4 % width, ls 2.
  static TextStyle badge(
    BuildContext context, {
    Color? color,
    double? letterSpacing,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    return GoogleFonts.rajdhani(
      fontSize: w * 0.024,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing ?? 2.0,
      height: 1.2,
    );
  }
}
