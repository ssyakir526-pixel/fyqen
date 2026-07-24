import 'package:flutter/material.dart';

import '../../features/achievements/presentation/pages/achievements_page.dart';
import '../../features/assets/domain/entities/asset.dart';
import '../../features/dashboard/presentation/pages/dashboard_placeholder_page.dart';
import '../../features/history/presentation/pages/history_placeholder_page.dart';
import '../../features/journey/presentation/pages/journey_placeholder_page.dart';
import '../../features/liabilities/domain/entities/liability.dart';
import '../../features/portfolio/domain/entities/portfolio.dart';
import '../../features/portfolio/domain/value_objects/financial_independence_target.dart';
import '../../features/portfolio/presentation/pages/portfolio_management_page.dart';
import '../../features/portfolio/presentation/pages/portfolio_placeholder_page.dart';
import '../../features/settings/presentation/pages/settings_placeholder_page.dart';
import '../../features/streak/presentation/state/daily_streak_view_state.dart';
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
    this.onAddLiability,
    this.onReplaceLiability,
    this.onRemoveLiability,
    this.onSetFinancialIndependenceTarget,
    this.createAssetId,
    this.createLiabilityId,
    this.currentTime,
    this.dailyStreakState = const DailyStreakViewState.loading(),
    this.onRetryDailyStreak,
  });

  final VoidCallback? onSignOut;
  final Portfolio? portfolio;
  final bool isPortfolioSaving;
  final Future<bool> Function(Asset asset)? onAddAsset;
  final Future<bool> Function(Asset asset)? onReplaceAsset;
  final Future<bool> Function(String assetId)? onRemoveAsset;
  final Future<bool> Function(Liability liability)? onAddLiability;
  final Future<bool> Function(Liability liability)? onReplaceLiability;
  final Future<bool> Function(String liabilityId)? onRemoveLiability;
  final Future<bool> Function(FinancialIndependenceTarget target)?
  onSetFinancialIndependenceTarget;
  final String Function()? createAssetId;
  final String Function()? createLiabilityId;
  final DateTime Function()? currentTime;
  final DailyStreakViewState dailyStreakState;
  final Future<void> Function()? onRetryDailyStreak;

  @override
  State<FyqenShell> createState() => _FyqenShellState();
}

final class _FyqenShellState extends State<FyqenShell> {
  late List<Widget> _pages;

  int _selectedIndex = 0;
  int _portfolioSectionIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = _buildPages();
  }

  @override
  void didUpdateWidget(covariant FyqenShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.portfolio, widget.portfolio) ||
        oldWidget.isPortfolioSaving != widget.isPortfolioSaving ||
        oldWidget.dailyStreakState != widget.dailyStreakState) {
      _pages = _buildPages();
    }
  }

  List<Widget> _buildPages() {
    final Portfolio? portfolio = widget.portfolio;
    final bool canManagePortfolio =
        portfolio != null &&
        widget.onAddAsset != null &&
        widget.onReplaceAsset != null &&
        widget.onRemoveAsset != null &&
        widget.onAddLiability != null &&
        widget.onReplaceLiability != null &&
        widget.onRemoveLiability != null &&
        widget.createAssetId != null &&
        widget.createLiabilityId != null &&
        widget.currentTime != null;

    return <Widget>[
      DashboardPlaceholderPage(
        portfolio: portfolio,
        isPortfolioSaving: widget.isPortfolioSaving,
        onSetFinancialIndependenceTarget:
            widget.onSetFinancialIndependenceTarget,
        dailyStreakState: widget.dailyStreakState,
        onRetryDailyStreak: widget.onRetryDailyStreak,
      ),
      canManagePortfolio
          ? PortfolioManagementPage(
              portfolio: portfolio,
              isSaving: widget.isPortfolioSaving,
              onAddAsset: widget.onAddAsset!,
              onReplaceAsset: widget.onReplaceAsset!,
              onRemoveAsset: widget.onRemoveAsset!,
              onAddLiability: widget.onAddLiability!,
              onReplaceLiability: widget.onReplaceLiability!,
              onRemoveLiability: widget.onRemoveLiability!,
              createAssetId: widget.createAssetId!,
              createLiabilityId: widget.createLiabilityId!,
              currentTime: widget.currentTime!,
              initialSectionIndex: _portfolioSectionIndex,
              onSectionSelected: _onPortfolioSectionSelected,
            )
          : const PortfolioPlaceholderPage(),
      JourneyPlaceholderPage(
        portfolio: portfolio,
        isPortfolioSaving: widget.isPortfolioSaving,
        onSetFinancialIndependenceTarget:
            widget.onSetFinancialIndependenceTarget,
      ),
      const HistoryPlaceholderPage(),
      AchievementsPage(portfolio: portfolio),
      SettingsPlaceholderPage(onSignOut: widget.onSignOut),
    ];
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onPortfolioSectionSelected(int index) {
    setState(() {
      _portfolioSectionIndex = index;
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
