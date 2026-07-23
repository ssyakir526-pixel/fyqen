import 'package:flutter/material.dart';

import '../../features/assets/domain/entities/asset.dart';
import '../../features/battle/presentation/pages/battle_placeholder_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_placeholder_page.dart';
import '../../features/history/presentation/pages/history_placeholder_page.dart';
import '../../features/journey/presentation/pages/journey_placeholder_page.dart';
import '../../features/portfolio/domain/entities/portfolio.dart';
import '../../features/portfolio/presentation/pages/assets_page.dart';
import '../../features/portfolio/presentation/pages/portfolio_placeholder_page.dart';
import '../../features/settings/presentation/pages/settings_placeholder_page.dart';
import 'fyqen_destination.dart';

/// Owns selection for Fyqen's persistent primary navigation destinations.
final class FyqenShell extends StatefulWidget {
  const FyqenShell({
    super.key,
    this.onSignOut,
    this.portfolio,
    this.isPortfolioSaving = false,
    this.onAddAsset,
    this.onReplaceAsset,
    this.onRemoveAsset,
    this.createAssetId,
    this.currentTime,
  });

  final VoidCallback? onSignOut;
  final Portfolio? portfolio;
  final bool isPortfolioSaving;
  final Future<bool> Function(Asset asset)? onAddAsset;
  final Future<bool> Function(Asset asset)? onReplaceAsset;
  final Future<bool> Function(String assetId)? onRemoveAsset;
  final String Function()? createAssetId;
  final DateTime Function()? currentTime;

  @override
  State<FyqenShell> createState() => _FyqenShellState();
}

final class _FyqenShellState extends State<FyqenShell> {
  late List<Widget> _pages;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = _buildPages();
  }

  @override
  void didUpdateWidget(covariant FyqenShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.portfolio, widget.portfolio) ||
        oldWidget.isPortfolioSaving != widget.isPortfolioSaving) {
      _pages = _buildPages();
    }
  }

  List<Widget> _buildPages() {
    final Portfolio? portfolio = widget.portfolio;
    final bool canManageAssets =
        portfolio != null &&
        widget.onAddAsset != null &&
        widget.onReplaceAsset != null &&
        widget.onRemoveAsset != null &&
        widget.createAssetId != null &&
        widget.currentTime != null;

    return <Widget>[
      DashboardPlaceholderPage(
        portfolio: portfolio,
        isPortfolioSaving: widget.isPortfolioSaving,
      ),
      canManageAssets
          ? AssetsPage(
              portfolio: portfolio,
              onAddAsset: widget.onAddAsset!,
              onReplaceAsset: widget.onReplaceAsset!,
              onRemoveAsset: widget.onRemoveAsset!,
              createAssetId: widget.createAssetId!,
              currentTime: widget.currentTime!,
              isSaving: widget.isPortfolioSaving,
            )
          : const PortfolioPlaceholderPage(),
      const JourneyPlaceholderPage(),
      const HistoryPlaceholderPage(),
      const BattlePlaceholderPage(),
      SettingsPlaceholderPage(onSignOut: widget.onSignOut),
    ];
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<FyqenDestination> destinations = FyqenDestination.values;

    return Column(
      key: const Key('fyqen_shell'),
      children: <Widget>[
        Expanded(
          child: IndexedStack(index: _selectedIndex, children: _pages),
        ),
        NavigationBar(
          key: const Key('fyqen_navigation_bar'),
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: destinations
              .map(
                (FyqenDestination destination) => NavigationDestination(
                  key: Key('${destination.name}_destination'),
                  icon: Icon(destination.unselectedIcon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.label,
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}
