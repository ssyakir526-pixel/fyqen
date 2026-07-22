import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../features/dashboard/presentation/pages/dashboard_placeholder_page.dart';

/// The root widget for the Fyqen application.
class FyqenApp extends StatelessWidget {
  const FyqenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const DashboardPlaceholderPage(),
    );
  }
}
