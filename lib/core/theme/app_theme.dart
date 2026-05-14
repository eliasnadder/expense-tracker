import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Colour tokens
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  // Primary
  static const primary = Color(0xFF3525CD);
  static const primaryContainer = Color(0xFF4F46E5);
  static const onPrimaryContainer = Color(0xFFDAD7FF);

  // Secondary
  static const secondary = Color(0xFF712AE2);
  static const secondaryContainer = Color(0xFF8A4CFC);
  static const onSecondaryContainer = Color(0xFFFFFBFF);

  // Surface – light defaults (widgets that hardcode these stay light-aware)
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const surfaceContainer = Color(0xFFEDEEEF);
  static const surfaceContainerHigh = Color(0xFFE7E8E9);
  static const surfaceContainerHighest = Color(0xFFE1E3E4);

  // Content
  static const onBackground = Color(0xFF191C1D);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF464555);
  static const outline = Color(0xFF777587);
  static const outlineVariant = Color(0xFFC7C4D8);

  // Semantic
  static const income = Color(0xFF00505F);
  static const incomeContainer = Color(0xFF006A7C);
  static const expense = Color(0xFFBA1A1A);
  static const expenseContainer = Color(0xFFFFDAD6);
  static const warning = Color(0xFFF59E0B);

  // Aliases kept for backward-compat
  static Color get inversePrimary => primaryContainer;
  static Color get surfaceVariant => surfaceContainerHigh;
  static Color get tertiary => income;
  static Color get tertiaryContainer => incomeContainer;
  static Color get onTertiaryContainer => onSecondaryContainer;
}

// ─────────────────────────────────────────────────────────────────────────────
// Dark-mode colour tokens (used only inside darkTheme below)
// ─────────────────────────────────────────────────────────────────────────────

class _DarkColors {
  static const scaffold = Color(0xFF111318);
  static const surface = Color(0xFF111318);
  static const surfaceLowest = Color(0xFF1A1C23);
  static const surfaceLow = Color(0xFF1E2028);
  static const surfaceContainer = Color(0xFF23252D);
  static const surfaceHigh = Color(0xFF272931);
  static const surfaceHighest = Color(0xFF2C2E37);

  static const primary = Color(0xFFB8B0FF);
  static const primaryContainer = Color(0xFF3525CD);
  static const onPrimaryContainer = Color(0xFFDAD7FF);

  static const secondary = Color(0xFFD4AAFC);
  static const secondaryContainer = Color(0xFF5C1DB5);
  static const onSecondaryContainer = Color(0xFFF0DBFF);

  static const onSurface = Color(0xFFE2E2EC);
  static const onSurfaceVariant = Color(0xFFC7C5D9);
  static const outline = Color(0xFF918FA5);
  static const outlineVariant = Color(0xFF464455);

  static const income = Color(0xFF4DDAE8);
  static const expense = Color(0xFFFFB4AB);
  static const expenseContainer = Color(0xFF93000A);
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme builder
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  // ── shared font constant ─────────────────────────────────────────────────
  // pubspec.yaml declares: family: HankenGrotesk  (no space)
  static const _font = 'HankenGrotesk';

  // ── light text theme ─────────────────────────────────────────────────────
  static TextTheme get _lightTextTheme => _buildTextTheme(AppColors.onSurface);

  static TextTheme get _darkTextTheme => _buildTextTheme(_DarkColors.onSurface);

  static TextTheme _buildTextTheme(Color baseColor) => TextTheme(
    displayLarge: TextStyle(
      fontFamily: _font,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: baseColor,
    ),
    headlineLarge: TextStyle(
      fontFamily: _font,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: baseColor,
    ),
    titleLarge: TextStyle(
      fontFamily: _font,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: baseColor,
    ),
    titleMedium: TextStyle(
      fontFamily: _font,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: baseColor,
    ),
    bodyLarge: TextStyle(
      fontFamily: _font,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: baseColor.withValues(alpha: 0.8),
    ),
    bodyMedium: TextStyle(
      fontFamily: _font,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: baseColor.withValues(alpha: 0.8),
    ),
    labelLarge: TextStyle(
      fontFamily: _font,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: baseColor.withValues(alpha: 0.8),
    ),
    labelMedium: TextStyle(
      fontFamily: _font,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: baseColor.withValues(alpha: 0.7),
    ),
  );

