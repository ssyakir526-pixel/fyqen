import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, text }

/// A themed button that supports visual variants and a stable loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color progressColor = switch (variant) {
      AppButtonVariant.primary => colorScheme.onPrimary,
      AppButtonVariant.secondary ||
      AppButtonVariant.text => colorScheme.primary,
    };
    final Widget child = isLoading
        ? Semantics(
            label: 'Loading',
            child: SizedBox.square(
              dimension: AppSpacing.md,
              child: CircularProgressIndicator(color: progressColor),
            ),
          )
        : Text(label);
    final Widget button = switch (variant) {
      AppButtonVariant.primary =>
        icon == null || isLoading
            ? FilledButton(onPressed: effectiveOnPressed, child: child)
            : FilledButton.icon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon),
                label: child,
              ),
      AppButtonVariant.secondary =>
        icon == null || isLoading
            ? OutlinedButton(onPressed: effectiveOnPressed, child: child)
            : OutlinedButton.icon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon),
                label: child,
              ),
      AppButtonVariant.text =>
        icon == null || isLoading
            ? TextButton(onPressed: effectiveOnPressed, child: child)
            : TextButton.icon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon),
                label: child,
              ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
