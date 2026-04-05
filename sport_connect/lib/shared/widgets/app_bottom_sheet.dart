import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    required this.child,
    super.key,
    this.title,
    this.trailing,
    this.padding,
    this.maxHeightFraction = 0.9,
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final double maxHeightFraction;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? trailing,
    bool isDismissible = true,
    bool enableDrag = true,
    double maxHeightFraction = 0.9,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      builder: (_) => AppBottomSheet(
        title: title,
        trailing: trailing,
        maxHeightFraction: maxHeightFraction,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * maxHeightFraction,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title!, style: AppTypography.titleMedium),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: padding ??
                    const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
