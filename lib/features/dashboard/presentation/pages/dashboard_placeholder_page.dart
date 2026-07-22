import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_title.dart';

/// A temporary screen that validates the initial application composition.
class DashboardPlaceholderPage extends StatelessWidget {
  const DashboardPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: AppPage(
        children: <Widget>[
          Text(
            'FINANCIAL FREEDOM',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionTitle(title: 'Dashboard', subtitle: AppConstants.appSlogan),
          AppSection(
            child: AppCard(
              child: const EmptyState(
                icon: Icons.dashboard_outlined,
                title: 'Your journey starts here',
                message:
                    'Fyqen is being built to help you measure real financial '
                    'progress with clarity and consistency.',
              ),
            ),
          ),
          AppSection(
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SectionTitle(
                    title: 'Interaction foundation',
                    subtitle:
                        'Reusable forms and user-feedback components are ready '
                        'for future features.',
                  ),
                  const AppTextField(
                    label: 'Example field',
                    hintText: 'Future input',
                    enabled: false,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AppButton(label: 'Continue', onPressed: null),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
