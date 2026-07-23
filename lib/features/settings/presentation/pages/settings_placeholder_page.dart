import 'package:flutter/material.dart';

import 'package:fyqen/shared/widgets/app_card.dart';
import 'package:fyqen/shared/widgets/app_page.dart';
import 'package:fyqen/shared/widgets/app_section.dart';
import 'package:fyqen/shared/widgets/empty_state.dart';
import 'package:fyqen/shared/widgets/section_title.dart';

class SettingsPlaceholderPage extends StatelessWidget {
  const SettingsPlaceholderPage({super.key, this.onSignOut});

  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: AppPage(
        children: <Widget>[
          const SectionTitle(title: 'Settings'),
          AppSection(
            child: AppCard(
              child: Column(
                children: <Widget>[
                  const EmptyState(
                    icon: Icons.settings_outlined,
                    title: 'Coming later',
                    message:
                        'Account preferences and future theme options will be managed here.',
                  ),
                  if (onSignOut != null)
                    OutlinedButton.icon(
                      key: const Key('sign_out_action'),
                      onPressed: onSignOut,
                      icon: const Icon(Icons.logout_outlined),
                      label: const Text('Sign out'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
