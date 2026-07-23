import 'package:fyqen/features/journey/presentation/challenges/models/challenge_evaluation_context.dart';

/// Structured, safe output from one typed Challenge rule evaluation.
final class ChallengeEvaluationResult {
  const ChallengeEvaluationResult({
    required this.isAvailable,
    required this.isSatisfied,
    required this.currentValue,
    required this.targetValue,
    required this.progressRatio,
    required this.formattedProgress,
    this.unavailableReason,
  });

  final bool isAvailable;
  final bool isSatisfied;
  final int? currentValue;
  final int? targetValue;
  final double? progressRatio;
  final String? formattedProgress;
  final String? unavailableReason;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is ChallengeEvaluationResult &&
            other.isAvailable == isAvailable &&
            other.isSatisfied == isSatisfied &&
            other.currentValue == currentValue &&
            other.targetValue == targetValue &&
            other.progressRatio == progressRatio &&
            other.formattedProgress == formattedProgress &&
            other.unavailableReason == unavailableReason;
  }

  @override
  int get hashCode => Object.hash(
    isAvailable,
    isSatisfied,
    currentValue,
    targetValue,
    progressRatio,
    formattedProgress,
    unavailableReason,
  );
}

/// A typed, application-defined condition for a derived Challenge.
sealed class ChallengeRule {
  const ChallengeRule();

  ChallengeEvaluationResult evaluate(ChallengeEvaluationContext context);
}

final class FiTargetConfiguredRule extends ChallengeRule {
  const FiTargetConfiguredRule();

  @override
  ChallengeEvaluationResult evaluate(ChallengeEvaluationContext context) {
    final bool isConfigured = context.hasFinancialIndependenceTarget;
    return ChallengeEvaluationResult(
      isAvailable: true,
      isSatisfied: isConfigured,
      currentValue: isConfigured ? 1 : 0,
      targetValue: 1,
      progressRatio: isConfigured ? 1 : 0,
      formattedProgress: isConfigured
          ? 'FI target configured'
          : 'FI target not configured',
    );
  }

  @override
  bool operator ==(Object other) => other is FiTargetConfiguredRule;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class AssetCountAtLeastChallengeRule extends ChallengeRule {
  const AssetCountAtLeastChallengeRule(this.requiredCount)
    : assert(requiredCount > 0);

  final int requiredCount;

  @override
  ChallengeEvaluationResult evaluate(ChallengeEvaluationContext context) {
    final int count = context.assetCount;
    return ChallengeEvaluationResult(
      isAvailable: true,
      isSatisfied: count >= requiredCount,
      currentValue: count,
      targetValue: requiredCount,
      progressRatio: _clampRatio(count, requiredCount),
      formattedProgress: '$count of $requiredCount assets',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AssetCountAtLeastChallengeRule &&
      other.requiredCount == requiredCount;

  @override
  int get hashCode => requiredCount.hashCode;
}

final class LevelAtLeastChallengeRule extends ChallengeRule {
  const LevelAtLeastChallengeRule(this.requiredLevel)
    : assert(requiredLevel >= 1 && requiredLevel <= 100);

  final int requiredLevel;

  @override
  ChallengeEvaluationResult evaluate(ChallengeEvaluationContext context) {
    final int? currentLevel = context.currentLevel;
    if (!context.financialProgressAvailable ||
        !context.levelAvailable ||
        currentLevel == null) {
      return const ChallengeEvaluationResult(
        isAvailable: false,
        isSatisfied: false,
        currentValue: null,
        targetValue: null,
        progressRatio: null,
        formattedProgress: null,
        unavailableReason: 'Financial Freedom Level is unavailable.',
      );
    }

    return ChallengeEvaluationResult(
      isAvailable: true,
      isSatisfied: currentLevel >= requiredLevel,
      currentValue: currentLevel,
      targetValue: requiredLevel,
      progressRatio: _clampRatio(currentLevel, requiredLevel),
      formattedProgress: 'Level $currentLevel of $requiredLevel',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LevelAtLeastChallengeRule &&
      other.requiredLevel == requiredLevel;

  @override
  int get hashCode => requiredLevel.hashCode;
}

final class JourneyStagesCompletedAtLeastChallengeRule extends ChallengeRule {
  const JourneyStagesCompletedAtLeastChallengeRule(this.requiredCount)
    : assert(requiredCount > 0 && requiredCount <= 10);

  final int requiredCount;

  @override
  ChallengeEvaluationResult evaluate(ChallengeEvaluationContext context) {
    if (!context.financialProgressAvailable || !context.journeyAvailable) {
      return const ChallengeEvaluationResult(
        isAvailable: false,
        isSatisfied: false,
        currentValue: null,
        targetValue: null,
        progressRatio: null,
        formattedProgress: null,
        unavailableReason: 'Journey progress is unavailable.',
      );
    }

    final int count = context.completedJourneyStageCount;
    return ChallengeEvaluationResult(
      isAvailable: true,
      isSatisfied: count >= requiredCount,
      currentValue: count,
      targetValue: requiredCount,
      progressRatio: _clampRatio(count, requiredCount),
      formattedProgress: '$count of $requiredCount stages',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is JourneyStagesCompletedAtLeastChallengeRule &&
      other.requiredCount == requiredCount;

  @override
  int get hashCode => requiredCount.hashCode;
}

final class JourneyCompleteChallengeRule extends ChallengeRule {
  const JourneyCompleteChallengeRule();

  @override
  ChallengeEvaluationResult evaluate(ChallengeEvaluationContext context) {
    final int? currentLevel = context.currentLevel;
    if (!context.financialProgressAvailable ||
        !context.journeyAvailable ||
        currentLevel == null) {
      return const ChallengeEvaluationResult(
        isAvailable: false,
        isSatisfied: false,
        currentValue: null,
        targetValue: null,
        progressRatio: null,
        formattedProgress: null,
        unavailableReason: 'Journey progress is unavailable.',
      );
    }

    return ChallengeEvaluationResult(
      isAvailable: true,
      isSatisfied: context.journeyComplete,
      currentValue: currentLevel,
      targetValue: 100,
      progressRatio: _clampRatio(currentLevel, 100),
      formattedProgress: 'Level $currentLevel of 100',
    );
  }

  @override
  bool operator ==(Object other) => other is JourneyCompleteChallengeRule;

  @override
  int get hashCode => runtimeType.hashCode;
}

double _clampRatio(int current, int target) {
  if (target <= 0) {
    return 0;
  }
  final double ratio = current / target;
  return ratio < 0
      ? 0
      : ratio > 1
      ? 1
      : ratio;
}
