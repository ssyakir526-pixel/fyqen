import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/application/use_cases/remove_liability_from_portfolio.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

void main() {
  Liability createLiability(String id) => Liability(
    id: id,
    name: id,
    type: LiabilityType.personalLoan,
    outstandingBalance: LiabilityAmount(amount: '1', currencyCode: 'MYR'),
    originalAmount: LiabilityAmount(amount: '1', currencyCode: 'MYR'),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test('delegates liability removal with aggregate ID normalization', () {
    final Liability liability = createLiability('Liability-1');
    final Portfolio original = Portfolio(
      id: 'portfolio-1',
      name: 'Main',
      assets: const [],
      liabilities: <Liability>[liability],
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final Portfolio updated = const RemoveLiabilityFromPortfolioUseCase()(
      portfolio: original,
      liabilityId: ' Liability-1 ',
      updatedAt: DateTime.utc(2026),
    );

    expect(updated.liabilities, isEmpty);
    expect(original.liabilities, <Liability>[liability]);
    expect(
      () => const RemoveLiabilityFromPortfolioUseCase()(
        portfolio: original,
        liabilityId: 'liability-1',
        updatedAt: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
    expect(
      () => const RemoveLiabilityFromPortfolioUseCase()(
        portfolio: original,
        liabilityId: '   ',
        updatedAt: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
  });
}
