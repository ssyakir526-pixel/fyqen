import 'package:flutter/material.dart';
import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/shared/widgets/app_button.dart';
import 'package:fyqen/shared/widgets/empty_state.dart';

/// Empty Asset collection state with an explicit add action.
final class AssetsEmptyState extends StatelessWidget {
  const AssetsEmptyState({required this.onAddAsset, super.key});

  final VoidCallback onAddAsset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No assets yet',
            message: 'Add your first asset to start tracking your portfolio.',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            key: const Key('assets-empty-state-add-button'),
            label: 'Add Asset',
            icon: Icons.add,
            onPressed: onAddAsset,
            expand: false,
          ),
        ],
      ),
    );
  }
}