  // ── LIGHT THEME ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: _font,
    scaffoldBackgroundColor: AppColors.surfaceContainerLow,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      surface: AppColors.surface,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      error: AppColors.expense,
      errorContainer: AppColors.expenseContainer,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      brightness: Brightness.light,
    ),
    textTheme: _lightTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _lightTextTheme.titleLarge,
      iconTheme: const IconThemeData(color: AppColors.onSurface),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceContainerLowest,
      indicatorColor: AppColors.secondaryContainer,
      height: 80,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _lightTextTheme.labelMedium!.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          );
        }
        return _lightTextTheme.labelMedium!.copyWith(
          color: AppColors.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.onSecondaryContainer);
        }
        return const IconThemeData(color: AppColors.onSurfaceVariant);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerHighest,
      border: const UnderlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: const UnderlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: _lightTextTheme.bodyMedium,
      hintStyle: _lightTextTheme.bodyMedium?.copyWith(color: AppColors.outline),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        textStyle: _lightTextTheme.labelLarge,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryContainer,
      foregroundColor: AppColors.onPrimaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      elevation: 2,
    ),
  );

  // ── DARK THEME ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: _font,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _DarkColors.scaffold,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: _DarkColors.primary,
      onPrimary: const Color(0xFF1B0090),
      primaryContainer: _DarkColors.primaryContainer,
      onPrimaryContainer: _DarkColors.onPrimaryContainer,
      secondary: _DarkColors.secondary,
      onSecondary: const Color(0xFF3D0075),
      secondaryContainer: _DarkColors.secondaryContainer,
      onSecondaryContainer: _DarkColors.onSecondaryContainer,
      tertiary: _DarkColors.income,
      onTertiary: const Color(0xFF003640),
      tertiaryContainer: const Color(0xFF004E5C),
      onTertiaryContainer: const Color(0xFF97F0FF),
      error: _DarkColors.expense,
      onError: const Color(0xFF690005),
      errorContainer: _DarkColors.expenseContainer,
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: _DarkColors.surface,
      onSurface: _DarkColors.onSurface,
      surfaceContainerLowest: _DarkColors.surfaceLowest,
      surfaceContainerLow: _DarkColors.surfaceLow,
      surfaceContainer: _DarkColors.surfaceContainer,
      surfaceContainerHigh: _DarkColors.surfaceHigh,
      surfaceContainerHighest: _DarkColors.surfaceHighest,
      onSurfaceVariant: _DarkColors.onSurfaceVariant,
      outline: _DarkColors.outline,
      outlineVariant: _DarkColors.outlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _DarkColors.onSurface,
      onInverseSurface: _DarkColors.surface,
      inversePrimary: AppColors.primary,
    ),
    textTheme: _darkTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: _DarkColors.surfaceLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _darkTextTheme.titleLarge,
      iconTheme: IconThemeData(color: _DarkColors.onSurface),
    ),
    cardTheme: CardThemeData(
      color: _DarkColors.surfaceLowest,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _DarkColors.surfaceLowest,
      indicatorColor: _DarkColors.secondaryContainer,
      height: 80,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final base = states.contains(WidgetState.selected)
            ? FontWeight.w600
            : FontWeight.normal;
        return TextStyle(
          fontFamily: _font,
          fontSize: 12,
          fontWeight: base,
          color: states.contains(WidgetState.selected)
              ? _DarkColors.onSurface
              : _DarkColors.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
              ? _DarkColors.onSecondaryContainer
              : _DarkColors.onSurfaceVariant,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _DarkColors.surfaceHighest,
      border: const UnderlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        borderSide: BorderSide(color: _DarkColors.outlineVariant, width: 1),
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        borderSide: BorderSide(color: _DarkColors.primary, width: 2),
      ),
      labelStyle: _darkTextTheme.bodyMedium,
      hintStyle: _darkTextTheme.bodyMedium?.copyWith(
        color: _DarkColors.outline,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _DarkColors.primary,
        foregroundColor: const Color(0xFF1B0090),
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        textStyle: _darkTextTheme.labelLarge,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _DarkColors.primaryContainer,
      foregroundColor: _DarkColors.onPrimaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      elevation: 2,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _DarkColors.primary;
        }
        return _DarkColors.outlineVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _DarkColors.primary.withValues(alpha: 0.3);
        }
        return _DarkColors.surfaceHighest;
      }),
    ),
    dividerTheme: DividerThemeData(color: _DarkColors.outlineVariant),
    dialogTheme: DialogThemeData(
      backgroundColor: _DarkColors.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _DarkColors.surfaceHighest,
      contentTextStyle: _darkTextTheme.bodyMedium,
    ),
  );
}
