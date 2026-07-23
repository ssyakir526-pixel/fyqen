import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/application/use_cases/replace_liability_in_portfolio.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

void main() {
  Liability createLiability(String id, String name) => Liability(
    id: id,
    name: name,
    type: LiabilityType.personalLoan,
    outstandingBalance: LiabilityAmount(amount: '1', currencyCode: 'MYR'),
    originalAmount: LiabilityAmount(amount: '1', currencyCode: 'MYR'),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test(
    'delegates in-place liability replacement and propagates missing IDs',
    () {
      final Liability first = createLiability('liability-1', 'First');
      final Liability second = createLiability('liability-2', 'Second');
      final Liability replacement = createLiability(
        'liability-1',
        'Replacement',
      );
      final Portfolio original = Portfolio(
        id: 'portfolio-1',
        name: 'Main',
        assets: const [],
        liabilities: <Liability>[first, second],
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      final Portfolio updated = const ReplaceLiabilityInPortfolioUseCase()(
        portfolio: original,
        liability: replacement,
        updatedAt: DateTime.utc(2026),
      );

      expect(updated.liabilities, <Liability>[replacement, second]);
      expect(identical(updated.liabilities.first, replacement), isTrue);
      expect(original.liabilities, <Liability>[first, second]);
      expect(
        () => const ReplaceLiabilityInPortfolioUseCase()(
          portfolio: original,
          liability: createLiability('missing', 'Missing'),
          updatedAt: DateTime.utc(2026),
        ),
        throwsArgumentError,
      );
    },
  );
}
