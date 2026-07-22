import 'package:flutter/material.dart';

import 'package:fyqen/shared/widgets/feature_placeholder_page.dart';

class HistoryPlaceholderPage extends StatelessWidget {
  const HistoryPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'History',
      description:
          'Your financial progress and investment activity will be reviewed here.',
      icon: Icons.history_outlined,
    );
  }
}
