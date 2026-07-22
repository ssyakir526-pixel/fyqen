import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/shared/widgets/app_button.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );
  }

  testWidgets('renders all supported button variants', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        Column(
          children: <Widget>[
            AppButton(label: 'Primary', onPressed: () {}),
            AppButton(
              label: 'Secondary',
              onPressed: () {},
              variant: AppButtonVariant.secondary,
            ),
            AppButton(
              label: 'Text',
              onPressed: () {},
              variant: AppButtonVariant.text,
            ),
          ],
        ),
      ),
    );

    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Secondary'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('enabled button invokes its callback', (
    WidgetTester tester,
  ) async {
    var presses = 0;

    await tester.pumpWidget(
      buildTestApp(
        AppButton(
          label: 'Enabled',
          icon: Icons.check,
          onPressed: () => presses += 1,
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.tap(find.text('Enabled'));
    await tester.pump();

    expect(presses, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disabled button does not invoke its callback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const AppButton(label: 'Disabled', onPressed: null)),
    );

    final FilledButton button = tester.widget<FilledButton>(
      find.byType(FilledButton),
    );

    expect(button.onPressed, isNull);

    await tester.tap(find.text('Disabled'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('loading button is disabled and shows progress indicator', (
    WidgetTester tester,
  ) async {
    var presses = 0;

    await tester.pumpWidget(
      buildTestApp(
        AppButton(
          label: 'Loading',
          icon: Icons.check,
          onPressed: () => presses += 1,
          isLoading: true,
          expand: false,
        ),
      ),
    );

    final FilledButton button = tester.widget<FilledButton>(
      find.byType(FilledButton),
    );

    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(presses, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expanded button renders without overflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        SizedBox(
          width: 320,
          child: AppButton(label: 'Expanded', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Expanded'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
