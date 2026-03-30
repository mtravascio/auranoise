// Aura Deep Slate Design System
// Based on DESIGN.md specifications

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color tokens from the Aura Deep Slate design system
class AuraColors {
  // Background colors
  static const Color background = Color(0xFF0E0E0E);
  static const Color surface = Color(0xFF0E0E0E);
  static const Color surfaceDim = Color(0xFF0E0E0E);
  static const Color surfaceBright = Color(0xFF2C2C2C);

  // Container hierarchy (elevation through tonal shifts)
  static const Color surfaceContainerLowest = Color(0xFF000000);
  static const Color surfaceContainerLow = Color(0xFF131313);
  static const Color surfaceContainer = Color(0xFF1A1A1A);
  static const Color surfaceContainerHigh = Color(0xFF20201F);
  static const Color surfaceContainerHighest = Color(0xFF262626);
  static const Color surfaceVariant = Color(0xFF262626);

  // Primary accent (The glow of dawn)
  static const Color primary = Color(0xFF54C7FC);
  static const Color primaryDim = Color(0xFF42B9ED);
  static const Color primaryContainer = Color(0xFF2EACDF);
  static const Color onPrimary = Color(0xFF003D54);
  static const Color onPrimaryContainer = Color(0xFF002635);
  static const Color primaryFixed = Color(0xFF54C7FC);
  static const Color onPrimaryFixed = Color(0xFF002636);
  static const Color primaryFixedDim = Color(0xFF42B9ED);

  // Secondary
  static const Color secondary = Color(0xFFD1E6F0);
  static const Color secondaryDim = Color(0xFFC3D8E2);
  static const Color secondaryContainer = Color(0xFF374952);
  static const Color onSecondary = Color(0xFF41545D);
  static const Color onSecondaryContainer = Color(0xFFBFD3DE);
  static const Color secondaryFixed = Color(0xFFD1E6F0);
  static const Color onSecondaryFixed = Color(0xFF2F424A);
  static const Color secondaryFixedDim = Color(0xFFC3D8E2);

  // Tertiary
  static const Color tertiary = Color(0xFF8EA0FF);
  static const Color tertiaryDim = Color(0xFF8397FF);
  static const Color tertiaryContainer = Color(0xFF7D91FA);
  static const Color onTertiary = Color(0xFF001A77);
  static const Color onTertiaryContainer = Color(0xFF001056);
  static const Color tertiaryFixed = Color(0xFF9DABFF);
  static const Color onTertiaryFixed = Color(0xFF000E50);

  // Error
  static const Color error = Color(0xFFFF716C);
  static const Color errorDim = Color(0xFFD7383B);
  static const Color errorContainer = Color(0xFF9F0519);
  static const Color onError = Color(0xFF490006);
  static const Color onErrorContainer = Color(0xFFFFA8A3);

  // Text colors
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFADAAAA);
  static const Color onBackground = Color(0xFFFFFFFF);

  // Outline
  static const Color outline = Color(0xFF767575);
  static const Color outlineVariant = Color(0xFF484847);

  // Utility
  static const Color inverseSurface = Color(0xFFFCF9F8);
  static const Color inverseOnSurface = Color(0xFF565555);
  static const Color inversePrimary = Color(0xFF006789);
  static const Color surfaceTint = Color(0xFF54C7FC);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryContainer],
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x99262626), Color(0x991A1A1A)],
  );
}

/// Typography using Manrope for headlines and Inter for body
class AuraTypography {
  // Display sizes
  static TextStyle get displayLarge => GoogleFonts.manrope(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.02,
    height: 1.1,
    color: AuraColors.onSurface,
  );

  static TextStyle get displayMedium => GoogleFonts.manrope(
    fontSize: 44,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.02,
    height: 1.1,
    color: AuraColors.onSurface,
  );

  static TextStyle get displaySmall => GoogleFonts.manrope(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    height: 1.2,
    color: AuraColors.onSurface,
  );

  // Headlines
  static TextStyle get headlineLarge => GoogleFonts.manrope(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    height: 1.2,
    color: AuraColors.onSurface,
  );

  static TextStyle get headlineMedium => GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    height: 1.2,
    color: AuraColors.onSurface,
  );

  static TextStyle get headlineSmall => GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    height: 1.3,
    color: AuraColors.onSurface,
  );

  // Title
  static TextStyle get titleLarge => GoogleFonts.manrope(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: AuraColors.onSurface,
  );

  static TextStyle get titleMedium => GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AuraColors.onSurface,
  );

  static TextStyle get titleSmall => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AuraColors.onSurface,
  );

  // Body (Inter font)
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AuraColors.onSurface,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AuraColors.onSurface,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
    color: AuraColors.onSurface,
  );

  // Label
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.02,
    height: 1.4,
    color: AuraColors.onSurface,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.02,
    height: 1.4,
    color: AuraColors.onSurface,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
    height: 1.2,
    color: AuraColors.onSurface,
  );

  // Special styles
  static TextStyle get uppercaseLabel => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.2,
    color: AuraColors.onSurfaceVariant,
  );
}

/// Border radius tokens
class AuraRadius {
  static const double none = 0;
  static const double sm = 8;
  static const double md = 24; // 1.5rem
  static const double lg = 32; // 2rem
  static const double xl = 48; // 3rem
  static const double full = 9999;
}

/// Spacing tokens (using 16/20/24 system)
class AuraSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 44; // 2.75rem for edge padding
}

/// Shadow tokens
class AuraShadows {
  // Ambient shadows (diffused, not heavy)
  static const BoxShadow ambientLow = BoxShadow(
    color: Color(0x66000000),
    blurRadius: 20,
    offset: Offset(0, 10),
  );

