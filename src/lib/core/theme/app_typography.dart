import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const _inter = 'Inter';
  static const _roboto = 'Roboto';

  // Display — Inter
  static const displayLarge = TextStyle(
    fontFamily: _inter,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const displayMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 1.16,
  );

  static const displaySmall = TextStyle(
    fontFamily: _inter,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.22,
  );

  // Headline — Inter
  static const headlineLarge = TextStyle(
    fontFamily: _inter,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const headlineMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
  );

  static const headlineSmall = TextStyle(
    fontFamily: _inter,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // Title — Inter
  static const titleLarge = TextStyle(
    fontFamily: _inter,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );

  static const titleMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const titleSmall = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body — Roboto
  static const bodyLarge = TextStyle(
    fontFamily: _roboto,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _roboto,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const bodySmall = TextStyle(
    fontFamily: _roboto,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label — Roboto
  static const labelLarge = TextStyle(
    fontFamily: _roboto,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const labelMedium = TextStyle(
    fontFamily: _roboto,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const labelSmall = TextStyle(
    fontFamily: _roboto,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  static TextTheme get textTheme => const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
