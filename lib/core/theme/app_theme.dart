import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reading themes available inside the Reader screen (independent from app theme).
enum ReadingTheme { dark, sepia, light }

class AppTheme {
  AppTheme._();

  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 24;

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        surfaceElevated: AppColors.darkSurfaceElevated,
        border: AppColors.darkBorder,
        textPrimary: AppColors.darkTextPrimary,
        textSecondary: AppColors.darkTextSecondary,
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        surfaceElevated: AppColors.lightSurfaceElevated,
        border: AppColors.lightBorder,
        textPrimary: AppColors.lightTextPrimary,
        textSecondary: AppColors.lightTextSecondary,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceElevated,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.accent,
      onPrimary: const Color(0xFF04201E),
      secondary: AppColors.accentDim,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: 'Roboto',
      textTheme: _textTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.accent.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.accent : textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.accent : textSecondary,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.accent.withValues(alpha: 0.18),
        selectedIconTheme: const IconThemeData(color: AppColors.accent),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(color: textSecondary, fontSize: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Color(0xFF04201E),
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: const Color(0xFF04201E),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accent),
      ),
      iconTheme: IconThemeData(color: textPrimary),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: border,
        thumbColor: AppColors.accent,
        overlayColor: AppColors.accent.withValues(alpha: 0.15),
        valueIndicatorColor: AppColors.accent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        selectedColor: AppColors.accent.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: textPrimary, fontSize: 13),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: TextStyle(color: textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      extensions: [
        AppSurfaceColors(
          background: background,
          surface: surface,
          surfaceElevated: surfaceElevated,
          border: border,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
      ],
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displaySmall: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 32),
      headlineMedium: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 24),
      headlineSmall: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 20),
      titleLarge: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 16),
      titleSmall: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 14),
      bodyLarge: TextStyle(color: primary, fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(color: primary, fontSize: 14, height: 1.5),
      bodySmall: TextStyle(color: secondary, fontSize: 12, height: 1.4),
      labelLarge: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }
}

/// Extra semantic colors not covered by [ColorScheme], accessible via
/// `Theme.of(context).extension<AppSurfaceColors>()`.
class AppSurfaceColors extends ThemeExtension<AppSurfaceColors> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  const AppSurfaceColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  AppSurfaceColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return AppSurfaceColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  AppSurfaceColors lerp(ThemeExtension<AppSurfaceColors>? other, double t) {
    if (other is! AppSurfaceColors) return this;
    return AppSurfaceColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}
