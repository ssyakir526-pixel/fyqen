import 'package:flutter/material.dart';

import 'package:fyqen/shared/widgets/feature_placeholder_page.dart';

class BattlePlaceholderPage extends StatelessWidget {
  const BattlePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Battle',
      description:
          'Privacy-preserving net-worth comparisons will be introduced here.',
      icon: Icons.sports_martial_arts_outlined,
    );
  }
}
