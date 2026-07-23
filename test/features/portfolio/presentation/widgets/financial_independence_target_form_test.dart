import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';
import 'package:fyqen/features/portfolio/presentation/widgets/financial_independence_target_form.dart';

void main() {
  Widget buildForm({
    FinancialIndependenceTarget? initialTarget,
    Future<bool> Function(FinancialIndependenceTarget target)? onSubmit,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: FinancialIndependenceTargetForm(
          key: ValueKey<String>(initialTarget?.amount ?? 'new-target'),
          initialTarget: initialTarget,
          onSubmit:
              onSubmit ?? (FinancialIndependenceTarget target) async => false,
        ),
      ),
    );
  }

  Finder editableField(String key) {
    return find.descendant(
      of: find.byKey(Key(key)),
      matching: find.byType(EditableText),
    );
  }

  Future<void> submit(WidgetTester tester) async {
    final Finder submitButton = find.byKey(
      const Key('financial-independence-target-submit-button'),
    );
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();
  }

  testWidgets('renders set and edit modes with existing target values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildForm());
    expect(find.text('Set FI Target'), findsOneWidget);

    await tester.pumpWidget(
      buildForm(
        initialTarget: FinancialIndependenceTarget(
          amount: '1000',
          currencyCode: 'MYR',
        ),
      ),
    );
    expect(find.text('Edit FI Target'), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(
            editableField('financial-independence-target-amount-field'),
          )
          .controller
          .text,
      '1000',
    );
    expect(
      tester
          .widget<EditableText>(
            editableField('financial-independence-target-currency-field'),
          )
          .controller
          .text,
      'MYR',
    );
  });

  testWidgets('validates invalid target values without calling back', (
    WidgetTester tester,
  ) async {
    int callCount = 0;
    await tester.pumpWidget(
      buildForm(
        onSubmit: (FinancialIndependenceTarget target) async {
          callCount += 1;
          return false;
        },
      ),
    );

    await submit(tester);
    expect(find.text('Enter your FI target.'), findsOneWidget);
    expect(callCount, 0);

    await tester.enterText(
      editableField('financial-independence-target-amount-field'),
      '0',
    );
    await tester.enterText(
      editableField('financial-independence-target-currency-field'),
      'MYR',
    );
    await submit(tester);
    expect(find.text('FI target must be greater than zero.'), findsOneWidget);
    expect(callCount, 0);
  });

  testWidgets('constructs a normalized target once after valid submission', (
    WidgetTester tester,
  ) async {
    FinancialIndependenceTarget? submitted;
    int callCount = 0;
    await tester.pumpWidget(
      buildForm(
        onSubmit: (FinancialIndependenceTarget target) async {
          submitted = target;
          callCount += 1;
          return false;
        },
      ),
    );

    await tester.enterText(
      editableField('financial-independence-target-amount-field'),
      '1000.50',
    );
    await tester.enterText(
      editableField('financial-independence-target-currency-field'),
      'myr',
    );
    await submit(tester);

    expect(callCount, 1);
    expect(submitted, isNotNull);
    expect(submitted!.amount, '1000.5');
    expect(submitted!.currencyCode, 'MYR');
    expect(
      find.byKey(const Key('financial-independence-target-form')),
      findsOneWidget,
    );
  });
}
