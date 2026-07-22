import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/app/navigation/fyqen_shell.dart';
import 'package:fyqen/core/theme/app_theme.dart';

void main() {
  Widget buildShell() {
    return MaterialApp(theme: AppTheme.dark, home: const FyqenShell());
  }

  testWidgets('switches between all primary destinations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildShell());

    expect(find.byKey(const Key('dashboard_destination')), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expectNavigationSelection(tester, 0);

    await selectDestination(tester, 'portfolio_destination');
    expect(
      find.text(
        'Your assets, liabilities, and real net worth will be managed here.',
      ),
      findsOneWidget,
    );
    expectNavigationSelection(tester, 1);

    await selectDestination(tester, 'journey_destination');
    expect(
      find.text(
        'Your progress toward financial freedom will be visualized here.',
      ),
      findsOneWidget,
    );
    expectNavigationSelection(tester, 2);

    await selectDestination(tester, 'history_destination');
    expect(
      find.text(
        'Your financial progress and investment activity will be reviewed here.',
      ),
      findsOneWidget,
    );
    expectNavigationSelection(tester, 3);

    await selectDestination(tester, 'battle_destination');
    expect(
      find.text(
        'Privacy-preserving net-worth comparisons will be introduced here.',
      ),
      findsOneWidget,
    );
    expectNavigationSelection(tester, 4);

    await selectDestination(tester, 'settings_destination');
    expect(
      find.text(
        'Account preferences and future theme options will be managed here.',
      ),
      findsOneWidget,
    );
    expectNavigationSelection(tester, 5);

    await selectDestination(tester, 'dashboard_destination');
    expect(find.text('Welcome back'), findsOneWidget);
    expectNavigationSelection(tester, 0);

    expect(tester.takeException(), isNull);
  });

  testWidgets('preserves the primary destination stack while switching tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildShell());

    final IndexedStack initialStack = tester.widget<IndexedStack>(
      find.byType(IndexedStack),
    );

    final List<Widget> initialChildren = initialStack.children;

    expect(initialStack.children, hasLength(6));
    expect(initialStack.index, 0);

    await selectDestination(tester, 'portfolio_destination');

    final IndexedStack updatedStack = tester.widget<IndexedStack>(
      find.byType(IndexedStack),
    );

    expect(updatedStack.index, 1);
    expect(updatedStack.children, same(initialChildren));
  });
}

Future<void> selectDestination(WidgetTester tester, String keyName) async {
  await tester.tap(find.byKey(Key(keyName)));
  await tester.pumpAndSettle();
}

void expectNavigationSelection(WidgetTester tester, int expectedIndex) {
  final NavigationBar navigationBar = tester.widget<NavigationBar>(
    find.byKey(const Key('fyqen_navigation_bar')),
  );

  expect(navigationBar.selectedIndex, expectedIndex);
}
