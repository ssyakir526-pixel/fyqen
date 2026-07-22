import 'package:flutter/material.dart';

/// Metadata for Fyqen's primary navigation destinations.
enum FyqenDestination {
  dashboard(
    label: 'Dashboard',
    selectedIcon: Icons.dashboard_rounded,
    unselectedIcon: Icons.dashboard_outlined,
  ),
  portfolio(
    label: 'Portfolio',
    selectedIcon: Icons.account_balance_wallet_rounded,
    unselectedIcon: Icons.account_balance_wallet_outlined,
  ),
  journey(
    label: 'Journey',
    selectedIcon: Icons.route_rounded,
    unselectedIcon: Icons.route_outlined,
  ),
  history(
    label: 'History',
    selectedIcon: Icons.history_rounded,
    unselectedIcon: Icons.history_outlined,
  ),
  battle(
    label: 'Battle',
    selectedIcon: Icons.sports_martial_arts_rounded,
    unselectedIcon: Icons.sports_martial_arts_outlined,
  ),
  settings(
    label: 'Settings',
    selectedIcon: Icons.settings_rounded,
    unselectedIcon: Icons.settings_outlined,
  );

  const FyqenDestination({
    required this.label,
    required this.selectedIcon,
    required this.unselectedIcon,
  });

  final String label;
  final IconData selectedIcon;
  final IconData unselectedIcon;
}
