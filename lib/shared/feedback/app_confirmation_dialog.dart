import 'package:flutter/material.dart';

import '../widgets/app_button.dart';

/// Requests confirmation and returns only the user's explicit intent.
Future<bool> showAppConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Confirm',
  bool isDestructive = false,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      final ColorScheme colorScheme = Theme.of(dialogContext).colorScheme;

      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          AppButton(
            label: cancelLabel,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            variant: AppButtonVariant.text,
            expand: false,
          ),
          isDestructive
              ? FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                  child: Text(confirmLabel),
                )
              : AppButton(
                  label: confirmLabel,
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  expand: false,
                ),
        ],
      );
    },
  );

  return confirmed ?? false;
}
