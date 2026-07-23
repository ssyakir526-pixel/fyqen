import 'package:flutter/material.dart';
import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/shared/widgets/app_button.dart';

/// Confirmation flow that keeps the dialog open when deletion persistence fails.
final class DeleteLiabilityConfirmationDialog extends StatefulWidget {
  const DeleteLiabilityConfirmationDialog({
    required this.liabilityId,
    required this.onDelete,
    super.key,
  });

  final String liabilityId;
  final Future<bool> Function(String liabilityId) onDelete;

  @override
  State<DeleteLiabilityConfirmationDialog> createState() =>
      _DeleteLiabilityConfirmationDialogState();
}

final class _DeleteLiabilityConfirmationDialogState
    extends State<DeleteLiabilityConfirmationDialog> {
  bool _isDeleting = false;
  bool _hasFailure = false;

  Future<void> _delete() async {
    if (_isDeleting) {
      return;
    }

    setState(() {
      _isDeleting = true;
      _hasFailure = false;
    });
    final bool didDelete = await widget.onDelete(widget.liabilityId);
    if (!mounted) {
      return;
    }
    if (didDelete) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isDeleting = false;
      _hasFailure = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      key: const Key('delete-liability-dialog'),
      title: const Text('Delete liability?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('This liability will be removed from your portfolio.'),
          if (_hasFailure) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We could not delete this liability. Please try again.',
              style: TextStyle(color: colorScheme.error),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        AppButton(
          key: const Key('cancel-delete-liability-button'),
          label: 'Cancel',
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          variant: AppButtonVariant.text,
          expand: false,
        ),
        FilledButton(
          key: const Key('confirm-delete-liability-button'),
          onPressed: _isDeleting ? null : _delete,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: _isDeleting
              ? const SizedBox.square(
                  dimension: AppSpacing.md,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }
}
