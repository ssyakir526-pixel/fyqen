import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/dashboard/presentation/models/dashboard_portfolio_summary.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';

void main() {
  final DateTime timestamp = DateTime.utc(2026);

  Asset asset({String currencyCode = 'MYR'}) {
    return Asset(
      id: 'asset-1',
      name: 'Synthetic asset',
      type: AssetType.cash,
      quantity: AssetQuantity('1'),
      unitPrice: AssetUnitPrice(amount: '500', currencyCode: currencyCode),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  Liability liability({String currencyCode = 'MYR'}) {
    return Liability(
      id: 'liability-1',
      name: 'Synthetic liability',
      type: LiabilityType.creditCard,
      outstandingBalance: LiabilityAmount(
        amount: '100',
        currencyCode: currencyCode,
      ),
      originalAmount: LiabilityAmount(
        amount: '100',
        currencyCode: currencyCode,
      ),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  Portfolio portfolio({
    List<Asset> assets = const <Asset>[],
    List<Liability> liabilities = const <Liability>[],
    FinancialIndependenceTarget? target,
  }) {
    return Portfolio(
      id: 'primary',
      name: 'My Portfolio',
      assets: assets,
      liabilities: liabilities,
      financialIndependenceTarget: target,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  test('reports no target without inventing FI progress', () {
    final DashboardPortfolioSummary summary =
        DashboardPortfolioSummary.fromPortfolio(portfolio());

    expect(summary.hasFinancialIndependenceTarget, isFalse);
    expect(summary.isFinancialIndependenceProgressAvailable, isFalse);
    expect(summary.financialIndependenceProgress, isNull);
  });

  test('derives actual percentage and a clamped indicator value', () {
    final DashboardPortfolioSummary partial =
        DashboardPortfolioSummary.fromPortfolio(
          portfolio(
            assets: <Asset>[asset()],
            liabilities: <Liability>[liability()],
            target: FinancialIndependenceTarget(
              amount: '800',
              currencyCode: 'MYR',
            ),
          ),
        );
    final DashboardPortfolioSummary aboveTarget =
        DashboardPortfolioSummary.fromPortfolio(
          portfolio(
            assets: <Asset>[asset()],
            target: FinancialIndependenceTarget(
              amount: '100',
              currencyCode: 'MYR',
            ),
          ),
        );

    expect(partial.financialIndependenceProgressLabel, '50%');
    expect(partial.financialIndependenceProgress, 0.5);
    expect(aboveTarget.financialIndependenceProgressLabel, '500%');
    expect(aboveTarget.financialIndependenceProgress, 1);
  });

  test('keeps progress unavailable for mixed currencies', () {
    final DashboardPortfolioSummary summary =
        DashboardPortfolioSummary.fromPortfolio(
          portfolio(
            assets: <Asset>[asset(currencyCode: 'MYR')],
            liabilities: <Liability>[liability(currencyCode: 'USD')],
            target: FinancialIndependenceTarget(
              amount: '1000',
              currencyCode: 'MYR',
            ),
          ),
        );

    expect(summary.isFinancialIndependenceProgressAvailable, isFalse);
    expect(summary.netWorthLabel, 'Unavailable across currencies');
  });
}
