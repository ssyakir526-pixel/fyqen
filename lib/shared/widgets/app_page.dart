import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Provides the responsive, scrollable content area used by Fyqen pages.
class AppPage extends StatelessWidget {
  const AppPage({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double horizontalPadding = constraints.maxWidth >= 600
              ? AppSpacing.lg
              : AppSpacing.md;

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppSpacing.xl,
              horizontalPadding,
              AppSpacing.xl + keyboardInset,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
