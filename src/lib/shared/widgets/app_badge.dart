import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

enum AppBadgeVariant { primary, secondary, success, warning, error, neutral }

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    super.key,
    this.variant = AppBadgeVariant.primary,
    this.leadingIcon,
    this.isSmall = false,
  });

  final String label;
  final AppBadgeVariant variant;
  final Widget? leadingIcon;
  final bool isSmall;

  Color get _backgroundColor => switch (variant) {
        AppBadgeVariant.primary => AppColors.primary.withValues(alpha: 0.15),
        AppBadgeVariant.secondary => AppColors.secondary.withValues(alpha: 0.15),
        AppBadgeVariant.success => AppColors.success.withValues(alpha: 0.15),
        AppBadgeVariant.warning => AppColors.warning.withValues(alpha: 0.20),
        AppBadgeVariant.error => AppColors.error.withValues(alpha: 0.15),
        AppBadgeVariant.neutral => AppColors.borderLight,
      };

  Color get _foregroundColor => switch (variant) {
        AppBadgeVariant.primary => AppColors.primary,
        AppBadgeVariant.secondary => AppColors.secondary,
        AppBadgeVariant.success => AppColors.success,
        AppBadgeVariant.warning => AppColors.warning,
        AppBadgeVariant.error => AppColors.error,
        AppBadgeVariant.neutral => AppColors.textSecondaryLight,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            IconTheme(
              data: IconThemeData(color: _foregroundColor, size: isSmall ? 10 : 12),
              child: leadingIcon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: (isSmall ? AppTypography.labelSmall : AppTypography.labelMedium)
                .copyWith(color: _foregroundColor),
          ),
        ],
      ),
    );
  }
}

