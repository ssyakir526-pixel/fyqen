import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/presentation/widgets/liability_form.dart';

void main() {
  final DateTime createdAt = DateTime.utc(2026, 1, 1);
  final DateTime updatedAt = DateTime.utc(2026, 1, 2);

  Liability liability() {
    return Liability(
      id: 'liability-1',
      name: 'Synthetic card balance',
      type: LiabilityType.creditCard,
      outstandingBalance: LiabilityAmount(amount: '50', currencyCode: 'MYR'),
      originalAmount: LiabilityAmount(amount: '100', currencyCode: 'MYR'),
      lenderName: 'Synthetic lender',
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  Widget buildForm({
    Liability? initialLiability,
    bool isSaving = false,
    Future<bool> Function(Liability liability)? onSubmit,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: LiabilityForm(
          key: ValueKey<String>(initialLiability?.id ?? 'new-liability-form'),
          initialLiability: initialLiability,
          createLiabilityId: () => 'liability-created',
          currentTime: () => updatedAt,
          isSaving: isSaving,
          onSubmit: onSubmit ?? (Liability liability) async => false,
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

  String fieldText(WidgetTester tester, String key) {
    return tester.widget<EditableText>(editableField(key)).controller.text;
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    final Finder submitButton = find.byKey(
      const Key('liability-submit-button'),
    );
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();
  }

  testWidgets('renders add and edit Liability form states', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildForm());
    expect(find.text('Add Liability'), findsNWidgets(2));

    await tester.pumpWidget(buildForm(initialLiability: liability()));
    expect(find.text('Edit Liability'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(fieldText(tester, 'liability-name-field'), 'Synthetic card balance');
    expect(
      fieldText(tester, 'liability-lender-name-field'),
      'Synthetic lender',
    );
    expect(fieldText(tester, 'liability-balance-field'), '50');
    expect(fieldText(tester, 'liability-original-amount-field'), '100');
    expect(fieldText(tester, 'liability-currency-field'), 'MYR');
    expect(
      tester
          .widget<DropdownButtonFormField<LiabilityType>>(
            find.byKey(const Key('liability-type-field')),
          )
          .initialValue,
      LiabilityType.creditCard,
    );
  });

  testWidgets('validates required name and exact non-negative amounts', (
    WidgetTester tester,
  ) async {
    int submitCallCount = 0;
    await tester.pumpWidget(
      buildForm(
        onSubmit: (Liability liability) async {
          submitCallCount += 1;
          return false;
        },
      ),
    );

    await tapSubmit(tester);
    expect(find.text('Enter a liability name.'), findsOneWidget);
    expect(find.text('Enter a valid non-negative amount.'), findsNWidgets(2));
    expect(submitCallCount, 0);

    await tester.enterText(editableField('liability-name-field'), '   ');
    await tester.enterText(editableField('liability-balance-field'), '-1');
    await tapSubmit(tester);
    expect(find.text('Enter a liability name.'), findsOneWidget);
    expect(find.text('Enter a valid non-negative amount.'), findsNWidgets(2));
    expect(submitCallCount, 0);
  });

  testWidgets(
    'constructs an immutable Liability with deterministic boundaries',
    (WidgetTester tester) async {
      Liability? submitted;
      int submitCallCount = 0;
      await tester.pumpWidget(
        buildForm(
          onSubmit: (Liability liability) async {
            submitted = liability;
            submitCallCount += 1;
            return false;
          },
        ),
      );

      await tester.enterText(
        editableField('liability-name-field'),
        'Test loan',
      );
      await tester.enterText(
        editableField('liability-lender-name-field'),
        'Test lender',
      );
      await tester.enterText(editableField('liability-balance-field'), '12.50');
      await tester.enterText(
        editableField('liability-original-amount-field'),
        '15',
      );
      await tester.enterText(editableField('liability-currency-field'), 'myr');
      await tapSubmit(tester);

      expect(submitted, isNotNull);
      final Liability captured = submitted!;
      expect(submitCallCount, 1);
      expect(captured.id, 'liability-created');
      expect(captured.name, 'Test loan');
      expect(captured.type, LiabilityType.creditCard);
      expect(captured.lenderName, 'Test lender');
      expect(captured.outstandingBalance.amount, '12.5');
      expect(captured.originalAmount.amount, '15');
      expect(captured.outstandingBalance.currencyCode, 'MYR');
      expect(captured.createdAt, updatedAt);
      expect(captured.updatedAt, updatedAt);
      expect(find.byKey(const Key('liability-form')), findsOneWidget);
    },
  );

  testWidgets('saving state disables submission and shows feedback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildForm(isSaving: true));

    expect(
      find.byKey(const Key('liability-form-saving-indicator')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(const Key('liability-submit-button')),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNull,
    );
  });
}
