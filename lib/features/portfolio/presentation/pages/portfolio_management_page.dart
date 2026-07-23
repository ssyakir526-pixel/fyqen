import 'package:flutter/material.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/presentation/pages/assets_page.dart';
import 'package:fyqen/features/portfolio/presentation/pages/liabilities_page.dart';

/// Keeps Asset and Liability management within the existing Portfolio destination.
final class PortfolioManagementPage extends StatelessWidget {
  const PortfolioManagementPage({
    required this.portfolio,
    required this.isSaving,
    required this.onAddAsset,
    required this.onReplaceAsset,
    required this.onRemoveAsset,
    required this.onAddLiability,
    required this.onReplaceLiability,
    required this.onRemoveLiability,
    required this.createAssetId,
    required this.createLiabilityId,
    required this.currentTime,
    super.key,
    this.initialSectionIndex = 0,
    this.onSectionSelected,
  });

  final Portfolio portfolio;
  final bool isSaving;
  final Future<bool> Function(Asset asset) onAddAsset;
  final Future<bool> Function(Asset asset) onReplaceAsset;
  final Future<bool> Function(String assetId) onRemoveAsset;
  final Future<bool> Function(Liability liability) onAddLiability;
  final Future<bool> Function(Liability liability) onReplaceLiability;
  final Future<bool> Function(String liabilityId) onRemoveLiability;
  final String Function() createAssetId;
  final String Function() createLiabilityId;
  final DateTime Function() currentTime;
  final int initialSectionIndex;
  final ValueChanged<int>? onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialSectionIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Portfolio'),
          bottom: TabBar(
            onTap: onSectionSelected,
            tabs: const <Widget>[
              Tab(text: 'Assets'),
              Tab(text: 'Liabilities'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            AssetsPage(
              portfolio: portfolio,
              onAddAsset: onAddAsset,
              onReplaceAsset: onReplaceAsset,
              onRemoveAsset: onRemoveAsset,
              createAssetId: createAssetId,
              currentTime: currentTime,
              isSaving: isSaving,
              showAppBar: false,
            ),
            LiabilitiesPage(
              portfolio: portfolio,
              onAddLiability: onAddLiability,
              onReplaceLiability: onReplaceLiability,
              onRemoveLiability: onRemoveLiability,
              createLiabilityId: createLiabilityId,
              currentTime: currentTime,
              isSaving: isSaving,
              showAppBar: false,
            ),
          ],
        ),
      ),
    );
  }
}
