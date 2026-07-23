import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/dashboard/presentation/models/dashboard_portfolio_summary.dart';
import 'package:fyqen/features/dashboard/presentation/models/financial_freedom_level_summary.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';

void main() {
  final DateTime timestamp = DateTime.utc(2026);

  Portfolio portfolio({
    String? netWorth,
    String? liabilityAmount,
    String? targetAmount,
    String assetCurrency = 'MYR',
    String liabilityCurrency = 'MYR',
  }) {
    final List<Asset> assets = netWorth == null
        ? const <Asset>[]
        : <Asset>[
            Asset(
              id: 'asset-1',
              name: 'Synthetic asset',
              type: AssetType.cash,
              quantity: AssetQuantity('1'),
              unitPrice: AssetUnitPrice(
                amount: netWorth,
                currencyCode: assetCurrency,
              ),
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          ];
    final List<Liability> liabilities = liabilityAmount == null
        ? const <Liability>[]
        : <Liability>[
            Liability(
              id: 'liability-1',
              name: 'Synthetic liability',
              type: LiabilityType.creditCard,
              outstandingBalance: LiabilityAmount(
                amount: liabilityAmount,
                currencyCode: liabilityCurrency,
              ),
              originalAmount: LiabilityAmount(
                amount: liabilityAmount,
                currencyCode: liabilityCurrency,
              ),
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          ];
    return Portfolio(
      id: 'primary',
      name: 'My Portfolio',
      assets: assets,
      liabilities: liabilities,
      financialIndependenceTarget: targetAmount == null
          ? null
          : FinancialIndependenceTarget(
              amount: targetAmount,
              currencyCode: 'MYR',
            ),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  FinancialFreedomLevelSummary level(Portfolio portfolio) {
    return FinancialFreedomLevelSummary.fromDashboardSummary(
      DashboardPortfolioSummary.fromPortfolio(portfolio),
    );
  }

  test('is unavailable with no target or mixed currencies', () {
    expect(level(portfolio()).isAvailable, isFalse);
    expect(
      level(
        portfolio(
          netWorth: '100',
          liabilityAmount: '1',
          targetAmount: '1000',
          liabilityCurrency: 'USD',
        ),
      ).isAvailable,
      isFalse,
    );
  });

  test('keeps negative and zero comparable net worth at Level 1', () {
    final FinancialFreedomLevelSummary negative = level(
      portfolio(liabilityAmount: '10', targetAmount: '1000'),
    );
    final FinancialFreedomLevelSummary zero = level(
      portfolio(targetAmount: '1000'),
    );

    expect(negative.currentLevel, 1);
    expect(negative.progressToNextLevelLabel, '0% toward Level 2');
    expect(zero.currentLevel, 1);
    expect(zero.progressToNextLevelLabel, '0% toward Level 2');
  });

  test('handles the Level 1 interval and exact Level 2 boundary', () {
    final FinancialFreedomLevelSummary belowOne = level(
      portfolio(netWorth: '500', targetAmount: '100000'),
    );
    final FinancialFreedomLevelSummary onePercent = level(
      portfolio(netWorth: '1000', targetAmount: '100000'),
    );
    final FinancialFreedomLevelSummary belowTwo = level(
      portfolio(netWorth: '1999.99', targetAmount: '100000'),
    );
    final FinancialFreedomLevelSummary twoPercent = level(
      portfolio(netWorth: '2000', targetAmount: '100000'),
    );

    expect(belowOne.currentLevel, 1);
    expect(belowOne.progressToNextLevelLabel, '25% toward Level 2');
    expect(onePercent.progressToNextLevelLabel, '50% toward Level 2');
    expect(belowTwo.currentLevel, 1);
    expect(belowTwo.progressToNextLevelRatio, lessThan(1));
    expect(twoPercent.currentLevel, 2);
    expect(twoPercent.progressToNextLevelLabel, '0% toward Level 3');
  });

  test('handles standard, maximum, and very large exact boundaries', () {
    final FinancialFreedomLevelSummary exactTwentyFive = level(
      portfolio(netWorth: '25000', targetAmount: '100000'),
    );
    final FinancialFreedomLevelSummary partial = level(
      portfolio(netWorth: '25400', targetAmount: '100000'),
    );
    final FinancialFreedomLevelSummary belowTwentySix = level(
      portfolio(netWorth: '25999.99', targetAmount: '100000'),
    );
    final FinancialFreedomLevelSummary ninetyNine = level(
      portfolio(netWorth: '99500', targetAmount: '100000'),
    );
    final FinancialFreedomLevelSummary exactNinetyNine = level(
      portfolio(netWorth: '99000', targetAmount: '100000'),
    );
    final FinancialFreedomLevelSummary maximum = level(
      portfolio(netWorth: '100000', targetAmount: '100000'),
    );
    final FinancialFreedomLevelSummary aboveMaximum = level(
      portfolio(netWorth: '150000', targetAmount: '100000'),
    );
    final FinancialFreedomLevelSummary large = level(
      portfolio(
        netWorth: '250000000000000000000000',
        targetAmount: '1000000000000000000000000',
      ),
    );

    expect(exactTwentyFive.currentLevel, 25);
    expect(exactTwentyFive.progressToNextLevelLabel, '0% toward Level 26');
    expect(partial.currentLevel, 25);
    expect(partial.progressToNextLevelLabel, '40% toward Level 26');
    expect(belowTwentySix.currentLevel, 25);
    expect(belowTwentySix.progressToNextLevelLabel, '99% toward Level 26');
    expect(ninetyNine.currentLevel, 99);
    expect(ninetyNine.progressToNextLevelLabel, '50% toward Level 100');
    expect(exactNinetyNine.currentLevel, 99);
    expect(exactNinetyNine.progressToNextLevelLabel, '0% toward Level 100');
    expect(maximum.currentLevel, 100);
    expect(maximum.isMaximumLevel, isTrue);
    expect(maximum.nextLevel, isNull);
    expect(aboveMaximum.currentLevel, 100);
    expect(aboveMaximum.progressToNextLevelRatio, 1);
    expect(large.currentLevel, 25);
  });
}
