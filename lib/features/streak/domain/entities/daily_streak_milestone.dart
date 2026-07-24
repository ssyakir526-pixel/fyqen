import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';

enum DailyStreakMilestone {
  sevenDays(7, '7-Day Streak'),
  thirtyDays(30, '30-Day Streak'),
  oneHundredDays(100, '100-Day Streak'),
  threeHundredSixtyFiveDays(365, '365-Day Streak'),
  oneThousandDays(1000, '1000-Day Streak');

  const DailyStreakMilestone(this.requiredDays, this.label);

  final int requiredDays;
  final String label;
}

/// Presentation-only next-milestone information derived from a DailyStreak.
final class DailyStreakMilestoneSummary {
  const DailyStreakMilestoneSummary({
    required this.currentStreak,
    required this.nextMilestone,
    required this.daysUntilNextMilestone,
    required this.progressRatio,
  });

  factory DailyStreakMilestoneSummary.fromStreak(DailyStreak streak) {
    DailyStreakMilestone? next;
    for (final DailyStreakMilestone milestone in DailyStreakMilestone.values) {
      if (milestone.requiredDays > streak.currentStreak) {
        next = milestone;
        break;
      }
    }
    if (next == null) {
      return DailyStreakMilestoneSummary(
        currentStreak: streak.currentStreak,
        nextMilestone: null,
        daysUntilNextMilestone: 0,
        progressRatio: 1,
      );
    }
    final double ratio = streak.currentStreak / next.requiredDays;
    return DailyStreakMilestoneSummary(
      currentStreak: streak.currentStreak,
      nextMilestone: next,
      daysUntilNextMilestone: next.requiredDays - streak.currentStreak,
      progressRatio: ratio.clamp(0, 1).toDouble(),
    );
  }

  final int currentStreak;
  final DailyStreakMilestone? nextMilestone;
  final int daysUntilNextMilestone;
  final double progressRatio;
}
