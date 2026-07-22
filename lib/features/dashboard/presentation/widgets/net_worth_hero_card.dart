import 'package:flutter/material.dart';

import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/shared/widgets/app_card.dart';

/// A presentation-only hero card for displaying supplied net-worth content.
class NetWorthHeroCard extends StatelessWidget {
  const NetWorthHeroCard({
    super.key,
    required this.hasData,
    this.netWorthLabel,
    this.subtitle,
  });

  final bool hasData;
  final String? netWorthLabel;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (!hasData) {
      return Semantics(
        label:
            'Net worth unavailable. Connect your financial data to begin '
            'tracking your progress.',
        child: const AppCard(child: _UnavailableNetWorthContent()),
      );
    }

    final String displayedLabel = netWorthLabel ?? '';
    final String displayedSubtitle = subtitle ?? '';

    return Semantics(
      label: 'Net Worth: $displayedLabel. $displayedSubtitle',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Net Worth', style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(displayedLabel, style: textTheme.displaySmall),
            if (displayedSubtitle.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(displayedSubtitle, style: textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnavailableNetWorthContent extends StatelessWidget {
  const _UnavailableNetWorthContent();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Net worth unavailable', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Connect your financial data to begin tracking your progress.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}
