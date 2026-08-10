import 'package:flutter/material.dart';

/// Central color palette for EchoBook — dark charcoal base with a teal/cyan accent.
class AppColors {
  AppColors._();

  // Brand accent
  static const Color accent = Color(0xFF2DD4C8);
  static const Color accentDim = Color(0xFF1F9E96);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0F1416);
  static const Color darkSurface = Color(0xFF161D20);
  static const Color darkSurfaceElevated = Color(0xFF1D262A);
  static const Color darkBorder = Color(0xFF283135);
  static const Color darkTextPrimary = Color(0xFFF3F6F6);
  static const Color darkTextSecondary = Color(0xFF9AABAF);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF7F9F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF0F3F3);
  static const Color lightBorder = Color(0xFFE1E7E7);
  static const Color lightTextPrimary = Color(0xFF141A1B);
  static const Color lightTextSecondary = Color(0xFF5B6B6E);

  // Sepia reading theme
  static const Color sepiaBackground = Color(0xFFF4ECD8);
  static const Color sepiaSurface = Color(0xFFEFE4CB);
  static const Color sepiaText = Color(0xFF3A2E1F);

  static const Color error = Color(0xFFE56B6B);
  static const Color success = Color(0xFF4CBB8A);
  static const Color warning = Color(0xFFE0B155);
}
