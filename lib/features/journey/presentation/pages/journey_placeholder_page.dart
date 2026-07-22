import 'package:flutter/material.dart';

import 'package:fyqen/shared/widgets/feature_placeholder_page.dart';

class JourneyPlaceholderPage extends StatelessWidget {
  const JourneyPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Journey',
      description:
          'Your progress toward financial freedom will be visualized here.',
      icon: Icons.route_outlined,
    );
  }
}
