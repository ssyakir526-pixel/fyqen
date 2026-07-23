import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/dashboard/presentation/models/dashboard_portfolio_summary.dart';
import 'package:fyqen/features/journey/presentation/models/financial_freedom_journey_summary.dart';
import 'package:fyqen/features/journey/presentation/models/journey_stage_summary.dart';
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

  FinancialFreedomJourneySummary journey(Portfolio portfolio) {
    return FinancialFreedomJourneySummary.fromDashboardSummary(
      DashboardPortfolioSummary.fromPortfolio(portfolio),
    );
  }

  test('defines ten immutable, deterministic Journey stages', () {
    final List<JourneyStageSummary> stages =
        FinancialFreedomJourneySummary.stageDefinitions;

    expect(stages, hasLength(10));
    expect(stages.map((JourneyStageSummary stage) => stage.stageNumber), <int>[
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
    ]);
    expect(
      stages.map((JourneyStageSummary stage) => stage.checkpointLevel),
      <int>[10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
    );
    expect(stages.map((JourneyStageSummary stage) => stage.name), <String>[
      'Foundation',
      'Stability',
      'Momentum',
      'Growth',
      'Halfway',
      'Expansion',
      'Strength',
      'Independence',
      'Final Stretch',
      'Financial Freedom',
    ]);
    expect(() => stages.add(stages.first), throwsUnsupportedError);
    expect(stages.first, stages.first.copyWith());
  });

  test('is unavailable without a target or comparable currencies', () {
    final FinancialFreedomJourneySummary noTarget = journey(portfolio());
    final FinancialFreedomJourneySummary mixedCurrency = journey(
      portfolio(
        netWorth: '100',
        liabilityAmount: '1',
        targetAmount: '1000',
        liabilityCurrency: 'USD',
      ),
    );

    expect(noTarget.isAvailable, isFalse);
    expect(noTarget.isNoTarget, isTrue);
    expect(
      noTarget.unavailableReason,
      'Add your Financial Independence target to begin tracking your Journey.',
    );
    expect(mixedCurrency.isAvailable, isFalse);
    expect(mixedCurrency.currentStage, isNull);
  });

  test('keeps negative and zero comparable net worth at Foundation', () {
    final FinancialFreedomJourneySummary negative = journey(
      portfolio(liabilityAmount: '10', targetAmount: '1000'),
    );
    final FinancialFreedomJourneySummary zero = journey(
      portfolio(targetAmount: '1000'),
    );

    expect(negative.currentLevel, 1);
    expect(negative.currentStage?.name, 'Foundation');
    expect(negative.currentStage?.status, JourneyStageStatus.current);
    expect(zero.currentLevel, 1);
    expect(zero.currentStage?.name, 'Foundation');
  });

  test('derives stage boundaries from the reused Level summary', () {
    final FinancialFreedomJourneySummary levelNine = journey(
      portfolio(netWorth: '9', targetAmount: '100'),
    );
    final FinancialFreedomJourneySummary levelTen = journey(
      portfolio(netWorth: '10', targetAmount: '100'),
    );
    final FinancialFreedomJourneySummary levelNineteen = journey(
      portfolio(netWorth: '19', targetAmount: '100'),
    );
    final FinancialFreedomJourneySummary levelTwenty = journey(
      portfolio(netWorth: '20', targetAmount: '100'),
    );
    final FinancialFreedomJourneySummary levelTwentyFive = journey(
      portfolio(netWorth: '25.5', targetAmount: '100'),
    );
    final FinancialFreedomJourneySummary levelFifty = journey(
      portfolio(netWorth: '50', targetAmount: '100'),
    );
    final FinancialFreedomJourneySummary levelNinety = journey(
      portfolio(netWorth: '90', targetAmount: '100'),
    );
    final FinancialFreedomJourneySummary levelEightyNine = journey(
      portfolio(netWorth: '89', targetAmount: '100'),
    );
    final FinancialFreedomJourneySummary levelNinetyNine = journey(
      portfolio(netWorth: '99', targetAmount: '100'),
    );

    expect(levelNine.currentStage?.name, 'Foundation');
    expect(levelNine.nextCheckpointLevel, 10);
    expect(levelTen.stages.first.status, JourneyStageStatus.completed);
    expect(levelTen.currentStage?.name, 'Stability');
    expect(levelTen.nextCheckpointLevel, 20);
    expect(levelNineteen.currentStage?.name, 'Stability');
    expect(levelTwenty.stages[1].status, JourneyStageStatus.completed);
    expect(levelTwenty.currentStage?.name, 'Momentum');
    expect(
      levelTwentyFive.stages
          .take(2)
          .every(
            (JourneyStageSummary stage) =>
                stage.status == JourneyStageStatus.completed,
          ),
      isTrue,
    );
    expect(levelTwentyFive.currentStage?.name, 'Momentum');
    expect(levelTwentyFive.nextCheckpointLevel, 30);
    expect(levelTwentyFive.levelsRemainingToNextCheckpoint, 5);
    expect(levelTwentyFive.overallProgressRatio, 0.25);
    expect(levelTwentyFive.formattedOverallProgress, '25%');
    expect(levelTwentyFive.nextLevelProgressLabel, '50% toward Level 26');
    expect(
      levelTwentyFive.stages.where(
        (JourneyStageSummary stage) =>
            stage.status == JourneyStageStatus.completed,
      ),
      hasLength(2),
    );
    expect(levelFifty.currentStage?.name, 'Expansion');
    expect(levelFifty.stages[4].status, JourneyStageStatus.completed);
    expect(levelEightyNine.currentStage?.name, 'Final Stretch');
    expect(levelEightyNine.nextCheckpointLevel, 90);
    expect(levelNinety.currentStage?.name, 'Financial Freedom');
    expect(levelNinety.stages[8].status, JourneyStageStatus.completed);
    expect(levelNinetyNine.currentStage?.name, 'Financial Freedom');
    expect(levelNinetyNine.nextCheckpointLevel, 100);
  });

  test('completes all stages at and above Level 100', () {
    final FinancialFreedomJourneySummary complete = journey(
      portfolio(netWorth: '100', targetAmount: '100'),
    );
    final FinancialFreedomJourneySummary aboveTarget = journey(
      portfolio(netWorth: '150', targetAmount: '100'),
    );

    expect(complete.isComplete, isTrue);
    expect(complete.currentLevel, 100);
    expect(complete.currentStage, isNull);
    expect(complete.nextCheckpointLevel, isNull);
    expect(
      complete.stages.every(
        (JourneyStageSummary stage) =>
            stage.status == JourneyStageStatus.completed,
      ),
      isTrue,
    );
    expect(aboveTarget.currentLevel, 100);
    expect(aboveTarget.isComplete, isTrue);
    expect(aboveTarget.nextCheckpointLevel, isNull);
    expect(complete, journey(portfolio(netWorth: '100', targetAmount: '100')));
  });
}
