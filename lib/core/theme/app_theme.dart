import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
//  APP COLORS
// ─────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Emerald Green palette
  static const Color emeraldPrimary  = Color(0xFF10B981);
  static const Color emeraldDark     = Color(0xFF059669);
  static const Color emeraldLight    = Color(0xFF34D399);
  static const Color emeraldSurface  = Color(0xFFD1FAE5);

  // Light mode
  static const Color lightBackground = Color(0xFFF8FAF9);
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightOnSurface  = Color(0xFF1A1A1A);
  static const Color lightSubtext    = Color(0xFF6B7280);
  static const Color lightBorder     = Color(0xFFE5E7EB);
  static const Color lightError      = Color(0xFFEF4444);

  // Dark mode
  static const Color darkBackground  = Color(0xFF0F1A17);
  static const Color darkSurface     = Color(0xFF1A2E26);
  static const Color darkCard        = Color(0xFF1F3A30);
  static const Color darkOnSurface   = Color(0xFFF3F4F6);
  static const Color darkSubtext     = Color(0xFF9CA3AF);
  static const Color darkBorder      = Color(0xFF2D4A3E);
  static const Color darkError       = Color(0xFFFCA5A5);
}

// ─────────────────────────────────────────────────────────────
//  TEXT THEME  (Hind Siliguri via Google Fonts)
// ─────────────────────────────────────────────────────────────
TextTheme _buildTextTheme(Color onBackground) {
  final base = GoogleFonts.hindSiliguriTextTheme().apply(
    bodyColor:    onBackground,
    displayColor: onBackground,
  );
  return base.copyWith(
    displayLarge:   base.displayLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 32),
    displayMedium:  base.displayMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 26),
    headlineLarge:  base.headlineLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 22),
    headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
    titleLarge:     base.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
    titleMedium:    base.titleMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 14),
    bodyLarge:      base.bodyLarge?.copyWith(fontWeight: FontWeight.w400, fontSize: 16),
    bodyMedium:     base.bodyMedium?.copyWith(fontWeight: FontWeight.w400, fontSize: 14),
    bodySmall:      base.bodySmall?.copyWith(fontWeight: FontWeight.w400, fontSize: 12),
    labelLarge:     base.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
  );
}

// ─────────────────────────────────────────────────────────────
//  LIGHT THEME
// ─────────────────────────────────────────────────────────────
ThemeData get lightTheme {
  const colorScheme = ColorScheme(
    brightness:           Brightness.light,
    primary:              AppColors.emeraldPrimary,
    onPrimary:            Colors.white,
    primaryContainer:     AppColors.emeraldSurface,
    onPrimaryContainer:   AppColors.emeraldDark,
    secondary:            AppColors.emeraldDark,
    onSecondary:          Colors.white,
    secondaryContainer:   AppColors.emeraldSurface,
    onSecondaryContainer: AppColors.emeraldDark,
    surface:              AppColors.lightSurface,
    onSurface:            AppColors.lightOnSurface,
    error:                AppColors.lightError,
    onError:              Colors.white,
  );

  return ThemeData(
    useMaterial3:           true,
    brightness:             Brightness.light,
    colorScheme:            colorScheme,
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme:              _buildTextTheme(AppColors.lightOnSurface),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.emeraldPrimary,
      foregroundColor: Colors.white,
      elevation:       0,
      centerTitle:     true,
      titleTextStyle:  GoogleFonts.hindSiliguri(
        fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
      ),
    ),

    cardTheme: CardTheme(
      color:       AppColors.lightSurface,
      elevation:   2,
      shadowColor: AppColors.emeraldPrimary.withOpacity(0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.emeraldPrimary,
        foregroundColor: Colors.white,
        elevation:       0,
        padding:   const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.emeraldPrimary,
        side:      const BorderSide(color: AppColors.emeraldPrimary, width: 1.5),
        padding:   const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled:         true,
      fillColor:      AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.emeraldPrimary, width: 2),
      ),
      labelStyle: GoogleFonts.hindSiliguri(color: AppColors.lightSubtext),
      hintStyle:  GoogleFonts.hindSiliguri(color: AppColors.lightSubtext),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.emeraldPrimary,
      foregroundColor: Colors.white,
    ),

    dividerTheme: const DividerThemeData(color: AppColors.lightBorder, thickness: 1),
  );
}

// ─────────────────────────────────────────────────────────────
//  DARK THEME
// ─────────────────────────────────────────────────────────────
ThemeData get darkTheme {
  const colorScheme = ColorScheme(
    brightness:           Brightness.dark,
    primary:              AppColors.emeraldLight,
    onPrimary:            AppColors.darkBackground,
    primaryContainer:     AppColors.emeraldDark,
    onPrimaryContainer:   AppColors.emeraldSurface,
    secondary:            AppColors.emeraldPrimary,
    onSecondary:          AppColors.darkBackground,
    secondaryContainer:   AppColors.darkCard,
    onSecondaryContainer: AppColors.emeraldLight,
    surface:              AppColors.darkSurface,
    onSurface:            AppColors.darkOnSurface,
    error:                AppColors.darkError,
    onError:              AppColors.darkBackground,
  );

  return ThemeData(
    useMaterial3:           true,
    brightness:             Brightness.dark,
    colorScheme:            colorScheme,
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme:              _buildTextTheme(AppColors.darkOnSurface),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkOnSurface,
      elevation:       0,
      centerTitle:     true,
      titleTextStyle:  GoogleFonts.hindSiliguri(
        fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.darkOnSurface,
      ),
    ),

    cardTheme: CardTheme(
      color:     AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.emeraldLight,
        foregroundColor: AppColors.darkBackground,
        elevation:       0,
        padding:   const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.emeraldLight,
        side:      const BorderSide(color: AppColors.emeraldLight, width: 1.5),
        padding:   const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled:         true,
      fillColor:      AppColors.darkCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.emeraldLight, width: 2),
      ),
      labelStyle: GoogleFonts.hindSiliguri(color: AppColors.darkSubtext),
      hintStyle:  GoogleFonts.hindSiliguri(color: AppColors.darkSubtext),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.emeraldPrimary,
      foregroundColor: Colors.white,
    ),

    dividerTheme: const DividerThemeData(color: AppColors.darkBorder, thickness: 1),
  );
}
