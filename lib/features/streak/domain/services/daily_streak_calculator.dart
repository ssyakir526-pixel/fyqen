import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak_milestone.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak_update_result.dart';

/// Pure local-calendar-day streak calculations.
final class DailyStreakCalculator {
  const DailyStreakCalculator();

  DailyStreakUpdateResult recordOpen({
    required DailyStreak streak,
    required DateTime openedAt,
  }) {
    final DateTime today = localDateOnly(openedAt);
    final DateTime? lastOpenedDate = streak.lastOpenedDate;
    if (lastOpenedDate == null) {
      return _changed(
        previous: streak,
        updated: DailyStreak(
          currentStreak: 1,
          longestStreak: streak.longestStreak < 1 ? 1 : streak.longestStreak,
          lastOpenedDate: today,
        ),
        isFirstOpen: true,
      );
    }

    final DateTime last = localDateOnly(lastOpenedDate);
    final int dayDifference = DateTime.utc(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime.utc(last.year, last.month, last.day)).inDays;
    if (dayDifference <= 0) {
      return DailyStreakUpdateResult(
        previousStreak: streak,
        streak: streak,
        didChange: false,
        didIncrement: false,
        didReset: false,
        isFirstOpen: false,
        isSameDay: dayDifference == 0,
        newlyReachedMilestone: null,
      );
    }

    if (dayDifference == 1) {
      final int current = streak.currentStreak + 1;
      return _changed(
        previous: streak,
        updated: DailyStreak(
          currentStreak: current,
          longestStreak: streak.longestStreak > current
              ? streak.longestStreak
              : current,
          lastOpenedDate: today,
        ),
        didIncrement: true,
      );
    }

    return _changed(
      previous: streak,
      updated: DailyStreak(
        currentStreak: 1,
        longestStreak: streak.longestStreak < 1 ? 1 : streak.longestStreak,
        lastOpenedDate: today,
      ),
      didReset: true,
    );
  }

  static DateTime localDateOnly(DateTime value) {
    final DateTime local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  DailyStreakUpdateResult _changed({
    required DailyStreak previous,
    required DailyStreak updated,
    bool didIncrement = false,
    bool didReset = false,
    bool isFirstOpen = false,
  }) {
    return DailyStreakUpdateResult(
      previousStreak: previous,
      streak: updated,
      didChange: true,
      didIncrement: didIncrement,
      didReset: didReset,
      isFirstOpen: isFirstOpen,
      isSameDay: false,
      newlyReachedMilestone: _milestoneFor(updated.currentStreak),
    );
  }

  static DailyStreakMilestone? _milestoneFor(int currentStreak) {
    for (final DailyStreakMilestone milestone in DailyStreakMilestone.values) {
      if (milestone.requiredDays == currentStreak) {
        return milestone;
      }
    }
    return null;
  }
}
