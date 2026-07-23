import 'package:fyqen/features/dashboard/presentation/models/dashboard_portfolio_summary.dart';
import 'package:fyqen/features/dashboard/presentation/models/financial_freedom_level_summary.dart';
import 'package:fyqen/features/journey/presentation/models/journey_stage_summary.dart';

/// Immutable Journey state composed from Dashboard and Level presentation data.
final class FinancialFreedomJourneySummary {
  const FinancialFreedomJourneySummary.noTarget()
    : isAvailable = false,
      isNoTarget = true,
      currentLevel = null,
      currentStage = null,
      stages = const <JourneyStageSummary>[],
      nextCheckpointLevel = null,
      levelsRemainingToNextCheckpoint = null,
      isComplete = false,
      overallProgressRatio = null,
      formattedOverallProgress = null,
      nextLevelProgressLabel = null,
      unavailableReason =
          'Add your Financial Independence target to begin tracking your Journey.';

  const FinancialFreedomJourneySummary._({
    required this.isAvailable,
    required this.isNoTarget,
    required this.currentLevel,
    required this.currentStage,
    required this.stages,
    required this.nextCheckpointLevel,
    required this.levelsRemainingToNextCheckpoint,
    required this.isComplete,
    required this.overallProgressRatio,
    required this.formattedOverallProgress,
    required this.nextLevelProgressLabel,
    required this.unavailableReason,
  });

  factory FinancialFreedomJourneySummary.fromDashboardSummary(
    DashboardPortfolioSummary dashboardSummary,
  ) {
    return FinancialFreedomJourneySummary.fromSummaries(
      dashboardSummary: dashboardSummary,
      levelSummary: FinancialFreedomLevelSummary.fromDashboardSummary(
        dashboardSummary,
      ),
    );
  }

  factory FinancialFreedomJourneySummary.fromSummaries({
    required DashboardPortfolioSummary dashboardSummary,
    required FinancialFreedomLevelSummary levelSummary,
  }) {
    if (!dashboardSummary.hasFinancialIndependenceTarget) {
      return const FinancialFreedomJourneySummary.noTarget();
    }

    final int? currentLevel = levelSummary.currentLevel;
    if (!levelSummary.isAvailable || currentLevel == null) {
      return const FinancialFreedomJourneySummary._(
        isAvailable: false,
        isNoTarget: false,
        currentLevel: null,
        currentStage: null,
        stages: <JourneyStageSummary>[],
        nextCheckpointLevel: null,
        levelsRemainingToNextCheckpoint: null,
        isComplete: false,
        overallProgressRatio: null,
        formattedOverallProgress: null,
        nextLevelProgressLabel: null,
        unavailableReason:
            'Your Journey cannot be calculated while your financial values use different currencies.',
      );
    }

    final bool isComplete = levelSummary.isMaximumLevel;
    final int currentStageIndex = isComplete ? -1 : currentLevel ~/ 10;
    final List<JourneyStageSummary> stages =
        List<JourneyStageSummary>.unmodifiable(
          stageDefinitions.asMap().entries.map((
            MapEntry<int, JourneyStageSummary> entry,
          ) {
            final int index = entry.key;
            final JourneyStageStatus status =
                isComplete || index < currentStageIndex
                ? JourneyStageStatus.completed
                : index == currentStageIndex
                ? JourneyStageStatus.current
                : JourneyStageStatus.upcoming;
            return entry.value.copyWith(status: status);
          }),
        );
    final JourneyStageSummary? currentStage = isComplete
        ? null
        : stages[currentStageIndex];
    final int? nextCheckpointLevel = currentStage?.checkpointLevel;

    return FinancialFreedomJourneySummary._(
      isAvailable: true,
      isNoTarget: false,
      currentLevel: currentLevel,
      currentStage: currentStage,
      stages: stages,
      nextCheckpointLevel: nextCheckpointLevel,
      levelsRemainingToNextCheckpoint: nextCheckpointLevel == null
          ? null
          : nextCheckpointLevel - currentLevel,
      isComplete: isComplete,
      overallProgressRatio: dashboardSummary.financialIndependenceProgress,
      formattedOverallProgress:
          dashboardSummary.financialIndependenceProgressLabel,
      nextLevelProgressLabel: levelSummary.progressToNextLevelLabel,
      unavailableReason: null,
    );
  }

