import 'package:flutter/material.dart';


enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                leadingIcon!,
                const SizedBox(width: 8),
              ],
              Text(label),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                trailingIcon!,
              ],
            ],
          );

    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
    };

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
