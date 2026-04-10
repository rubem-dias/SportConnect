import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.label, this.color});

  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.borderDark
            : AppColors.borderLight);

    if (label == null) {
      return Divider(color: dividerColor, height: 1, thickness: 1);
    }

    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label!,
            style: AppTypography.labelSmall.copyWith(color: dividerColor),
          ),
        ),
        Expanded(child: Divider(color: dividerColor, thickness: 1)),
      ],
    );
  }
}
