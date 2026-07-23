import 'package:flutter/material.dart';
import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/dashboard/presentation/models/dashboard_portfolio_summary.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/presentation/widgets/asset_form.dart';
import 'package:fyqen/features/portfolio/presentation/widgets/asset_list_item.dart';
import 'package:fyqen/features/portfolio/presentation/widgets/assets_empty_state.dart';
import 'package:fyqen/features/portfolio/presentation/widgets/delete_asset_confirmation_dialog.dart';
import 'package:fyqen/shared/widgets/app_button.dart';

/// Portfolio destination for viewing and managing the current Asset collection.
final class AssetsPage extends StatelessWidget {
  const AssetsPage({
    required this.portfolio,
    required this.onAddAsset,
    required this.onReplaceAsset,
    required this.onRemoveAsset,
    required this.createAssetId,
    required this.currentTime,
    super.key,
    this.isSaving = false,
  });

  final Portfolio portfolio;
  final Future<bool> Function(Asset asset) onAddAsset;
  final Future<bool> Function(Asset asset) onReplaceAsset;
  final Future<bool> Function(String assetId) onRemoveAsset;
  final String Function() createAssetId;
  final DateTime Function() currentTime;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final DashboardPortfolioSummary summary =
        DashboardPortfolioSummary.fromPortfolio(portfolio);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets'),
        actions: <Widget>[
          IconButton(
            key: const Key('assets-page-add-button'),
            tooltip: 'Add Asset',
            onPressed: isSaving ? null : () => _openForm(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: portfolio.assets.isEmpty
            ? AssetsEmptyState(onAddAsset: () => _openForm(context))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: portfolio.assets.length + 1,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return _AssetSummary(
                      assetCount: summary.assetCount,
                      totalAssetsLabel: summary.totalAssetsLabel,
                      isSaving: isSaving,
                      onAddAsset: () => _openForm(context),
                    );
                  }

                  final Asset asset = portfolio.assets[index - 1];
                  return AssetListItem(
                    asset: asset,
                    onEdit: isSaving ? null : () => _openForm(context, asset),
                    onDelete: isSaving
                        ? null
                        : () => _confirmDelete(context, asset),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, [Asset? asset]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AssetForm(
          initialAsset: asset,
          createAssetId: createAssetId,
          currentTime: currentTime,
          onSubmit: asset == null ? onAddAsset : onReplaceAsset,
          isSaving: isSaving,
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Asset asset) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DeleteAssetConfirmationDialog(
          assetId: asset.id,
          onDelete: onRemoveAsset,
        );
      },
    );
  }
}

final class _AssetSummary extends StatelessWidget {
  const _AssetSummary({
    required this.assetCount,
    required this.totalAssetsLabel,
    required this.isSaving,
    required this.onAddAsset,
  });

  final int assetCount;
  final String totalAssetsLabel;
  final bool isSaving;
  final VoidCallback onAddAsset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Track the assets that contribute to your net worth.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Text('$assetCount assets • Total: $totalAssetsLabel'),
        if (isSaving) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          const LinearProgressIndicator(),
        ],
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Add Asset',
          icon: Icons.add,
          onPressed: isSaving ? null : onAddAsset,
          expand: false,
        ),
      ],
    );
  }
}
