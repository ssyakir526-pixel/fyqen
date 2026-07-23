import 'package:fyqen/features/achievements/presentation/models/achievement_evaluation_context.dart';

/// Structured, safe output from a typed Achievement rule.
final class AchievementEvaluationResult {
  const AchievementEvaluationResult({
    required this.isAvailable,
    required this.isSatisfied,
    required this.progressRatio,
    required this.formattedProgress,
    this.unavailableReason,
  });

  final bool isAvailable;
  final bool isSatisfied;
  final double? progressRatio;
  final String? formattedProgress;
  final String? unavailableReason;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is AchievementEvaluationResult &&
            other.isAvailable == isAvailable &&
            other.isSatisfied == isSatisfied &&
            other.progressRatio == progressRatio &&
            other.formattedProgress == formattedProgress &&
            other.unavailableReason == unavailableReason;
  }

  @override
  int get hashCode => Object.hash(
    isAvailable,
    isSatisfied,
    progressRatio,
    formattedProgress,
    unavailableReason,
  );
}

/// Typed, application-defined condition for a derived Achievement.
sealed class AchievementRule {
  const AchievementRule();

  AchievementEvaluationResult evaluate(AchievementEvaluationContext context);
}

final class AssetCountAtLeastRule extends AchievementRule {
  const AssetCountAtLeastRule(this.requiredCount) : assert(requiredCount > 0);

  final int requiredCount;

