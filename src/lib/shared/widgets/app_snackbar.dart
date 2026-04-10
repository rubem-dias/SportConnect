import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

enum AppSnackbarType { success, error, info }

abstract final class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final (icon, color) = switch (type) {
      AppSnackbarType.success => (Icons.check_circle_outline, AppColors.success),
      AppSnackbarType.error => (Icons.error_outline, AppColors.error),
      AppSnackbarType.info => (Icons.info_outline, AppColors.info),
    };

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onAction ?? () {},
                )
              : null,
          content: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: AppSnackbarType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: AppSnackbarType.error);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: AppSnackbarType.info);
}
