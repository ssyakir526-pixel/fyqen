import 'package:fyqen/features/dashboard/presentation/models/dashboard_portfolio_summary.dart';
import 'package:fyqen/features/dashboard/presentation/models/financial_freedom_level_summary.dart';
import 'package:fyqen/features/journey/presentation/models/financial_freedom_journey_summary.dart';
import 'package:fyqen/features/journey/presentation/models/journey_stage_summary.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

/// Immutable, presentation-only inputs for Achievement rule evaluation.
final class AchievementEvaluationContext {
  const AchievementEvaluationContext._({
    required this.assetCount,
    required this.liabilityCount,
    required this.netWorthAmount,
    required this.fiTargetAmount,
    required this.fiProgressAvailable,
    required this.fiProgressRatio,
    required this.fiProgressLabel,
    required this.levelAvailable,
    required this.currentLevel,
    required this.journeyAvailable,
    required this.journeyComplete,
    required this.completedJourneyStageCount,
  });

  const AchievementEvaluationContext.empty()
    : assetCount = 0,
      liabilityCount = 0,
      netWorthAmount = null,
      fiTargetAmount = null,
      fiProgressAvailable = false,
      fiProgressRatio = null,
      fiProgressLabel = null,
      levelAvailable = false,
      currentLevel = null,
      journeyAvailable = false,
      journeyComplete = false,
      completedJourneyStageCount = 0;

  factory AchievementEvaluationContext.fromPortfolio(Portfolio portfolio) {
    final DashboardPortfolioSummary dashboardSummary =
        DashboardPortfolioSummary.fromPortfolio(portfolio);
    final FinancialFreedomLevelSummary levelSummary =
        FinancialFreedomLevelSummary.fromDashboardSummary(dashboardSummary);
    final FinancialFreedomJourneySummary journeySummary =
        FinancialFreedomJourneySummary.fromSummaries(
          dashboardSummary: dashboardSummary,
          levelSummary: levelSummary,
        );

    return AchievementEvaluationContext._(
      assetCount: portfolio.assets.length,
      liabilityCount: portfolio.liabilities.length,
      netWorthAmount: dashboardSummary.netWorthAmount,
      fiTargetAmount: dashboardSummary.financialIndependenceTargetAmount,
      fiProgressAvailable:
          dashboardSummary.isFinancialIndependenceProgressAvailable,
      fiProgressRatio: dashboardSummary.financialIndependenceProgress,
      fiProgressLabel: dashboardSummary.financialIndependenceProgressLabel,
      levelAvailable: levelSummary.isAvailable,
      currentLevel: levelSummary.currentLevel,
      journeyAvailable: journeySummary.isAvailable,
      journeyComplete: journeySummary.isComplete,
      completedJourneyStageCount: journeySummary.stages
          .where(
            (JourneyStageSummary stage) =>
                stage.status == JourneyStageStatus.completed,
          )
          .length,
    );
  }

  final int assetCount;
  final int liabilityCount;
  final String? netWorthAmount;
  final String? fiTargetAmount;
  final bool fiProgressAvailable;
  final double? fiProgressRatio;
  final String? fiProgressLabel;
  final bool levelAvailable;
  final int? currentLevel;
  final bool journeyAvailable;
  final bool journeyComplete;
  final int completedJourneyStageCount;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is AchievementEvaluationContext &&
            other.assetCount == assetCount &&
            other.liabilityCount == liabilityCount &&
            other.netWorthAmount == netWorthAmount &&
            other.fiTargetAmount == fiTargetAmount &&
            other.fiProgressAvailable == fiProgressAvailable &&
            other.fiProgressRatio == fiProgressRatio &&
            other.fiProgressLabel == fiProgressLabel &&
            other.levelAvailable == levelAvailable &&
            other.currentLevel == currentLevel &&
            other.journeyAvailable == journeyAvailable &&
            other.journeyComplete == journeyComplete &&
            other.completedJourneyStageCount == completedJourneyStageCount;
  }

  @override
  int get hashCode => Object.hash(
    assetCount,
    liabilityCount,
    netWorthAmount,
    fiTargetAmount,
    fiProgressAvailable,
    fiProgressRatio,
    fiProgressLabel,
    levelAvailable,
    currentLevel,
    journeyAvailable,
    journeyComplete,
    completedJourneyStageCount,
  );
}