  @override
  AchievementEvaluationResult evaluate(AchievementEvaluationContext context) {
    final int count = context.assetCount;
    return AchievementEvaluationResult(
      isAvailable: true,
      isSatisfied: count >= requiredCount,
      progressRatio: _ratio(count, requiredCount),
      formattedProgress: '$count of $requiredCount assets',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AssetCountAtLeastRule && other.requiredCount == requiredCount;

  @override
  int get hashCode => requiredCount.hashCode;
}

final class LiabilityCountAtMostRule extends AchievementRule {
  const LiabilityCountAtMostRule(this.maximumCount) : assert(maximumCount >= 0);

  final int maximumCount;

  @override
  AchievementEvaluationResult evaluate(AchievementEvaluationContext context) {
    final int count = context.liabilityCount;
    return AchievementEvaluationResult(
      isAvailable: true,
      isSatisfied: count <= maximumCount,
      progressRatio: count <= maximumCount ? 1 : 0,
      formattedProgress: '$count liabilities recorded',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LiabilityCountAtMostRule && other.maximumCount == maximumCount;

  @override
  int get hashCode => maximumCount.hashCode;
}

final class LevelAtLeastRule extends AchievementRule {
  const LevelAtLeastRule(this.requiredLevel)
    : assert(requiredLevel >= 1 && requiredLevel <= 100);

  final int requiredLevel;

  @override
  AchievementEvaluationResult evaluate(AchievementEvaluationContext context) {
    final int? currentLevel = context.currentLevel;
    if (!context.levelAvailable || currentLevel == null) {
      return const AchievementEvaluationResult(
        isAvailable: false,
        isSatisfied: false,
        progressRatio: null,
        formattedProgress: null,
        unavailableReason: 'Financial Freedom Level is unavailable.',
      );
    }
    return AchievementEvaluationResult(
      isAvailable: true,
      isSatisfied: currentLevel >= requiredLevel,
      progressRatio: _ratio(currentLevel, requiredLevel),
      formattedProgress: 'Level $currentLevel of $requiredLevel',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LevelAtLeastRule && other.requiredLevel == requiredLevel;

  @override
  int get hashCode => requiredLevel.hashCode;
}

final class JourneyStagesCompletedAtLeastRule extends AchievementRule {
  const JourneyStagesCompletedAtLeastRule(this.requiredCount)
    : assert(requiredCount > 0 && requiredCount <= 10);

  final int requiredCount;

  @override
  AchievementEvaluationResult evaluate(AchievementEvaluationContext context) {
    if (!context.journeyAvailable) {
      return const AchievementEvaluationResult(
        isAvailable: false,
        isSatisfied: false,
        progressRatio: null,
        formattedProgress: null,
        unavailableReason: 'Journey progress is unavailable.',
      );
    }
    final int count = context.completedJourneyStageCount;
    return AchievementEvaluationResult(
      isAvailable: true,
      isSatisfied: count >= requiredCount,
      progressRatio: _ratio(count, requiredCount),
      formattedProgress: '$count of $requiredCount stages',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is JourneyStagesCompletedAtLeastRule &&
      other.requiredCount == requiredCount;

  @override
  int get hashCode => requiredCount.hashCode;
}

final class JourneyCompleteRule extends AchievementRule {
  const JourneyCompleteRule();

  @override
  AchievementEvaluationResult evaluate(AchievementEvaluationContext context) {
    if (!context.journeyAvailable) {
      return const AchievementEvaluationResult(
        isAvailable: false,
        isSatisfied: false,
        progressRatio: null,
        formattedProgress: null,
        unavailableReason: 'Journey progress is unavailable.',
      );
    }
    final int level = context.currentLevel ?? 0;
    return AchievementEvaluationResult(
      isAvailable: true,
      isSatisfied: context.journeyComplete,
      progressRatio: context.journeyComplete ? 1 : _ratio(level, 100),
      formattedProgress: 'Level $level of 100',
    );
  }

  @override
  bool operator ==(Object other) => other is JourneyCompleteRule;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class FiProgressAtLeastRule extends AchievementRule {
  const FiProgressAtLeastRule(this.requiredProgress)
    : assert(requiredProgress != '');

  /// Exact decimal ratio, for example `0.25` for 25%.
  final String requiredProgress;

  @override
  AchievementEvaluationResult evaluate(AchievementEvaluationContext context) {
    final String? netWorth = context.netWorthAmount;
    final String? target = context.fiTargetAmount;
    if (!context.fiProgressAvailable || netWorth == null || target == null) {
      return const AchievementEvaluationResult(
        isAvailable: false,
        isSatisfied: false,
        progressRatio: null,
        formattedProgress: null,
        unavailableReason: 'Financial Independence progress is unavailable.',
      );
    }

    final _ExactDecimal netWorthValue = _ExactDecimal.parse(netWorth);
    final _ExactDecimal targetValue = _ExactDecimal.parse(target);
    final _ExactDecimal requiredValue = _ExactDecimal.parse(requiredProgress);
    final bool isSatisfied = _compareRatio(
      numerator: netWorthValue,
      denominator: targetValue,
      required: requiredValue,
    );
    return AchievementEvaluationResult(
      isAvailable: true,
      isSatisfied: isSatisfied,
      progressRatio: context.fiProgressRatio,
      formattedProgress: context.fiProgressLabel,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FiProgressAtLeastRule &&
      other.requiredProgress == requiredProgress;

  @override
  int get hashCode => requiredProgress.hashCode;
}

double _ratio(int current, int target) {
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

bool _compareRatio({
  required _ExactDecimal numerator,
  required _ExactDecimal denominator,
  required _ExactDecimal required,
}) {
  if (numerator.unscaled.isNegative) {
    return false;
  }
  final BigInt left =
      numerator.unscaled *
      BigInt.from(10).pow(denominator.scale + required.scale);
  final BigInt right =
      denominator.unscaled *
      required.unscaled *
      BigInt.from(10).pow(numerator.scale);
  return left >= right;
}

final class _ExactDecimal {
  const _ExactDecimal._(this.unscaled, this.scale);

  factory _ExactDecimal.parse(String value) {
    final List<String> parts = value.split('.');
    final String fraction = parts.length == 2 ? parts.last : '';
    return _ExactDecimal._(
      BigInt.parse('${parts.first}$fraction'),
      fraction.length,
    );
  }

  final BigInt unscaled;
  final int scale;
}
