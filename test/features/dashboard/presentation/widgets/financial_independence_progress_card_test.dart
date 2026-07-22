import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/features/dashboard/presentation/widgets/financial_independence_progress_card.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );
  }

  testWidgets('renders the unavailable state without progress', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const FinancialIndependenceProgressCard(hasData: false)),
    );

    expect(find.text('Progress unavailable'), findsOneWidget);
    expect(
      find.text('Your journey progress will appear here after setup.'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders all supplied available-state values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const FinancialIndependenceProgressCard(
          hasData: true,
          progress: 0.4,
          progressLabel: 'Setup progress',
          currentValueLabel: 'Current value supplied',
          targetValueLabel: 'Target value supplied',
          subtitle: 'Progress values are supplied by a future feature layer.',
        ),
      ),
    );

    final LinearProgressIndicator progressIndicator = tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));

    expect(find.text('Financial Independence'), findsOneWidget);
    expect(find.text('Setup progress'), findsOneWidget);
    expect(progressIndicator.value, 0.4);
    expect(find.text('Current value supplied'), findsOneWidget);
    expect(find.text('Target value supplied'), findsOneWidget);
    expect(
      find.text('Progress values are supplied by a future feature layer.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('handles missing optional values without misleading blocks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const FinancialIndependenceProgressCard(hasData: true)),
    );

    expect(find.text('Financial Independence'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('Current'), findsNothing);
    expect(find.text('Target'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wraps long supplied labels safely in a narrow layout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const SizedBox(
          width: 280,
          child: FinancialIndependenceProgressCard(
            hasData: true,
            currentValueLabel:
                'A long neutral current value supplied by a future feature layer',
            targetValueLabel:
                'A long neutral target value supplied by a future feature layer',
          ),
        ),
      ),
    );

    expect(
      find.text(
        'A long neutral current value supplied by a future feature layer',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'A long neutral target value supplied by a future feature layer',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('builds a semantic tree safely', (WidgetTester tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    try {
      await tester.pumpWidget(
        buildTestApp(
          const FinancialIndependenceProgressCard(
            hasData: true,
            progressLabel: 'Setup progress',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
