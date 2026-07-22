import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/core/theme/app_colors.dart';
import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/shared/widgets/app_card.dart';
import 'package:fyqen/shared/widgets/app_page.dart';
import 'package:fyqen/shared/widgets/empty_state.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );
  }

  testWidgets('AppPage renders supplied children in the themed page layout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const AppPage(children: <Widget>[Text('Page content')])),
    );

    expect(find.text('Page content'), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppCard accepts child content and uses the active card theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const AppCard(child: Text('Card content'))),
    );

    final BuildContext cardContext = tester.element(find.byType(Card));
    expect(find.text('Card content'), findsOneWidget);
    expect(CardTheme.of(cardContext).color, AppColors.surface);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EmptyState renders its supplied icon and message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Nothing here yet',
          message: 'Content will appear here when it is available.',
        ),
      ),
    );

    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(
      find.text('Content will appear here when it is available.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
