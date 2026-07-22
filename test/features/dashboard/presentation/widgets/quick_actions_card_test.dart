import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/features/dashboard/presentation/widgets/dashboard_quick_action.dart';
import 'package:fyqen/features/dashboard/presentation/widgets/quick_actions_card.dart';

void main() {
  Widget buildTestApp(Widget child, {TextScaler? textScaler}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler ?? TextScaler.noScaling),
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('renders the default empty state without action buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const QuickActionsCard(actions: <DashboardQuickAction>[])),
    );

    expect(find.text('Quick actions unavailable'), findsOneWidget);
    expect(find.text('Quick actions are not available yet.'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders a supplied empty-state message exactly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const QuickActionsCard(
          actions: <DashboardQuickAction>[],
          emptyMessage: 'Supplied empty message.',
        ),
      ),
    );

    expect(find.text('Supplied empty message.'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders and forwards supplied enabled action callbacks', (
    WidgetTester tester,
  ) async {
    int primaryInvocationCount = 0;
    int secondaryInvocationCount = 0;

    await tester.pumpWidget(
      buildTestApp(
        QuickActionsCard(
          actions: <DashboardQuickAction>[
            DashboardQuickAction(
              label: 'Primary supplied action',
              icon: Icons.add_chart,
              onPressed: () => primaryInvocationCount += 1,
            ),
            DashboardQuickAction(
              label: 'Secondary supplied action',
              icon: Icons.remove_circle_outline,
              onPressed: () => secondaryInvocationCount += 1,
            ),
          ],
        ),
      ),
    );

    final Finder primaryButton = find.widgetWithText(
      OutlinedButton,
      'Primary supplied action',
    );
    final Finder secondaryButton = find.widgetWithText(
      OutlinedButton,
      'Secondary supplied action',
    );

    expect(find.text('Quick Actions'), findsOneWidget);
    expect(primaryButton, findsOneWidget);
    expect(secondaryButton, findsOneWidget);
    expect(find.byIcon(Icons.add_chart), findsOneWidget);
    expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    expect(tester.widget<OutlinedButton>(primaryButton).onPressed, isNotNull);
    expect(tester.widget<OutlinedButton>(secondaryButton).onPressed, isNotNull);

    await tester.tap(primaryButton);
    await tester.pump();
    await tester.tap(secondaryButton);
    await tester.pump();

    expect(primaryInvocationCount, 1);
    expect(secondaryInvocationCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders a supplied disabled action safely', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const QuickActionsCard(
          actions: <DashboardQuickAction>[
            DashboardQuickAction(
              label: 'Disabled supplied action',
              icon: Icons.add_chart,
            ),
          ],
        ),
      ),
    );

    final Finder actionButton = find.widgetWithText(
      OutlinedButton,
      'Disabled supplied action',
    );

    expect(actionButton, findsOneWidget);
    expect(find.byIcon(Icons.add_chart), findsOneWidget);
    expect(tester.widget<OutlinedButton>(actionButton).onPressed, isNull);
    await tester.tap(actionButton);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('preserves the supplied action order', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const QuickActionsCard(
          actions: <DashboardQuickAction>[
            DashboardQuickAction(
              label: 'First supplied action',
              icon: Icons.add_chart,
            ),
            DashboardQuickAction(
              label: 'Second supplied action',
              icon: Icons.remove_circle_outline,
            ),
            DashboardQuickAction(
              label: 'Third supplied action',
              icon: Icons.route,
            ),
          ],
        ),
      ),
    );

    final Offset firstPosition = tester.getTopLeft(
      find.text('First supplied action'),
    );
    final Offset secondPosition = tester.getTopLeft(
      find.text('Second supplied action'),
    );
    final Offset thirdPosition = tester.getTopLeft(
      find.text('Third supplied action'),
    );

    expect(firstPosition.dx, lessThan(secondPosition.dx));
    expect(thirdPosition.dy, greaterThan(firstPosition.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('wraps long supplied action labels safely in a narrow layout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        SingleChildScrollView(
          child: SizedBox(
            width: 280,
            child: QuickActionsCard(
              actions: <DashboardQuickAction>[
                const DashboardQuickAction(
                  label:
                      'A long neutral action label supplied by a future feature layer',
                  icon: Icons.add_chart,
                ),
                const DashboardQuickAction(
                  label:
                      'Another long neutral action label supplied by a future feature layer',
                  icon: Icons.remove_circle_outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      find.text(
        'A long neutral action label supplied by a future feature layer',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Another long neutral action label supplied by a future feature layer',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders supplied action labels with large text safely', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const SizedBox(
          width: 280,
          child: QuickActionsCard(
            actions: <DashboardQuickAction>[
              DashboardQuickAction(
                label: 'Long supplied action label for large text',
                icon: Icons.add_chart,
              ),
            ],
          ),
        ),
        textScaler: TextScaler.linear(2),
      ),
    );

    expect(
      find.text('Long supplied action label for large text'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('builds accessible action semantics safely', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    try {
      await tester.pumpWidget(
        buildTestApp(
          const QuickActionsCard(
            actions: <DashboardQuickAction>[
              DashboardQuickAction(
                label: 'Visible supplied action',
                icon: Icons.add_chart,
                semanticLabel: 'Accessible supplied action',
              ),
            ],
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Accessible supplied action'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
