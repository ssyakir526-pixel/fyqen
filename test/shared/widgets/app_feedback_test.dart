import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/shared/feedback/app_confirmation_dialog.dart';
import 'package:fyqen/shared/feedback/app_snack_bar.dart';
import 'package:fyqen/shared/widgets/app_error_state.dart';
import 'package:fyqen/shared/widgets/app_loading_indicator.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );
  }

  testWidgets('renders loading and error feedback with optional retry', (
    WidgetTester tester,
  ) async {
    var retries = 0;

    await tester.pumpWidget(
      buildTestApp(
        Column(
          children: <Widget>[
            const AppLoadingIndicator(message: 'Loading content'),
            const AppErrorState(
              title: 'Unable to continue',
              message: 'Try later.',
            ),
            AppErrorState(
              title: 'Retry available',
              message: 'Try again now.',
              onRetry: () => retries += 1,
              retryLabel: 'Retry now',
            ),
          ],
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading content'), findsOneWidget);
    expect(find.text('Unable to continue'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
    expect(find.text('Retry now'), findsOneWidget);
    await tester.tap(find.text('Retry now'));
    expect(retries, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows one active snack bar for supplied feedback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const SizedBox()));
    final BuildContext context = tester.element(find.byType(Scaffold));

    AppSnackBar.show(context, message: 'First message');
    await tester.pump();
    AppSnackBar.show(context, message: 'Second message');
    await tester.pump();

    expect(find.text('Second message'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'confirmation dialog returns cancel, confirm, and dismissal intent',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const SizedBox()));
      final BuildContext context = tester.element(find.byType(Scaffold));

      Future<bool> result = showAppConfirmationDialog(
        context,
        title: 'Confirm change',
        message: 'Continue with this action?',
      );
      await tester.pumpAndSettle();
      expect(find.text('Confirm change'), findsOneWidget);
      expect(find.text('Continue with this action?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await result, isFalse);

      result = showAppConfirmationDialog(
        context,
        title: 'Confirm change',
        message: 'Continue with this action?',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(await result, isTrue);

      result = showAppConfirmationDialog(
        context,
        title: 'Confirm change',
        message: 'Continue with this action?',
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(1, 1));
      await tester.pumpAndSettle();
      expect(await result, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
