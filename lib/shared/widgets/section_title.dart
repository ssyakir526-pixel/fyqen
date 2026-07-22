import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A responsive heading for a page or major section.
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: textTheme.displaySmall),
                if (subtitle case final String subtitle) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: textTheme.bodyLarge),
                ],
              ],
            ),
          ),
          if (trailing case final Widget trailing) ...<Widget>[
            const SizedBox(width: AppSpacing.md),
            Flexible(child: trailing),
          ],
        ],
      ),
    );
  }
}
