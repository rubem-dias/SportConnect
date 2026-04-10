import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF5C6BC0);
  static const primaryLight = Color(0xFF8E99F3);
  static const primaryDark = Color(0xFF26418F);

  static const secondary = Color(0xFFFF7043);
  static const secondaryLight = Color(0xFFFF9E80);
  static const secondaryDark = Color(0xFFC63F17);

  // Feedback
  static const success = Color(0xFF00C853);
  static const successLight = Color(0xFF69F0AE);
  static const warning = Color(0xFFFFD600);
  static const warningLight = Color(0xFFFFFF52);
  static const error = Color(0xFFD50000);
  static const errorLight = Color(0xFFFF5131);
  static const info = Color(0xFF2979FF);

  // PR / Gamification
  static const prGold = Color(0xFFFFD700);
  static const prGreen = Color(0xFF00C853);
  static const prBadgeBg = Color(0xFF003300);

  // Backgrounds — Light
  static const backgroundLight = Color(0xFFF5F5F5);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceVariantLight = Color(0xFFEEEEEE);
  static const borderLight = Color(0xFFE0E0E0);

  // Backgrounds — Dark
  static const backgroundDark = Color(0xFF1A1A2E);
  static const surfaceDark = Color(0xFF16213E);
  static const surfaceVariantDark = Color(0xFF0F3460);
  static const borderDark = Color(0xFF2C2C54);

  // Chat bubbles
  static const chatBubbleMe = Color(0xFF5C6BC0);
  static const chatBubbleOther = Color(0xFFFFFFFF);
  static const chatBubbleMeDark = Color(0xFF3949AB);
  static const chatBubbleOtherDark = Color(0xFF16213E);

  // Text
  static const textPrimaryLight = Color(0xFF212121);
  static const textSecondaryLight = Color(0xFF757575);
  static const textDisabledLight = Color(0xFFBDBDBD);

  static const textPrimaryDark = Color(0xFFEEEEEE);
  static const textSecondaryDark = Color(0xFF9E9E9E);
  static const textDisabledDark = Color(0xFF616161);

  // Online indicator
  static const online = Color(0xFF00E676);
  static const offline = Color(0xFF757575);

  // Transparent helpers
  static const transparent = Colors.transparent;
  static const overlay = Color(0x80000000);
}
