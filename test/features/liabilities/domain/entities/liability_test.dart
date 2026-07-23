import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';

void main() {
  Liability createLiability({
    String id = ' liability-1 ',
    String name = ' Car Loan ',
    LiabilityType type = LiabilityType.vehicleLoan,
    LiabilityAmount? outstandingBalance,
    LiabilityAmount? originalAmount,
    String? lenderName = ' Maybank ',
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
  }) {
    final DateTime creationTime = createdAt ?? DateTime(2026, 1, 1, 8);

    return Liability(
      id: id,
      name: name,
      type: type,
      outstandingBalance:
          outstandingBalance ??
          LiabilityAmount(amount: '100', currencyCode: 'MYR'),
      originalAmount:
          originalAmount ?? LiabilityAmount(amount: '100', currencyCode: 'MYR'),
      createdAt: creationTime,
      updatedAt: updatedAt ?? creationTime,
      lenderName: lenderName,
      dueDate: dueDate,
    );
  }

  group('Liability', () {
    test('creates a normalized immutable entity', () {
      final Liability liability = createLiability();

      expect(liability.id, 'liability-1');
      expect(liability.name, 'Car Loan');
      expect(liability.lenderName, 'Maybank');
      expect(liability.type, LiabilityType.vehicleLoan);
    });

    test(
      'normalizes optional lender names without changing capitalization',
      () {
        expect(createLiability(lenderName: ' cImB ').lenderName, 'cImB');
        expect(createLiability(lenderName: '').lenderName, isNull);
        expect(createLiability(lenderName: '  ').lenderName, isNull);
        expect(createLiability(lenderName: null).lenderName, isNull);
      },
    );

    test('normalizes supplied dates to UTC', () {
      final DateTime timestamp = DateTime(2026, 1, 1, 8);
      final DateTime historicalDueDate = DateTime(2020, 1, 1, 8);
      final Liability liability = createLiability(
        createdAt: timestamp,
        updatedAt: timestamp,
        dueDate: historicalDueDate,
      );

      expect(liability.createdAt.isUtc, isTrue);
      expect(liability.updatedAt.isUtc, isTrue);
      expect(liability.dueDate!.isUtc, isTrue);
      expect(liability.createdAt, liability.updatedAt);
      expect(liability.dueDate!.isBefore(liability.createdAt), isTrue);
    });

    test('accepts null and historical due dates', () {
      expect(createLiability(dueDate: null).dueDate, isNull);
      expect(
        createLiability(dueDate: DateTime.utc(2020, 1, 1)).dueDate,
        DateTime.utc(2020, 1, 1),
      );
    });

    test(
      'rejects empty identity, name, invalid order, and currency mismatch',
      () {
        expect(() => createLiability(id: ''), throwsArgumentError);
        expect(() => createLiability(id: '  '), throwsArgumentError);
        expect(() => createLiability(name: ''), throwsArgumentError);
        expect(() => createLiability(name: '  '), throwsArgumentError);
        expect(
          () => createLiability(
            createdAt: DateTime.utc(2026, 1, 2),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
          throwsArgumentError,
        );
        expect(
          () => createLiability(
            outstandingBalance: LiabilityAmount(
              amount: '1',
              currencyCode: 'MYR',
            ),
            originalAmount: LiabilityAmount(amount: '1', currencyCode: 'USD'),
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'accepts matching normalized currencies and unrestricted balances',
      () {
        final Liability liability = createLiability(
          outstandingBalance: LiabilityAmount(
            amount: '200',
            currencyCode: 'myr',
          ),
          originalAmount: LiabilityAmount(amount: '0', currencyCode: 'MYR'),
        );

        expect(liability.outstandingBalance.currencyCode, 'MYR');
        expect(liability.originalAmount.amount, '0');
        expect(liability.outstandingBalance.amount, '200');
      },
    );

    test('allows zero outstanding and original amounts', () {
      final Liability liability = createLiability(
        outstandingBalance: LiabilityAmount(amount: '0', currencyCode: 'MYR'),
        originalAmount: LiabilityAmount(amount: '0', currencyCode: 'MYR'),
      );

      expect(liability.outstandingBalance.amount, '0');
      expect(liability.originalAmount.amount, '0');
    });

    test('uses normalized ID-only entity equality', () {
      final Liability first = createLiability();
      final Liability sameIdWithDifferentFields = createLiability(
        id: 'liability-1',
        name: 'Different name',
        type: LiabilityType.creditCard,
        outstandingBalance: LiabilityAmount(amount: '50', currencyCode: 'MYR'),
        originalAmount: LiabilityAmount(amount: '100', currencyCode: 'MYR'),
        lenderName: 'Different lender',
        dueDate: DateTime.utc(2030, 1, 1),
      );
      final Liability differentId = createLiability(id: 'liability-2');

      expect(first, sameIdWithDifferentFields);
      expect(first.hashCode, sameIdWithDifferentFields.hashCode);
      expect(first, isNot(differentId));
    });

    test('has a concise developer-readable string representation', () {
      final String description = createLiability().toString();

      expect(description, contains('liability-1'));
      expect(description, contains('Car Loan'));
      expect(description, contains('LiabilityType.vehicleLoan'));
      expect(description, isNot(contains('outstandingBalance')));
      expect(description, isNot(contains('originalAmount')));
      expect(description, isNot(contains('lenderName')));
      expect(description, isNot(contains('dueDate')));
    });
  });
}
