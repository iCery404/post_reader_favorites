import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Night sky behind the window
  static const Color night = Color(0xFF2B2851);
  static const Color nightDeep = Color(0xFF1D1B3A);
  static const Color star = Color(0xFFEDE6CF);
  static const Color shadowNavy = Color(0xFF15132D);

  // Window frame
  static const Color outline = Color(0xFF3B4739);

  // Caramel (title bar, primary buttons, panel borders)
  static const Color caramel = Color(0xFFB08968);
  static const Color caramelDark = Color(0xFF7B5A43);

  // Cream paper
  static const Color cream = Color(0xFFF5ECDB);
  static const Color creamLight = Color(0xFFFBF6EA);
  static const Color rowAlt = Color(0xFFF0E4CF);
  static const Color hover = Color(0x4DC6DBCF);

  // Sage green (table header, secondary buttons)
  static const Color sage = Color(0xFF8FB09E);
  static const Color sageLight = Color(0xFFC6DBCF);
  static const Color sageDark = Color(0xFF3E5648);

  // Text
  static const Color cocoa = Color(0xFF5A3D2B);
  static const Color ink = Color(0xFF3F3028);

  // Alerts
  static const Color blush = Color(0xFFD9857F);
  static const Color blushLight = Color(0xFFF6DAD5);
  static const Color danger = Color(0xFFB5524A);
}

class AppTheme {
  AppTheme._();

  static const double radius = 14;

  static ThemeData get light {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    // Rounded, friendly sans for body text...
    final TextTheme nunito = GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.cocoa,
    );

    // ...and a bold serif for headings, like "Welcome back" in the reference.
    final TextTheme textTheme = nunito.copyWith(
      headlineSmall: GoogleFonts.lora(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.cocoa,
      ),
      titleLarge: GoogleFonts.lora(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.cocoa,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 15.5,
        fontWeight: FontWeight.w800,
        height: 1.3,
        color: AppColors.ink,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        height: 1.5,
        color: AppColors.ink,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        height: 1.4,
        color: AppColors.ink,
      ),
      labelLarge: GoogleFonts.nunito(
        fontSize: 14.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      ),
    );

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.caramel,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.caramel,
      onPrimary: Colors.white,
      secondary: AppColors.sage,
      onSecondary: AppColors.ink,
      surface: AppColors.cream,
      onSurface: AppColors.ink,
      error: AppColors.danger,
    );

    OutlineInputBorder inputBorder(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.night,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.caramel,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 15.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.caramel,
        foregroundColor: Colors.white,
        extendedTextStyle: textTheme.labelLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creamLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(
          color: AppColors.cocoa,
          fontWeight: FontWeight.w700,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.cocoa,
          fontWeight: FontWeight.w800,
        ),
        border: inputBorder(AppColors.caramel, 2),
        enabledBorder: inputBorder(AppColors.caramel, 2),
        focusedBorder: inputBorder(AppColors.caramelDark, 2.5),
        errorBorder: inputBorder(AppColors.blush, 2),
        focusedErrorBorder: inputBorder(AppColors.danger, 2.5),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: AppColors.cocoa,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.nunito(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.caramelDark,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.sageDark,
      ),
    );
  }
}
