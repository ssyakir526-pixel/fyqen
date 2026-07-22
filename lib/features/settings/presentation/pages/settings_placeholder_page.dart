import 'package:flutter/material.dart';

import 'package:fyqen/shared/widgets/feature_placeholder_page.dart';

class SettingsPlaceholderPage extends StatelessWidget {
  const SettingsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Settings',
      description:
          'Account preferences and future theme options will be managed here.',
      icon: Icons.settings_outlined,
    );
  }
}
