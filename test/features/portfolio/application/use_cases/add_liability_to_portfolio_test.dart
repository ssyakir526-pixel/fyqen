import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/application/use_cases/add_liability_to_portfolio.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

void main() {
  Liability createLiability(String id) => Liability(id: id, name: id, type: LiabilityType.personalLoan, outstandingBalance: LiabilityAmount(amount: '1', currencyCode: 'MYR'), originalAmount: LiabilityAmount(amount: '1', currencyCode: 'MYR'), createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026));

  test('delegates liability append and propagates duplicate errors', () {
    final Liability existing = createLiability('liability-1');
    final Liability added = createLiability('liability-2');
    final Portfolio original = Portfolio(id: 'portfolio-1', name: 'Main', assets: const [], liabilities: <Liability>[existing], createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026));
    final Portfolio updated = const AddLiabilityToPortfolioUseCase()(portfolio: original, liability: added, updatedAt: DateTime.utc(2026, 1, 2));

    expect(updated.liabilities, <Liability>[existing, added]);
    expect(identical(updated.liabilities.last, added), isTrue);
    expect(original.liabilities, <Liability>[existing]);
    expect(() => updated.liabilities.clear(), throwsUnsupportedError);
    expect(() => const AddLiabilityToPortfolioUseCase()(portfolio: original, liability: existing, updatedAt: DateTime.utc(2026, 1, 2)), throwsArgumentError);
  });
}
