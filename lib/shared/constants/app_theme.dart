import 'package:flutter/material.dart';

/// Light of Impact Design System
/// Comprehensive theme and spacing constants

// ============================================================================
// COLOR SYSTEM
// ============================================================================

/// Primary Colors
const Color friendlyBlue = Color(0xFF1E7ABF);
const Color softTeal = Color(0xFF3BB3A9);

/// Background Colors
const Color backgroundOffWhite = Color(0xFFF9FAFB);
const Color softBlueTint = Color(0xFFF3F8FC);
const Color cardWhite = Color(0xFFFFFFFF);

/// Text Colors
const Color textDark = Color(0xFF1F2937);
const Color textMedium = Color(0xFF6B7280);
const Color textLight = Color(0xFF9CA3AF);

/// Border & Divider Colors
const Color borderLight = Color(0xFFE5E7EB);
const Color dividerColor = Color(0xFFE5E7EB);

/// Status Colors
const Color successColor = Color(0xFF3BB3A9);
const Color warningColor = Color(0xFFF59E0B);
const Color errorColor = Color(0xFFEF4444);
const Color infoColor = Color(0xFF1E7ABF);

/// Shimmer Colors
const Color shimmerBaseColor = Color(0xFFE8EDF2);
const Color shimmerHighlightColor = Color(0xFFF5F7FA);

// ============================================================================
// SPACING SYSTEM (8px base grid)
// ============================================================================

/// Extra small spacing - 4px
const double spacingXxs = 4;

/// Small spacing - 8px
const double spacingXs = 8;

/// Medium-small spacing - 12px
const double spacingSm = 12;

/// Medium spacing - 16px
const double spacingMd = 16;

/// Large spacing - 20px
const double spacingLg = 20;

/// Extra large spacing - 24px
const double spacingXl = 24;

/// 2x Extra large spacing - 32px
const double spacing2Xl = 32;

/// 3x Extra large spacing - 40px
const double spacing3Xl = 40;

/// 4x Extra large spacing - 48px
const double spacing4Xl = 48;

// ============================================================================
// BORDER RADIUS SYSTEM
// ============================================================================

/// Small radius - 8px
const double radiusSm = 8;

/// Medium radius - 12px
const double radiusMd = 12;

/// Large radius - 16px
const double radiusLg = 16;

/// Extra large radius - 20px
const double radiusXl = 20;

/// 2x Extra large radius - 24px
const double radius2Xl = 24;

/// Full radius (circle) - 9999
const double radiusFull = 9999;

// ============================================================================
// SHADOWS
// ============================================================================

/// Small shadow - subtle elevation
final List<BoxShadow> shadowSm = [
  BoxShadow(
    color: friendlyBlue.withAlpha(8),
    blurRadius: 8,
    offset: const Offset(0, 2),
  ),
];

/// Medium shadow - cards
final List<BoxShadow> shadowMd = [
  BoxShadow(
    color: friendlyBlue.withAlpha(12),
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

/// Large shadow - elevated cards
final List<BoxShadow> shadowLg = [
  BoxShadow(
    color: friendlyBlue.withAlpha(20),
    blurRadius: 16,
    offset: const Offset(0, 8),
  ),
];

/// Extra large shadow - modals/bottom sheets
final List<BoxShadow> shadowXl = [
  BoxShadow(
    color: friendlyBlue.withAlpha(30),
    blurRadius: 24,
    offset: const Offset(0, 12),
  ),
];

// ============================================================================
// TYPOGRAPHY
// ============================================================================

/// Font weights
const FontWeight fontLight = FontWeight.w300;
const FontWeight fontRegular = FontWeight.w400;
const FontWeight fontMedium = FontWeight.w500;
const FontWeight fontSemiBold = FontWeight.w600;
const FontWeight fontBold = FontWeight.w700;
const FontWeight fontExtraBold = FontWeight.w800;

/// Text Styles
class AppTextStyles {
  static const String fontFamily = 'IBM Plex Sans Arabic';

  /// Heading styles
  static TextStyle h1 = const TextStyle(
    fontSize: 32,
    fontWeight: fontBold,
    color: textDark,
    height: 1.3,
  );

  static TextStyle h2 = const TextStyle(
    fontSize: 24,
    fontWeight: fontBold,
    color: textDark,
    height: 1.3,
  );

  static TextStyle h3 = const TextStyle(
    fontSize: 20,
    fontWeight: fontBold,
    color: textDark,
    height: 1.3,
  );

  static TextStyle h4 = const TextStyle(
    fontSize: 18,
    fontWeight: fontBold,
    color: textDark,
    height: 1.4,
  );

  /// Body styles
  static TextStyle bodyLarge = const TextStyle(
    fontSize: 16,
    fontWeight: fontRegular,
    color: textDark,
    height: 1.5,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 14,
    fontWeight: fontRegular,
    color: textDark,
    height: 1.5,
  );

  static TextStyle bodySmall = const TextStyle(
    fontSize: 12,
    fontWeight: fontRegular,
    color: textDark,
    height: 1.5,
  );

  /// Label styles
  static TextStyle labelLarge = const TextStyle(
    fontSize: 14,
    fontWeight: fontSemiBold,
    color: textDark,
    letterSpacing: 0.5,
  );

  static TextStyle labelMedium = const TextStyle(
    fontSize: 12,
    fontWeight: fontSemiBold,
    color: textDark,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = const TextStyle(
    fontSize: 11,
    fontWeight: fontSemiBold,
    color: textDark,
    letterSpacing: 0.5,
  );
}

// ============================================================================
// DURATIONS (Animation & Transitions)
// ============================================================================

/// Fast duration - 100ms
const Duration durationFast = Duration(milliseconds: 100);

/// Normal duration - 200ms
const Duration durationNormal = Duration(milliseconds: 200);

/// Medium duration - 300ms
const Duration durationMedium = Duration(milliseconds: 300);

/// Slow duration - 500ms
const Duration durationSlow = Duration(milliseconds: 500);

/// Very slow duration - 800ms
const Duration durationVerySlow = Duration(milliseconds: 800);

// ============================================================================
// EASING CURVES
// ============================================================================

/// Standard easing
const Curve curveStandard = Curves.easeInOut;

/// Entrance easing (decelerate)
const Curve curveEntrance = Curves.decelerate;

/// Exit easing (accelerate)
const Curve curveExit = Curves.easeIn;

/// Bounce easing
const Curve curveBounce = Curves.elasticOut;

// ============================================================================
// APP THEME
// ============================================================================

class AppTheme {
  /// Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'IBM Plex Sans Arabic',
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundOffWhite,
    primaryColor: friendlyBlue,
    colorScheme: const ColorScheme.light(
      primary: friendlyBlue,
      secondary: softTeal,
      surface: cardWhite,
      background: backgroundOffWhite,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark,
      onBackground: textDark,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundOffWhite,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h4,
      iconTheme: const IconThemeData(color: friendlyBlue),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: softBlueTint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: friendlyBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingSm,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: friendlyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: friendlyBlue,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingXs,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: friendlyBlue,
        side: const BorderSide(color: friendlyBlue),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: spacingMd,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      backgroundColor: textDark,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
    ),
  );
}
