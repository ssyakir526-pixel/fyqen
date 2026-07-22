import 'package:flutter/material.dart';

import 'package:fyqen/shared/widgets/feature_placeholder_page.dart';

class PortfolioPlaceholderPage extends StatelessWidget {
  const PortfolioPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Portfolio',
      description:
          'Your assets, liabilities, and real net worth will be managed here.',
      icon: Icons.account_balance_wallet_outlined,
    );
  }
}
