import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

/// A temporary screen that validates the initial application composition.
class DashboardPlaceholderPage extends StatelessWidget {
  const DashboardPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Dashboard', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                AppConstants.appSlogan,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
