import 'package:flutter/material.dart';

import '../../features/battle/presentation/pages/battle_placeholder_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_placeholder_page.dart';
import '../../features/history/presentation/pages/history_placeholder_page.dart';
import '../../features/journey/presentation/pages/journey_placeholder_page.dart';
import '../../features/portfolio/domain/entities/portfolio.dart';
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
  });

  final VoidCallback? onSignOut;
  final Portfolio? portfolio;
  final bool isPortfolioSaving;

  @override
  State<FyqenShell> createState() => _FyqenShellState();
}

final class _FyqenShellState extends State<FyqenShell> {
  late final List<Widget> _pages;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      DashboardPlaceholderPage(
        portfolio: widget.portfolio,
        isPortfolioSaving: widget.isPortfolioSaving,
      ),
      const PortfolioPlaceholderPage(),
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
