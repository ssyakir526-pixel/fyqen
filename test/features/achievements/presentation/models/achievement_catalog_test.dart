import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/achievements/presentation/models/achievement_catalog.dart';
import 'package:fyqen/features/achievements/presentation/models/achievement_evaluation_context.dart';
import 'package:fyqen/features/achievements/presentation/rules/achievement_rule.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';

void main() {
  final DateTime timestamp = DateTime.utc(2026);

  Portfolio portfolio({
    int assetCount = 0,
    int liabilityCount = 0,
    String? netWorth,
    String? target,
    String liabilityCurrency = 'MYR',
  }) {
    return Portfolio(
      id: 'portfolio',
      name: 'Portfolio',
      assets: List<Asset>.generate(
        assetCount,
        (int index) => Asset(
          id: 'asset-$index',
          name: 'Asset $index',
          type: AssetType.cash,
          quantity: AssetQuantity('1'),
          unitPrice: AssetUnitPrice(
            amount: netWorth ?? '1',
            currencyCode: 'MYR',
          ),
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      ),
      liabilities: List<Liability>.generate(
        liabilityCount,
        (int index) => Liability(
          id: 'liability-$index',
          name: 'Liability $index',
          type: LiabilityType.creditCard,
          outstandingBalance: LiabilityAmount(
            amount: '1',
            currencyCode: liabilityCurrency,
          ),
          originalAmount: LiabilityAmount(
            amount: '1',
            currencyCode: liabilityCurrency,
          ),
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      ),
      financialIndependenceTarget: target == null
          ? null
          : FinancialIndependenceTarget(amount: target, currencyCode: 'MYR'),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  AchievementCatalogSummary summary(Portfolio portfolio) {
    return AchievementCatalogSummary.fromContext(
      AchievementEvaluationContext.fromPortfolio(portfolio),
    );
  }

  AchievementSummary achievement(AchievementCatalogSummary summary, String id) {
    return summary.achievements.singleWhere(
      (AchievementSummary item) => item.definition.id == id,
    );
  }

  test('provides the fixed immutable catalog in display order', () {
    expect(achievementCatalog, hasLength(12));
    expect(
      achievementCatalog.map((AchievementDefinition item) => item.id),
      <String>[
        'first-asset',
        'building-a-portfolio',
        'no-current-liabilities',
        'level-10',
        'level-25',
        'level-50',
        'level-75',
        'level-90',
        'journey-stage-3',
        'journey-stage-5',
        'journey-stage-9',
        'financial-freedom-reached',
      ],
    );
    expect(
      achievementCatalog.map((AchievementDefinition item) => item.displayOrder),
      <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    );
    expect(
      () => achievementCatalog.add(achievementCatalog.first),
      throwsUnsupportedError,
    );
    expect(achievementCatalog.first, achievementCatalog.first);
  });

  test('evaluates typed count and unavailable financial rules safely', () {
    const AssetCountAtLeastRule assetRule = AssetCountAtLeastRule(3);
    const LiabilityCountAtMostRule liabilityRule = LiabilityCountAtMostRule(0);
    const LevelAtLeastRule levelRule = LevelAtLeastRule(10);
    const JourneyStagesCompletedAtLeastRule stagesRule =
        JourneyStagesCompletedAtLeastRule(3);
    const JourneyCompleteRule completeRule = JourneyCompleteRule();
    const FiProgressAtLeastRule fiRule = FiProgressAtLeastRule('0.25');
    const AchievementEvaluationContext empty =
        AchievementEvaluationContext.empty();

    expect(assetRule.evaluate(empty).formattedProgress, '0 of 3 assets');
    expect(assetRule.evaluate(empty).progressRatio, 0);
    expect(liabilityRule.evaluate(empty).isSatisfied, isTrue);
    expect(levelRule.evaluate(empty).isAvailable, isFalse);
    expect(stagesRule.evaluate(empty).isAvailable, isFalse);
    expect(completeRule.evaluate(empty).isAvailable, isFalse);
    expect(fiRule.evaluate(empty).isAvailable, isFalse);
    expect(assetRule, const AssetCountAtLeastRule(3));
  });

  test('derives revocable statuses from replacement Portfolio snapshots', () {
    final AchievementCatalogSummary empty = summary(portfolio());
    final AchievementCatalogSummary oneAsset = summary(
      portfolio(assetCount: 1),
    );
    final AchievementCatalogSummary threeAssets = summary(
      portfolio(assetCount: 3),
    );
    final AchievementCatalogSummary levelTwentyFive = summary(
      portfolio(assetCount: 1, netWorth: '25', target: '100'),
    );
    final AchievementCatalogSummary levelTwentyFour = summary(
      portfolio(assetCount: 1, netWorth: '24', target: '100'),
    );
    final AchievementCatalogSummary financialFreedom = summary(
      portfolio(assetCount: 1, netWorth: '100', target: '100'),
    );

    expect(
      achievement(empty, 'first-asset').status,
      AchievementStatus.unearned,
    );
    expect(
      achievement(empty, 'no-current-liabilities').status,
      AchievementStatus.earned,
    );
    expect(
      achievement(empty, 'level-10').status,
      AchievementStatus.unavailable,
    );
    expect(
      achievement(oneAsset, 'first-asset').status,
      AchievementStatus.earned,
    );
    expect(
      achievement(threeAssets, 'building-a-portfolio').status,
      AchievementStatus.earned,
    );
    expect(
      achievement(levelTwentyFive, 'level-25').status,
      AchievementStatus.earned,
    );
    expect(
      achievement(levelTwentyFour, 'level-25').status,
      AchievementStatus.unearned,
    );
    expect(
      achievement(financialFreedom, 'financial-freedom-reached').status,
      AchievementStatus.earned,
    );
    expect(financialFreedom.totalCount, 12);
    expect(financialFreedom.overallCompletionRatio, inInclusiveRange(0, 1));
  });

  test('keeps count rules available when financial comparisons are mixed', () {
    final AchievementCatalogSummary mixedCurrency = summary(
      portfolio(
        assetCount: 1,
        liabilityCount: 1,
        netWorth: '100',
        target: '1000',
        liabilityCurrency: 'USD',
      ),
    );

    expect(
      achievement(mixedCurrency, 'first-asset').status,
      AchievementStatus.earned,
    );
    expect(
      achievement(mixedCurrency, 'no-current-liabilities').status,
      AchievementStatus.unearned,
    );
    expect(
      achievement(mixedCurrency, 'level-10').status,
      AchievementStatus.unavailable,
    );
    expect(
      achievement(mixedCurrency, 'journey-stage-3').status,
      AchievementStatus.unavailable,
    );
  });
}
