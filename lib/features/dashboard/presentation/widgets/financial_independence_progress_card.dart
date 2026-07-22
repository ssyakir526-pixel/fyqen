import 'package:flutter/material.dart';

import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/shared/widgets/app_card.dart';

/// A presentation-only card for supplied financial-independence progress data.
class FinancialIndependenceProgressCard extends StatelessWidget {
  const FinancialIndependenceProgressCard({
    required this.hasData,
    super.key,
    this.progress,
    this.progressLabel,
    this.currentValueLabel,
    this.targetValueLabel,
    this.subtitle,
  }) : assert(progress == null || (progress >= 0 && progress <= 1));

  final bool hasData;
  final double? progress;
  final String? progressLabel;
  final String? currentValueLabel;
  final String? targetValueLabel;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    if (!hasData) {
      return Semantics(
        label:
            'Progress unavailable. Your journey progress will appear here '
            'after setup.',
        child: const AppCard(child: _UnavailableProgressContent()),
      );
    }

    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<String> semanticParts = <String>['Financial Independence'];

    if (progressLabel case final String progressLabel
        when progressLabel.isNotEmpty) {
      semanticParts.add(progressLabel);
    }

    if (currentValueLabel case final String currentValueLabel
        when currentValueLabel.isNotEmpty) {
      semanticParts.add('Current: $currentValueLabel');
    }

    if (targetValueLabel case final String targetValueLabel
        when targetValueLabel.isNotEmpty) {
      semanticParts.add('Target: $targetValueLabel');
    }

    if (subtitle case final String subtitle when subtitle.isNotEmpty) {
      semanticParts.add(subtitle);
    }

    return Semantics(
      label: semanticParts.join('. '),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                Text('Financial Independence', style: textTheme.labelLarge),
                if (progressLabel case final String progressLabel
                    when progressLabel.isNotEmpty)
                  Text(progressLabel, style: textTheme.bodySmall),
              ],
            ),
            if (progress != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(value: progress),
            ],
            if (_hasText(currentValueLabel) ||
                _hasText(targetValueLabel)) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.md,
                children: <Widget>[
                  if (currentValueLabel case final String currentValueLabel
                      when currentValueLabel.isNotEmpty)
                    _ValueSummary(label: 'Current', value: currentValueLabel),
                  if (targetValueLabel case final String targetValueLabel
                      when targetValueLabel.isNotEmpty)
                    _ValueSummary(label: 'Target', value: targetValueLabel),
                ],
              ),
            ],
            if (subtitle case final String subtitle
                when subtitle.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(subtitle, style: textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  static bool _hasText(String? value) {
    return value != null && value.isNotEmpty;
  }
}

class _UnavailableProgressContent extends StatelessWidget {
  const _UnavailableProgressContent();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Progress unavailable', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your journey progress will appear here after setup.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ValueSummary extends StatelessWidget {
  const _ValueSummary({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(value, style: textTheme.bodyLarge),
      ],
    );
  }
}