  static const List<JourneyStageSummary> stageDefinitions =
      <JourneyStageSummary>[
        JourneyStageSummary(
          stageNumber: 1,
          name: 'Foundation',
          description: 'Building the first part of your financial base.',
          checkpointLevel: 10,
          status: JourneyStageStatus.upcoming,
        ),
        JourneyStageSummary(
          stageNumber: 2,
          name: 'Stability',
          description: 'Strengthening your position toward Level 20.',
          checkpointLevel: 20,
          status: JourneyStageStatus.upcoming,
        ),
        JourneyStageSummary(
          stageNumber: 3,
          name: 'Momentum',
          description: 'Growing consistent progress toward your FI target.',
          checkpointLevel: 30,
          status: JourneyStageStatus.upcoming,
        ),
        JourneyStageSummary(
          stageNumber: 4,
          name: 'Growth',
          description: 'Continuing to build net worth toward Level 40.',
          checkpointLevel: 40,
          status: JourneyStageStatus.upcoming,
        ),
        JourneyStageSummary(
          stageNumber: 5,
          name: 'Halfway',
          description: 'Approaching or passing the midpoint of the Journey.',
          checkpointLevel: 50,
          status: JourneyStageStatus.upcoming,
        ),
        JourneyStageSummary(
          stageNumber: 6,
          name: 'Expansion',
          description: 'Building beyond the halfway stage.',
          checkpointLevel: 60,
          status: JourneyStageStatus.upcoming,
        ),
        JourneyStageSummary(
          stageNumber: 7,
          name: 'Strength',
          description: 'Establishing a stronger financial position.',
          checkpointLevel: 70,
          status: JourneyStageStatus.upcoming,
        ),
        JourneyStageSummary(
          stageNumber: 8,
          name: 'Independence',
          description: 'Moving closer to financial independence.',
          checkpointLevel: 80,
          status: JourneyStageStatus.upcoming,
        ),
        JourneyStageSummary(
          stageNumber: 9,
          name: 'Final Stretch',
          description: 'Approaching the final part of the target.',
          checkpointLevel: 90,
          status: JourneyStageStatus.upcoming,
        ),
        JourneyStageSummary(
          stageNumber: 10,
          name: 'Financial Freedom',
          description: 'Reaching the configured Financial Independence target.',
          checkpointLevel: 100,
          status: JourneyStageStatus.upcoming,
        ),
      ];

  final bool isAvailable;
  final bool isNoTarget;
  final int? currentLevel;
  final JourneyStageSummary? currentStage;
  final List<JourneyStageSummary> stages;
  final int? nextCheckpointLevel;
  final int? levelsRemainingToNextCheckpoint;
  final bool isComplete;
  final double? overallProgressRatio;
  final String? formattedOverallProgress;
  final String? nextLevelProgressLabel;
  final String? unavailableReason;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is FinancialFreedomJourneySummary &&
            other.isAvailable == isAvailable &&
            other.isNoTarget == isNoTarget &&
            other.currentLevel == currentLevel &&
            other.currentStage == currentStage &&
            _sameStages(other.stages, stages) &&
            other.nextCheckpointLevel == nextCheckpointLevel &&
            other.levelsRemainingToNextCheckpoint ==
                levelsRemainingToNextCheckpoint &&
            other.isComplete == isComplete &&
            other.overallProgressRatio == overallProgressRatio &&
            other.formattedOverallProgress == formattedOverallProgress &&
            other.nextLevelProgressLabel == nextLevelProgressLabel &&
            other.unavailableReason == unavailableReason;
  }

  @override
  int get hashCode => Object.hash(
    isAvailable,
    isNoTarget,
    currentLevel,
    currentStage,
    Object.hashAll(stages),
    nextCheckpointLevel,
    levelsRemainingToNextCheckpoint,
    isComplete,
    overallProgressRatio,
    formattedOverallProgress,
    nextLevelProgressLabel,
    unavailableReason,
  );

  static bool _sameStages(
    List<JourneyStageSummary> first,
    List<JourneyStageSummary> second,
  ) {
    if (first.length != second.length) {
      return false;
    }
    for (int index = 0; index < first.length; index += 1) {
      if (first[index] != second[index]) {
        return false;
      }
    }
    return true;
  }
}
