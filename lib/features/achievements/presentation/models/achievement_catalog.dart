import 'package:fyqen/features/achievements/presentation/models/achievement_evaluation_context.dart';
import 'package:fyqen/features/achievements/presentation/rules/achievement_rule.dart';

enum AchievementCategory { portfolio, progress, journey, financialFreedom }

extension AchievementCategoryLabel on AchievementCategory {
  String get label => switch (this) {
    AchievementCategory.portfolio => 'Portfolio',
    AchievementCategory.progress => 'Progress',
    AchievementCategory.journey => 'Journey',
    AchievementCategory.financialFreedom => 'Financial Freedom',
  };
}

final class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.rule,
    required this.displayOrder,
  });

  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final AchievementRule rule;
  final int displayOrder;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is AchievementDefinition &&
            other.id == id &&
            other.title == title &&
            other.description == description &&
            other.category == category &&
            other.rule == rule &&
            other.displayOrder == displayOrder;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, category, rule, displayOrder);
}

enum AchievementStatus { earned, unearned, unavailable }

final class AchievementSummary {
  const AchievementSummary({
    required this.definition,
    required this.evaluation,
    required this.status,
  });

  final AchievementDefinition definition;
  final AchievementEvaluationResult evaluation;
  final AchievementStatus status;

  bool get isEarned => status == AchievementStatus.earned;

  bool get isAvailable => status != AchievementStatus.unavailable;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is AchievementSummary &&
            other.definition == definition &&
            other.evaluation == evaluation &&
            other.status == status;
  }

  @override
  int get hashCode => Object.hash(definition, evaluation, status);
}

final class AchievementCatalogSummary {
  AchievementCatalogSummary._({required List<AchievementSummary> achievements})
    : achievements = List<AchievementSummary>.unmodifiable(achievements),
      earnedAchievements = List<AchievementSummary>.unmodifiable(
        achievements.where((AchievementSummary item) => item.isEarned),
      ),
      unearnedAchievements = List<AchievementSummary>.unmodifiable(
        achievements.where(
          (AchievementSummary item) =>
              item.status == AchievementStatus.unearned,
        ),
      ),
      unavailableAchievements = List<AchievementSummary>.unmodifiable(
        achievements.where(
          (AchievementSummary item) =>
              item.status == AchievementStatus.unavailable,
        ),
      );

  factory AchievementCatalogSummary.fromContext(
    AchievementEvaluationContext context,
  ) {
    return AchievementCatalogSummary._(
      achievements: achievementCatalog
          .map((AchievementDefinition definition) {
            final AchievementEvaluationResult evaluation = definition.rule
                .evaluate(context);
            final AchievementStatus status = !evaluation.isAvailable
                ? AchievementStatus.unavailable
                : evaluation.isSatisfied
                ? AchievementStatus.earned
                : AchievementStatus.unearned;
            return AchievementSummary(
              definition: definition,
              evaluation: evaluation,
              status: status,
            );
          })
          .toList(growable: false),
    );
  }

  final List<AchievementSummary> achievements;
  final List<AchievementSummary> earnedAchievements;
  final List<AchievementSummary> unearnedAchievements;
  final List<AchievementSummary> unavailableAchievements;

  int get totalCount => achievements.length;
  int get earnedCount => earnedAchievements.length;
  int get availableCount => totalCount - unavailableAchievements.length;
  double get overallCompletionRatio =>
      totalCount == 0 ? 0 : earnedCount / totalCount;
  String get formattedOverallCompletion =>
      '${(overallCompletionRatio * 100).floor()}%';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is AchievementCatalogSummary &&
            _sameItems(other.achievements, achievements);
  }

  @override
  int get hashCode => Object.hashAll(achievements);

  static bool _sameItems(
    List<AchievementSummary> first,
    List<AchievementSummary> second,
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

const List<AchievementDefinition> achievementCatalog = <AchievementDefinition>[
  AchievementDefinition(
    id: 'first-asset',
    title: 'First Asset',
    description: 'Add your first asset to your Portfolio.',
    category: AchievementCategory.portfolio,
    rule: AssetCountAtLeastRule(1),
    displayOrder: 1,
  ),
  AchievementDefinition(
    id: 'building-a-portfolio',
    title: 'Building a Portfolio',
    description: 'Track at least three assets in your Portfolio.',
    category: AchievementCategory.portfolio,
    rule: AssetCountAtLeastRule(3),
    displayOrder: 2,
  ),
  AchievementDefinition(
    id: 'no-current-liabilities',
    title: 'No Current Liabilities',
    description: 'Your Portfolio currently has no recorded liabilities.',
    category: AchievementCategory.portfolio,
    rule: LiabilityCountAtMostRule(0),
    displayOrder: 3,
  ),
  AchievementDefinition(
    id: 'level-10',
    title: 'Foundation Reached',
    description: 'Reach Financial Freedom Level 10.',
    category: AchievementCategory.progress,
    rule: LevelAtLeastRule(10),
    displayOrder: 4,
  ),
  AchievementDefinition(
    id: 'level-25',
    title: 'Momentum Reached',
    description: 'Reach Financial Freedom Level 25.',
    category: AchievementCategory.progress,
    rule: LevelAtLeastRule(25),
    displayOrder: 5,
  ),
  AchievementDefinition(
    id: 'level-50',
    title: 'Halfway Level',
    description: 'Reach Financial Freedom Level 50.',
    category: AchievementCategory.progress,
    rule: LevelAtLeastRule(50),
    displayOrder: 6,
  ),
  AchievementDefinition(
    id: 'level-75',
    title: 'Strong Position',
    description: 'Reach Financial Freedom Level 75.',
    category: AchievementCategory.progress,
    rule: LevelAtLeastRule(75),
    displayOrder: 7,
  ),
  AchievementDefinition(
    id: 'level-90',
    title: 'Final Stretch',
    description: 'Reach Financial Freedom Level 90.',
    category: AchievementCategory.progress,
    rule: LevelAtLeastRule(90),
    displayOrder: 8,
  ),
  AchievementDefinition(
    id: 'journey-stage-3',
    title: 'Three Stages Completed',
    description: 'Complete three Financial Freedom Journey stages.',
    category: AchievementCategory.journey,
    rule: JourneyStagesCompletedAtLeastRule(3),
    displayOrder: 9,
  ),
  AchievementDefinition(
    id: 'journey-stage-5',
    title: 'Five Stages Completed',
    description: 'Complete five Financial Freedom Journey stages.',
    category: AchievementCategory.journey,
    rule: JourneyStagesCompletedAtLeastRule(5),
    displayOrder: 10,
  ),
  AchievementDefinition(
    id: 'journey-stage-9',
    title: 'Nine Stages Completed',
    description: 'Complete nine Financial Freedom Journey stages.',
    category: AchievementCategory.journey,
    rule: JourneyStagesCompletedAtLeastRule(9),
    displayOrder: 11,
  ),
  AchievementDefinition(
    id: 'financial-freedom-reached',
    title: 'Financial Freedom Reached',
    description: 'Reach your configured Financial Independence target.',
    category: AchievementCategory.financialFreedom,
    rule: JourneyCompleteRule(),
    displayOrder: 12,
  ),
];
