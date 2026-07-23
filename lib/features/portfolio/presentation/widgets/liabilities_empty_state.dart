import 'package:flutter/material.dart';
import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/shared/widgets/app_button.dart';
import 'package:fyqen/shared/widgets/empty_state.dart';

/// Empty Liability collection state with an explicit add action.
final class LiabilitiesEmptyState extends StatelessWidget {
  const LiabilitiesEmptyState({
    super.key,
    this.onAddLiability,
    this.isSaving = false,
  });

  final VoidCallback? onAddLiability;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('liabilities-empty-state'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const EmptyState(
            icon: Icons.account_balance_outlined,
            title: 'No liabilities yet',
            message:
                'Add a liability to keep your net worth calculation accurate.',
          ),
          if (isSaving) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            const LinearProgressIndicator(
              key: Key('liabilities-saving-indicator'),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            key: const Key('liabilities-empty-state-add-button'),
            label: 'Add Liability',
            icon: Icons.add,
            onPressed: onAddLiability,
            expand: false,
          ),
        ],
      ),
    );
  }
}
