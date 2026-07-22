import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/dashboard/presentation/pages/dashboard_placeholder_page.dart';

/// The root widget for the Fyqen application.
class FyqenApp extends StatelessWidget {
  const FyqenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const DashboardPlaceholderPage(),
    );
  }
}