  static const BoxShadow ambientMedium = BoxShadow(
    color: Color(0x66000000),
    blurRadius: 40,
    offset: Offset(0, 20),
  );

  static const BoxShadow ambientHigh = BoxShadow(
    color: Color(0x66000000),
    blurRadius: 60,
    offset: Offset(0, 30),
  );

  // Primary glow
  static const BoxShadow primaryGlow = BoxShadow(
    color: Color(0x3354C7FC),
    blurRadius: 20,
    offset: Offset(0, 4),
  );
}

/// Main theme data for the app
class AuraTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AuraColors.background,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        background: AuraColors.background,
        surface: AuraColors.surface,
        surfaceVariant: AuraColors.surfaceVariant,
        primary: AuraColors.primary,
        onPrimary: AuraColors.onPrimary,
        primaryContainer: AuraColors.primaryContainer,
        onPrimaryContainer: AuraColors.onPrimaryContainer,
        secondary: AuraColors.secondary,
        onSecondary: AuraColors.onSecondary,
        secondaryContainer: AuraColors.secondaryContainer,
        onSecondaryContainer: AuraColors.onSecondaryContainer,
        tertiary: AuraColors.tertiary,
        onTertiary: AuraColors.onTertiary,
        error: AuraColors.error,
        onError: AuraColors.onError,
        errorContainer: AuraColors.errorContainer,
        onErrorContainer: AuraColors.onErrorContainer,
        outline: AuraColors.outline,
        outlineVariant: AuraColors.outlineVariant,
        onSurface: AuraColors.onSurface,
        onSurfaceVariant: AuraColors.onSurfaceVariant,
        surfaceTint: AuraColors.surfaceTint,
        inverseSurface: AuraColors.inverseSurface,
        inversePrimary: AuraColors.inversePrimary,
      ),
      // Typography
      textTheme: TextTheme(
        displayLarge: AuraTypography.displayLarge,
        displayMedium: AuraTypography.displayMedium,
        displaySmall: AuraTypography.displaySmall,
        headlineLarge: AuraTypography.headlineLarge,
        headlineMedium: AuraTypography.headlineMedium,
        headlineSmall: AuraTypography.headlineSmall,
        titleLarge: AuraTypography.titleLarge,
        titleMedium: AuraTypography.titleMedium,
        titleSmall: AuraTypography.titleSmall,
        bodyLarge: AuraTypography.bodyLarge,
        bodyMedium: AuraTypography.bodyMedium,
        bodySmall: AuraTypography.bodySmall,
        labelLarge: AuraTypography.labelLarge,
        labelMedium: AuraTypography.labelMedium,
        labelSmall: AuraTypography.labelSmall,
      ),
      // Card theme
      cardTheme: CardThemeData(
        color: AuraColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraRadius.md),
        ),
      ),
      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AuraColors.primary,
        inactiveTrackColor: AuraColors.surfaceVariant.withOpacity(0.4),
        thumbColor: AuraColors.primary,
        overlayColor: AuraColors.primary.withOpacity(0.16),
        trackHeight: 4,
        thumbShape: const _GlowingSliderThumb(),
      ),
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AuraColors.primary,
          foregroundColor: AuraColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuraRadius.full),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AuraTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AuraColors.onSurface,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuraRadius.full),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AuraColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuraRadius.full),
          ),
        ),
      ),
      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AuraColors.primary,
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
        ),
      ),
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AuraColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuraRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuraRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuraRadius.md),
          borderSide: const BorderSide(
            color: AuraColors.outlineVariant,
            width: 1,
          ),
        ),
        hintStyle: AuraTypography.bodyMedium.copyWith(
          color: AuraColors.onSurfaceVariant,
        ),
      ),
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AuraColors.background,
        foregroundColor: AuraColors.primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AuraTypography.headlineSmall,
      ),
      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AuraColors.surfaceContainerLow,
        selectedItemColor: AuraColors.primary,
        unselectedItemColor: AuraColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      // Divider
      dividerTheme: DividerThemeData(
        color: AuraColors.outlineVariant.withOpacity(0.2),
        thickness: 1,
        space: 0,
      ),
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AuraColors.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
      ),
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AuraColors.primary;
          }
          return AuraColors.outline;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AuraColors.primary.withOpacity(0.2);
          }
          return AuraColors.surfaceContainerHighest;
        }),
      ),
      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AuraColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(AuraColors.onPrimary),
        side: const BorderSide(color: AuraColors.outline),
      ),
      useMaterial3: true,
    );
  }

  /// Apply system UI overlay style
  static void applySystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AuraColors.surfaceContainerLow,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
}

/// Custom glowing slider thumb (the "Atmospheric Slider")
class _GlowingSliderThumb extends SliderComponentShape {
  const _GlowingSliderThumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(20, 20);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Outer glow
    final glowPaint = Paint()
      ..color = AuraColors.primary.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, 12, glowPaint);

    // Main thumb
    final thumbPaint = Paint()
      ..color = AuraColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 10, thumbPaint);

    // Inner dot
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, innerPaint);
  }
}

/// Glass panel widget (glassmorphism effect)
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AuraColors.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(borderRadius ?? AuraRadius.md),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

/// Gradient text widget
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final LinearGradient gradient;

  const GradientText({
    super.key,
    required this.text,
    required this.style,
    this.gradient = AuraColors.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

/// Background decoration with blur orbs
class AuraBackground extends StatelessWidget {
  final Widget child;

  const AuraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AuraColors.background,
      child: Stack(
        children: [
          // Subtle background glows
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AuraColors.primary.withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: AuraColors.primary.withOpacity(0.05),
                    blurRadius: 120,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AuraColors.tertiary.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: AuraColors.tertiary.withOpacity(0.03),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          // Content
          child,
        ],
      ),
    );
  }
}
