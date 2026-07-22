import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'navigation/fyqen_shell.dart';

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
      home: const FyqenShell(),
    );
  }
}
