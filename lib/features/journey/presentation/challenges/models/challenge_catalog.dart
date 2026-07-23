import 'package:fyqen/features/journey/presentation/challenges/models/challenge_evaluation_context.dart';
import 'package:fyqen/features/journey/presentation/challenges/rules/challenge_rule.dart';

enum ChallengeCategory { setup, portfolio, progress, journey, financialFreedom }

extension ChallengeCategoryLabel on ChallengeCategory {
  String get label => switch (this) {
    ChallengeCategory.setup => 'Setup',
    ChallengeCategory.portfolio => 'Portfolio',
    ChallengeCategory.progress => 'Progress',
    ChallengeCategory.journey => 'Journey',
    ChallengeCategory.financialFreedom => 'Financial Freedom',
  };
}

final class ChallengeDefinition {
  const ChallengeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.rule,
    required this.displayOrder,
    required this.priority,
  });

  final String id;
  final String title;
  final String description;
  final ChallengeCategory category;
  final ChallengeRule rule;
  final int displayOrder;
  final int priority;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is ChallengeDefinition &&
            other.id == id &&
            other.title == title &&
            other.description == description &&
            other.category == category &&
            other.rule == rule &&
            other.displayOrder == displayOrder &&
            other.priority == priority;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    category,
    rule,
    displayOrder,
    priority,
  );
}

enum ChallengeStatus { active, completed, unavailable }

final class ChallengeSummary {
  const ChallengeSummary({
    required this.definition,
    required this.evaluation,
    required this.status,
  });

  final ChallengeDefinition definition;
  final ChallengeEvaluationResult evaluation;
  final ChallengeStatus status;

  bool get isAvailable => status != ChallengeStatus.unavailable;

  bool get isCompleted => status == ChallengeStatus.completed;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is ChallengeSummary &&
            other.definition == definition &&
            other.evaluation == evaluation &&
            other.status == status;
  }

  @override
  int get hashCode => Object.hash(definition, evaluation, status);
}

/// An immutable, priority-ordered evaluation of the fixed Challenge catalog.
final class ChallengeCatalogSummary {
  ChallengeCatalogSummary._({required List<ChallengeSummary> challenges})
    : challenges = List<ChallengeSummary>.unmodifiable(challenges),
      activeChallenges = List<ChallengeSummary>.unmodifiable(
        challenges.where(
          (ChallengeSummary item) => item.status == ChallengeStatus.active,
        ),
      ),
      completedChallenges = List<ChallengeSummary>.unmodifiable(
        challenges.where((ChallengeSummary item) => item.isCompleted),
      ),
      unavailableChallenges = List<ChallengeSummary>.unmodifiable(
        challenges.where(
          (ChallengeSummary item) => item.status == ChallengeStatus.unavailable,
        ),
      );

  factory ChallengeCatalogSummary.fromContext(
    ChallengeEvaluationContext context,
  ) {
    final List<ChallengeSummary> evaluated = challengeCatalog
        .map((ChallengeDefinition definition) {
          final ChallengeEvaluationResult evaluation = definition.rule.evaluate(
            context,
          );
          final ChallengeStatus status = !evaluation.isAvailable
              ? ChallengeStatus.unavailable
              : evaluation.isSatisfied
              ? ChallengeStatus.completed
              : ChallengeStatus.active;
          return ChallengeSummary(
            definition: definition,
            evaluation: evaluation,
            status: status,
          );
        })
        .toList(growable: false);
    return ChallengeCatalogSummary._(challenges: evaluated);
  }

  final List<ChallengeSummary> challenges;
  final List<ChallengeSummary> activeChallenges;
  final List<ChallengeSummary> completedChallenges;
  final List<ChallengeSummary> unavailableChallenges;

  int get totalCount => challenges.length;
  int get completedCount => completedChallenges.length;
  int get availableCount => totalCount - unavailableChallenges.length;
  int get unavailableCount => unavailableChallenges.length;
  double get overallCompletionRatio => totalCount == 0
      ? 0
      : (completedCount / totalCount).clamp(0, 1).toDouble();
  String get formattedOverallCompletion =>
      '${(overallCompletionRatio * 100).floor()}%';
  bool get allCompleted => totalCount > 0 && completedCount == totalCount;

  /// The first active Challenge by the catalog's stable priority order.
  /// Falls back to the first unavailable Challenge only for explanation.
  ChallengeSummary? get recommendedChallenge {
    if (activeChallenges.isNotEmpty) {
      return activeChallenges.first;
    }
    if (unavailableChallenges.isNotEmpty) {
      return unavailableChallenges.first;
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is ChallengeCatalogSummary &&
            _sameItems(other.challenges, challenges);
  }

  @override
  int get hashCode => Object.hashAll(challenges);

  static bool _sameItems(
    List<ChallengeSummary> first,
    List<ChallengeSummary> second,
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

const List<ChallengeDefinition> challengeCatalog = <ChallengeDefinition>[
  ChallengeDefinition(
    id: 'set-fi-target',
    title: 'Set Your FI Target',
    description:
        'Configure the Financial Independence target used to measure your progress.',
    category: ChallengeCategory.setup,
    rule: FiTargetConfiguredRule(),
    displayOrder: 1,
    priority: 1,
  ),
  ChallengeDefinition(
    id: 'add-first-asset',
    title: 'Add Your First Asset',
    description: 'Add an asset to begin tracking your Portfolio.',
    category: ChallengeCategory.portfolio,
    rule: AssetCountAtLeastChallengeRule(1),
    displayOrder: 2,
    priority: 2,
  ),
  ChallengeDefinition(
    id: 'track-three-assets',
    title: 'Build Your Portfolio',
    description: 'Track at least three assets in your Portfolio.',
    category: ChallengeCategory.portfolio,
    rule: AssetCountAtLeastChallengeRule(3),
    displayOrder: 3,
    priority: 3,
  ),
  ChallengeDefinition(
    id: 'reach-level-10',
    title: 'Reach Level 10',
    description: 'Progress to Financial Freedom Level 10.',
    category: ChallengeCategory.progress,
    rule: LevelAtLeastChallengeRule(10),
    displayOrder: 4,
    priority: 4,
  ),
  ChallengeDefinition(
    id: 'reach-level-25',
    title: 'Reach Level 25',
    description: 'Progress to Financial Freedom Level 25.',
    category: ChallengeCategory.progress,
    rule: LevelAtLeastChallengeRule(25),
    displayOrder: 5,
    priority: 5,
  ),
  ChallengeDefinition(
    id: 'complete-three-journey-stages',
    title: 'Complete Three Journey Stages',
    description: 'Complete three stages in your Financial Freedom Journey.',
    category: ChallengeCategory.journey,
    rule: JourneyStagesCompletedAtLeastChallengeRule(3),
    displayOrder: 6,
    priority: 6,
  ),
  ChallengeDefinition(
    id: 'complete-five-journey-stages',
    title: 'Complete Five Journey Stages',
    description: 'Complete five stages in your Financial Freedom Journey.',
    category: ChallengeCategory.journey,
    rule: JourneyStagesCompletedAtLeastChallengeRule(5),
    displayOrder: 7,
    priority: 7,
  ),
  ChallengeDefinition(
    id: 'reach-financial-freedom',
    title: 'Reach Financial Freedom',
    description: 'Reach your configured Financial Independence target.',
    category: ChallengeCategory.financialFreedom,
    rule: JourneyCompleteChallengeRule(),
    displayOrder: 8,
    priority: 8,
  ),
];
