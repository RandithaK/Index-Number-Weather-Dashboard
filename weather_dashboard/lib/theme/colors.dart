import 'package:flutter/material.dart';

// Centralized color tokens for the app. This makes it easier to tune colors
// to match the provided designs (light + dark) and keeps widget code small.
class AppColors {
  // Light theme
  static const Color lightScaffold = Color(0xFFFBF7FF); // soft lavender
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightAccent = Color(0xFF7C3AED); // primary purple
  static const Color lightAccentSoft = Color(0xFFDDD6FE); // muted purple
  static const Color lightInputFill = Color(0xFFECEAF6);

  // Dark theme
  static const Color darkScaffold = Color(0xFF11131A); // deep dark
  static const Color darkCard = Color(0xFF1F2937); // slate
  static const Color darkAccent = Color(0xFFC4B5FD); // light purple in dark mode
  static const Color darkMuted = Color(0xFF374151);

  // Accent tokens
  static const Color warningLight = Color(0xFFFDE68A);
  static const Color warningDark = Color(0xFFFBBF24);
}

// Small extension helpers used to avoid deprecated .withOpacity
extension AppColorHelpers on Color {
  /// Use integer alpha to avoid precision loss. Prefer this instead of
  /// `withOpacity` which is shown deprecating messages in analyzer.
  Color withOpacityF(double opacity) => withAlpha((opacity * 255).round());
}
