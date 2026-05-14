import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const primary = Color(0xFF3525CD);
  static const primaryContainer = Color(0xFF4F46E5);
  static const onPrimaryContainer = Color(0xFFDAD7FF);

  static const secondary = Color(0xFF712AE2);
  static const secondaryContainer = Color(0xFF8A4CFC);
  static const onSecondaryContainer = Color(0xFFFFFBFF);

  // Surface Palette (Tonal Layers)
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const surfaceContainer = Color(0xFFEDEEEF);
  static const surfaceContainerHigh = Color(0xFFE7E8E9);
  static const surfaceContainerHighest = Color(0xFFE1E3E4);

  // Text / Content
  static const onBackground = Color(0xFF191C1D);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF464555);
  static const outline = Color(0xFF777587);
  static const outlineVariant = Color(0xFFC7C4D8);

  // Semantic
  static const income = Color(0xFF00505F); // tertiary
  static const incomeContainer = Color(0xFF006A7C); // tertiary-container
  static const expense = Color(0xFFBA1A1A); // error
  static const expenseContainer = Color(0xFFFFDAD6); // error-container
  static const warning = Color(0xFFF59E0B);

  static Color get inversePrimary => primaryContainer;

  static Color get surfaceVariant => surfaceContainerHigh;

  static Color get tertiary => income;

  static Color get tertiaryContainer => incomeContainer;

  static Color get onTertiaryContainer => onSecondaryContainer;
}

class AppTheme {
  static TextTheme get _textTheme => const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Hanken Grotesk',
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: AppColors.onSurface,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Hanken Grotesk',
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurface,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Hanken Grotesk',
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurface,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Hanken Grotesk',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: AppColors.onSurface,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Hanken Grotesk',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: AppColors.onSurfaceVariant,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Hanken Grotesk',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: AppColors.onSurfaceVariant,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Hanken Grotesk',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: AppColors.onSurfaceVariant,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Hanken Grotesk',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: AppColors.onSurfaceVariant,
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Hanken Grotesk',
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
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _textTheme.titleLarge,
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
          return _textTheme.labelMedium!.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          );
        }
        return _textTheme.labelMedium!.copyWith(
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
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: _textTheme.bodyMedium,
      hintStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.outline),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        textStyle: _textTheme.labelLarge,
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

  static ThemeData get darkTheme => lightTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF191C1D),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.inversePrimary, // M3 dark mode primary
      surface: const Color(0xFF191C1D),
      brightness: Brightness.dark,
    ),
  );
}
