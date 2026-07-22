import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/features/dashboard/presentation/widgets/net_worth_hero_card.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );
  }

  testWidgets('renders the unavailable state without numeric content', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    try {
      await tester.pumpWidget(
        buildTestApp(const NetWorthHeroCard(hasData: false)),
      );

      expect(find.text('Net worth unavailable'), findsOneWidget);
      expect(
        find.text(
          'Connect your financial data to begin tracking your progress.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('renders supplied available-state content without overflow', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    try {
      await tester.pumpWidget(
        buildTestApp(
          const NetWorthHeroCard(
            hasData: true,
            netWorthLabel: 'Available after connection',
            subtitle: 'This supplied value is presentation-only.',
          ),
        ),
      );

      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.text('Available after connection'), findsOneWidget);
      expect(
        find.text('This supplied value is presentation-only.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
