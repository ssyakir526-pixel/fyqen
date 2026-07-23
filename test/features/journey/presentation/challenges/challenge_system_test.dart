import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/dashboard/presentation/models/dashboard_portfolio_summary.dart';
import 'package:fyqen/features/dashboard/presentation/models/financial_freedom_level_summary.dart';
import 'package:fyqen/features/journey/presentation/challenges/models/challenge_catalog.dart';
import 'package:fyqen/features/journey/presentation/challenges/models/challenge_evaluation_context.dart';
import 'package:fyqen/features/journey/presentation/challenges/rules/challenge_rule.dart';
import 'package:fyqen/features/journey/presentation/models/financial_freedom_journey_summary.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';

void main() {
  final DateTime timestamp = DateTime.utc(2026);

  Portfolio portfolio({
    int assetCount = 0,
    String assetAmount = '1',
    String? targetAmount,
    bool mixedCurrencies = false,
  }) {
    return Portfolio(
      id: 'primary',
      name: 'My Portfolio',
      assets: List<Asset>.generate(
        assetCount,
        (int index) => Asset(
          id: 'asset-$index',
          name: 'Asset $index',
          type: AssetType.cash,
          quantity: AssetQuantity('1'),
          unitPrice: AssetUnitPrice(
            amount: index == 0 ? assetAmount : '1',
            currencyCode: 'MYR',
          ),
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      ),
      liabilities: mixedCurrencies
          ? <Liability>[
              Liability(
                id: 'liability-1',
                name: 'Mixed currency liability',
                type: LiabilityType.creditCard,
                outstandingBalance: LiabilityAmount(
                  amount: '1',
                  currencyCode: 'USD',
                ),
                originalAmount: LiabilityAmount(
                  amount: '1',
                  currencyCode: 'USD',
                ),
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            ]
          : const <Liability>[],
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

  ChallengeEvaluationContext contextFor(Portfolio portfolio) {
    final DashboardPortfolioSummary dashboard =
        DashboardPortfolioSummary.fromPortfolio(portfolio);
    final FinancialFreedomLevelSummary level =
        FinancialFreedomLevelSummary.fromDashboardSummary(dashboard);
    final FinancialFreedomJourneySummary journey =
        FinancialFreedomJourneySummary.fromSummaries(
          dashboardSummary: dashboard,
          levelSummary: level,
        );
    return ChallengeEvaluationContext.fromSummaries(
      portfolio: portfolio,
      dashboardSummary: dashboard,
      levelSummary: level,
      journeySummary: journey,
    );
  }

  ChallengeCatalogSummary summaryFor(Portfolio portfolio) {
    return ChallengeCatalogSummary.fromContext(contextFor(portfolio));
  }

  test('defines the exact immutable Challenge catalog in priority order', () {
    expect(challengeCatalog, hasLength(8));
    expect(
      challengeCatalog.map((ChallengeDefinition item) => item.id),
      <String>[
        'set-fi-target',
        'add-first-asset',
        'track-three-assets',
        'reach-level-10',
        'reach-level-25',
        'complete-three-journey-stages',
        'complete-five-journey-stages',
        'reach-financial-freedom',
      ],
    );
    expect(
      challengeCatalog.map((ChallengeDefinition item) => item.priority),
      <int>[1, 2, 3, 4, 5, 6, 7, 8],
    );
    expect(
      challengeCatalog.map((ChallengeDefinition item) => item.displayOrder),
      <int>[1, 2, 3, 4, 5, 6, 7, 8],
    );
    expect(
      challengeCatalog.map((ChallengeDefinition item) => item.id).toSet(),
      hasLength(8),
    );
    expect(
      () => challengeCatalog.add(challengeCatalog.first),
      throwsUnsupportedError,
    );
    expect(
      challengeCatalog.first,
      const ChallengeDefinition(
        id: 'set-fi-target',
        title: 'Set Your FI Target',
        description:
            'Configure the Financial Independence target used to measure your progress.',
        category: ChallengeCategory.setup,
        rule: FiTargetConfiguredRule(),
        displayOrder: 1,
        priority: 1,
      ),
    );
  });

  test('evaluates FI target and asset-count rules deterministically', () {
    final ChallengeEvaluationContext noTarget = contextFor(portfolio());
    final ChallengeEvaluationContext configuredMixed = contextFor(
      portfolio(assetCount: 1, targetAmount: '100', mixedCurrencies: true),
    );
    const FiTargetConfiguredRule targetRule = FiTargetConfiguredRule();
    const AssetCountAtLeastChallengeRule assetsRule =
        AssetCountAtLeastChallengeRule(3);

    expect(
      targetRule.evaluate(noTarget).formattedProgress,
      'FI target not configured',
    );
    expect(targetRule.evaluate(configuredMixed).isSatisfied, isTrue);
    expect(targetRule, const FiTargetConfiguredRule());
    expect(assetsRule.evaluate(noTarget).formattedProgress, '0 of 3 assets');
    expect(assetsRule.evaluate(configuredMixed).progressRatio, 1 / 3);
    expect(
      assetsRule.evaluate(contextFor(portfolio(assetCount: 4))).progressRatio,
      1,
    );
  });

  test(
    'makes financial Challenges unavailable without comparable FI progress',
    () {
      final ChallengeCatalogSummary noTarget = summaryFor(portfolio());
      final ChallengeCatalogSummary mixed = summaryFor(
        portfolio(assetCount: 2, targetAmount: '100', mixedCurrencies: true),
      );
      final ChallengeCatalogSummary comparable = summaryFor(
        portfolio(assetCount: 2, targetAmount: '100'),
      );

      expect(noTarget.challenges[0].status, ChallengeStatus.active);
      expect(noTarget.challenges[1].status, ChallengeStatus.active);
      expect(noTarget.challenges[3].status, ChallengeStatus.unavailable);
      expect(noTarget.challenges[5].status, ChallengeStatus.unavailable);
      expect(noTarget.challenges[7].status, ChallengeStatus.unavailable);
      expect(noTarget.totalCount, 8);
      expect(noTarget.completedCount, 0);
      expect(noTarget.availableCount, 3);
      expect(noTarget.unavailableCount, 5);
      expect(noTarget.formattedOverallCompletion, '0%');
      expect(noTarget.recommendedChallenge?.definition.id, 'set-fi-target');
      expect(mixed.challenges[0].status, ChallengeStatus.completed);
      expect(mixed.challenges[1].status, ChallengeStatus.completed);
      expect(mixed.challenges[3].status, ChallengeStatus.unavailable);
      expect(mixed.challenges[4].status, ChallengeStatus.unavailable);
      expect(mixed.challenges[5].status, ChallengeStatus.unavailable);
      expect(mixed.challenges[6].status, ChallengeStatus.unavailable);
      expect(mixed.challenges[7].status, ChallengeStatus.unavailable);
      expect(mixed.completedCount, 2);
      expect(mixed.formattedOverallCompletion, '25%');
      expect(mixed.recommendedChallenge?.definition.id, 'track-three-assets');
      expect(comparable.challenges[3].status, ChallengeStatus.active);
      expect(comparable.challenges[5].status, ChallengeStatus.active);
    },
  );

  test('selects the first active Challenge and reverses completion', () {
    final ChallengeCatalogSummary zeroAssets = summaryFor(
      portfolio(targetAmount: '100'),
    );
    final ChallengeCatalogSummary oneAsset = summaryFor(
      portfolio(assetCount: 1, targetAmount: '100'),
    );
    final ChallengeCatalogSummary threeAssets = summaryFor(
      portfolio(assetCount: 3, targetAmount: '100'),
    );

    expect(zeroAssets.recommendedChallenge?.definition.id, 'add-first-asset');
    expect(oneAsset.challenges[1].status, ChallengeStatus.completed);
    expect(oneAsset.recommendedChallenge?.definition.id, 'track-three-assets');
    expect(threeAssets.challenges[2].status, ChallengeStatus.completed);
    expect(threeAssets.recommendedChallenge?.definition.id, 'reach-level-10');
    expect(zeroAssets.challenges[1].status, ChallengeStatus.active);
  });

  test(
    'derives Level and Journey Challenge progress from existing summaries',
    () {
      final ChallengeCatalogSummary levelNine = summaryFor(
        portfolio(assetCount: 1, assetAmount: '9', targetAmount: '100'),
      );
      final ChallengeCatalogSummary levelTwentyFive = summaryFor(
        portfolio(assetCount: 1, assetAmount: '25', targetAmount: '100'),
      );
      final ChallengeCatalogSummary maximum = summaryFor(
        portfolio(assetCount: 3, assetAmount: '98', targetAmount: '100'),
      );

      expect(
        levelNine.challenges[3].evaluation.formattedProgress,
        'Level 9 of 10',
      );
      expect(levelNine.challenges[3].status, ChallengeStatus.active);
      expect(levelTwentyFive.challenges[4].status, ChallengeStatus.completed);
      expect(
        levelTwentyFive.challenges[5].evaluation.formattedProgress,
        '2 of 3 stages',
      );
      expect(maximum.challenges[5].status, ChallengeStatus.completed);
      expect(maximum.challenges[6].status, ChallengeStatus.completed);
      expect(maximum.challenges[7].status, ChallengeStatus.completed);
      expect(maximum.allCompleted, isTrue);
      expect(maximum.completedCount, 8);
      expect(maximum.formattedOverallCompletion, '100%');
      expect(maximum.recommendedChallenge, isNull);
    },
  );

  test(
    'keeps negative comparable net worth available and summaries immutable',
    () {
      final Portfolio negativePortfolio = Portfolio(
        id: 'negative',
        name: 'Negative',
        assets: const <Asset>[],
        liabilities: <Liability>[
          Liability(
            id: 'liability',
            name: 'Liability',
            type: LiabilityType.creditCard,
            outstandingBalance: LiabilityAmount(
              amount: '10',
              currencyCode: 'MYR',
            ),
            originalAmount: LiabilityAmount(amount: '10', currencyCode: 'MYR'),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        ],
        financialIndependenceTarget: FinancialIndependenceTarget(
          amount: '100',
          currencyCode: 'MYR',
        ),
        createdAt: timestamp,
        updatedAt: timestamp,
      );
      final ChallengeCatalogSummary summary = summaryFor(negativePortfolio);

      expect(summary.challenges[3].status, ChallengeStatus.active);
      expect(
        summary.challenges[3].evaluation.formattedProgress,
        'Level 1 of 10',
      );
      expect(summary.challenges[5].status, ChallengeStatus.active);
      expect(
        () => summary.challenges.add(summary.challenges.first),
        throwsUnsupportedError,
      );
      expect(summary, summaryFor(negativePortfolio));
    },
  );
}
