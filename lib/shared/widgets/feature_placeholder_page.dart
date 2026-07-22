import 'package:flutter/material.dart';

import 'app_card.dart';
import 'app_page.dart';
import 'app_section.dart';
import 'empty_state.dart';
import 'section_title.dart';

/// A consistent temporary page for primary destinations under construction.
class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppPage(
        children: <Widget>[
          SectionTitle(title: title),
          AppSection(
            child: AppCard(
              child: EmptyState(
                icon: icon,
                title: 'Coming later',
                message: description,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
