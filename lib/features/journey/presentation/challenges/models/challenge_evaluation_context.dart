import 'package:fyqen/features/dashboard/presentation/models/dashboard_portfolio_summary.dart';
import 'package:fyqen/features/dashboard/presentation/models/financial_freedom_level_summary.dart';
import 'package:fyqen/features/journey/presentation/models/financial_freedom_journey_summary.dart';
import 'package:fyqen/features/journey/presentation/models/journey_stage_summary.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

/// Immutable presentation inputs for deterministic Challenge evaluation.
final class ChallengeEvaluationContext {
  const ChallengeEvaluationContext._({
    required this.assetCount,
    required this.hasFinancialIndependenceTarget,
    required this.financialProgressAvailable,
    required this.levelAvailable,
    required this.currentLevel,
    required this.journeyAvailable,
    required this.journeyComplete,
    required this.completedJourneyStageCount,
  });

  const ChallengeEvaluationContext.empty()
    : assetCount = 0,
      hasFinancialIndependenceTarget = false,
      financialProgressAvailable = false,
      levelAvailable = false,
      currentLevel = null,
      journeyAvailable = false,
      journeyComplete = false,
      completedJourneyStageCount = 0;

  factory ChallengeEvaluationContext.fromSummaries({
    required Portfolio portfolio,
    required DashboardPortfolioSummary dashboardSummary,
    required FinancialFreedomLevelSummary levelSummary,
    required FinancialFreedomJourneySummary journeySummary,
  }) {
    return ChallengeEvaluationContext._(
      assetCount: portfolio.assets.length,
      hasFinancialIndependenceTarget:
          dashboardSummary.hasFinancialIndependenceTarget,
      financialProgressAvailable:
          dashboardSummary.isFinancialIndependenceProgressAvailable,
      levelAvailable:
          dashboardSummary.isFinancialIndependenceProgressAvailable &&
          levelSummary.isAvailable,
      currentLevel: levelSummary.currentLevel,
      journeyAvailable:
          dashboardSummary.isFinancialIndependenceProgressAvailable &&
          journeySummary.isAvailable,
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
  final bool hasFinancialIndependenceTarget;
  final bool financialProgressAvailable;
  final bool levelAvailable;
  final int? currentLevel;
  final bool journeyAvailable;
  final bool journeyComplete;
  final int completedJourneyStageCount;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is ChallengeEvaluationContext &&
            other.assetCount == assetCount &&
            other.hasFinancialIndependenceTarget ==
                hasFinancialIndependenceTarget &&
            other.financialProgressAvailable == financialProgressAvailable &&
            other.levelAvailable == levelAvailable &&
            other.currentLevel == currentLevel &&
            other.journeyAvailable == journeyAvailable &&
            other.journeyComplete == journeyComplete &&
            other.completedJourneyStageCount == completedJourneyStageCount;
  }

  @override
  int get hashCode => Object.hash(
    assetCount,
    hasFinancialIndependenceTarget,
    financialProgressAvailable,
    levelAvailable,
    currentLevel,
    journeyAvailable,
    journeyComplete,
    completedJourneyStageCount,
  );
}
