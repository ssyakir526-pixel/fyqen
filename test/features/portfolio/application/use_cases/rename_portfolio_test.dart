import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/portfolio/application/use_cases/rename_portfolio.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

void main() {
  Portfolio createPortfolio() => Portfolio(
    id: 'portfolio-1',
    name: 'Main',
    assets: const [],
    liabilities: const [],
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test('delegates rename and preserves immutable aggregate identity', () {
    final Portfolio original = createPortfolio();
    final Portfolio updated = const RenamePortfolioUseCase()(
      portfolio: original,
      name: 'Updated',
      updatedAt: DateTime.utc(2026, 1, 2),
    );

    expect(updated.name, 'Updated');
    expect(identical(updated, original), isFalse);
    expect(updated, original);
    expect(original.name, 'Main');
    expect(updated.createdAt, original.createdAt);
    expect(
      () => const RenamePortfolioUseCase()(
        portfolio: original,
        name: '',
        updatedAt: DateTime.utc(2026, 1, 2),
      ),
      throwsArgumentError,
    );
  });
}
