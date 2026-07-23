import 'package:flutter/material.dart';
import 'package:fyqen/shared/widgets/app_button.dart';

/// Confirmation flow that keeps the dialog open when deletion persistence fails.
final class DeleteAssetConfirmationDialog extends StatefulWidget {
  const DeleteAssetConfirmationDialog({
    required this.assetId,
    required this.onDelete,
    super.key,
  });

  final String assetId;
  final Future<bool> Function(String assetId) onDelete;

  @override
  State<DeleteAssetConfirmationDialog> createState() =>
      _DeleteAssetConfirmationDialogState();
}

final class _DeleteAssetConfirmationDialogState
    extends State<DeleteAssetConfirmationDialog> {
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
    final bool didDelete = await widget.onDelete(widget.assetId);
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
      title: const Text('Delete asset?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('This asset will be removed from your portfolio.'),
          if (_hasFailure) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              'We could not delete this asset. Please try again.',
              style: TextStyle(color: colorScheme.error),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        AppButton(
          label: 'Cancel',
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          variant: AppButtonVariant.text,
          expand: false,
        ),
        FilledButton(
          onPressed: _isDeleting ? null : _delete,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: _isDeleting
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }
}
