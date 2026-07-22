import 'package:flutter/material.dart';

import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/shared/widgets/app_card.dart';

/// A presentation-only card for supplied financial journey information.
class JourneyOverviewCard extends StatelessWidget {
  const JourneyOverviewCard({
    required this.hasData,
    super.key,
    this.stageLabel,
    this.nextStepTitle,
    this.description,
    this.progress,
    this.progressLabel,
  }) : assert(progress == null || (progress >= 0 && progress <= 1));

  final bool hasData;
  final String? stageLabel;
  final String? nextStepTitle;
  final String? description;
  final double? progress;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) {
    if (!hasData) {
      return Semantics(
        label:
            'Journey unavailable. Complete your setup to see your current '
            'stage and next direction.',
        child: const AppCard(child: _UnavailableJourneyContent()),
      );
    }

    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool hasOptionalContent =
        _hasText(stageLabel) ||
        _hasText(nextStepTitle) ||
        _hasText(description) ||
        progress != null ||
        _hasText(progressLabel);
    final List<String> semanticParts = <String>['Journey'];

    if (stageLabel case final String stageLabel when stageLabel.isNotEmpty) {
      semanticParts.add('Current stage: $stageLabel');
    }
    if (nextStepTitle case final String nextStepTitle
        when nextStepTitle.isNotEmpty) {
      semanticParts.add('Next direction: $nextStepTitle');
    }
    if (progressLabel case final String progressLabel
        when progressLabel.isNotEmpty) {
      semanticParts.add(progressLabel);
    }
    if (description case final String description when description.isNotEmpty) {
      semanticParts.add(description);
    }
    if (!hasOptionalContent) {
      semanticParts.add('Journey details are not available yet');
    }

    return Semantics(
      label: semanticParts.join('. '),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Journey', style: textTheme.labelLarge),
            if (!hasOptionalContent) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Journey details are not available yet.',
                style: textTheme.bodyMedium,
              ),
            ],
            if (stageLabel case final String stageLabel
                when stageLabel.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text('Current stage', style: textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(stageLabel, style: textTheme.bodyLarge),
            ],
            if (nextStepTitle case final String nextStepTitle
                when nextStepTitle.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text('Next direction', style: textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(nextStepTitle, style: textTheme.bodyLarge),
            ],
            if (_hasText(progressLabel) || progress != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              if (progressLabel case final String progressLabel
                  when progressLabel.isNotEmpty)
                Text(progressLabel, style: textTheme.bodySmall),
              if (_hasText(progressLabel) && progress != null)
                const SizedBox(height: AppSpacing.xs),
              if (progress != null) LinearProgressIndicator(value: progress),
            ],
            if (description case final String description
                when description.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(description, style: textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  static bool _hasText(String? value) => value != null && value.isNotEmpty;
}

class _UnavailableJourneyContent extends StatelessWidget {
  const _UnavailableJourneyContent();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Journey unavailable', style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Complete your setup to see your current stage and next direction.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}
