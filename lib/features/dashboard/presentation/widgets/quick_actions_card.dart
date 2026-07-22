import 'package:flutter/material.dart';

import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/shared/widgets/app_card.dart';

import 'dashboard_quick_action.dart';

/// A presentation-only card that renders supplied Dashboard quick actions.
class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({
    required this.actions,
    super.key,
    this.emptyMessage = 'Quick actions are not available yet.',
  });

  final List<DashboardQuickAction> actions;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return Semantics(
        container: true,
        label: _emptySemanticLabel,
        child: AppCard(
          child: _EmptyQuickActionsContent(emptyMessage: emptyMessage),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Quick Actions', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool canShowTwoColumns = constraints.maxWidth >= 520;

              final double actionWidth = canShowTwoColumns
                  ? (constraints.maxWidth - AppSpacing.md) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: actions
                    .map(
                      (DashboardQuickAction action) => SizedBox(
                        width: actionWidth,
                        child: _QuickActionButton(action: action),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String get _emptySemanticLabel {
    if (emptyMessage.isEmpty) {
      return 'Quick actions unavailable';
    }

    return 'Quick actions unavailable. $emptyMessage';
  }
}

class _EmptyQuickActionsContent extends StatelessWidget {
  const _EmptyQuickActionsContent({required this.emptyMessage});

  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Quick actions unavailable', style: textTheme.titleLarge),
        if (emptyMessage.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(emptyMessage, style: textTheme.bodyMedium),
        ],
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action});

  final DashboardQuickAction action;

  @override
  Widget build(BuildContext context) {
    final Widget button = OutlinedButton(
      onPressed: action.onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(action.icon),
          const SizedBox(width: AppSpacing.xs),
          Flexible(child: Text(action.label)),
        ],
      ),
    );

    final String? semanticLabel = action.semanticLabel;

    if (semanticLabel != null && semanticLabel.isNotEmpty) {
      return Semantics(
        container: true,
        label: semanticLabel,
        button: true,
        enabled: action.onPressed != null,
        excludeSemantics: true,
        onTap: action.onPressed,
        child: button,
      );
    }

    return button;
  }
}
