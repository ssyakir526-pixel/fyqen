import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/portfolio/application/use_cases/set_financial_independence_target.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';

void main() {
  test('sets a target without changing Portfolio identity or collections', () {
    final DateTime timestamp = DateTime.utc(2026);
    final Portfolio original = Portfolio(
      id: 'primary',
      name: 'My Portfolio',
      assets: const <Asset>[],
      liabilities: const <Liability>[],
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    final FinancialIndependenceTarget target = FinancialIndependenceTarget(
      amount: '1000',
      currencyCode: 'MYR',
    );
    final DateTime updatedAt = timestamp.add(const Duration(days: 1));
    final Portfolio updated = const SetFinancialIndependenceTargetUseCase()(
      portfolio: original,
      target: target,
      updatedAt: updatedAt,
    );

    expect(updated, isNot(same(original)));
    expect(updated.id, original.id);
    expect(updated.name, original.name);
    expect(updated.createdAt, original.createdAt);
    expect(updated.updatedAt, updatedAt);
    expect(updated.financialIndependenceTarget, target);
    expect(updated.assets, equals(original.assets));
    expect(updated.assets, hasLength(original.assets.length));
    expect(updated.liabilities, equals(original.liabilities));
    expect(updated.liabilities, hasLength(original.liabilities.length));
  });
}
