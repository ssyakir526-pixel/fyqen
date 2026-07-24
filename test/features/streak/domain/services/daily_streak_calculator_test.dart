import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak_milestone.dart';
import 'package:fyqen/features/streak/domain/services/daily_streak_calculator.dart';

void main() {
  const DailyStreakCalculator calculator = DailyStreakCalculator();

  test('records a first open and ignores a same-day duplicate', () {
    final DateTime openedAt = DateTime(2026, 1, 1, 23, 50);
    final first = calculator.recordOpen(
      streak: const DailyStreak.empty(),
      openedAt: openedAt,
    );
    final duplicate = calculator.recordOpen(
      streak: first.streak,
      openedAt: DateTime(2026, 1, 1, 23, 55),
    );

    expect(first.streak.currentStreak, 1);
    expect(first.streak.longestStreak, 1);
    expect(first.isFirstOpen, isTrue);
    expect(duplicate.didChange, isFalse);
    expect(duplicate.isSameDay, isTrue);
  });

  test('uses local calendar dates across midnight and calendar boundaries', () {
    final DailyStreak streak = DailyStreak(
      currentStreak: 1,
      longestStreak: 1,
      lastOpenedDate: DateTime(2024, 2, 28, 23, 55),
    );
    final leapDay = calculator.recordOpen(
      streak: streak,
      openedAt: DateTime(2024, 2, 29, 0, 5),
    );
    final march = calculator.recordOpen(
      streak: leapDay.streak,
      openedAt: DateTime(2024, 3, 1, 0, 5),
    );

    expect(leapDay.streak.currentStreak, 2);
    expect(march.streak.currentStreak, 3);
  });

  test('resets after a missed local calendar day and keeps longest streak', () {
    final result = calculator.recordOpen(
      streak: DailyStreak(
        currentStreak: 5,
        longestStreak: 8,
        lastOpenedDate: DateTime(2026, 1, 5),
      ),
      openedAt: DateTime(2026, 1, 7),
    );

    expect(result.didReset, isTrue);
    expect(result.streak.currentStreak, 1);
    expect(result.streak.longestStreak, 8);
  });

  test('does not corrupt the streak when the local clock rolls backward', () {
    final DailyStreak streak = DailyStreak(
      currentStreak: 5,
      longestStreak: 5,
      lastOpenedDate: DateTime(2026, 2, 2),
    );
    final result = calculator.recordOpen(
      streak: streak,
      openedAt: DateTime(2026, 2, 1),
    );

    expect(result.didChange, isFalse);
    expect(result.isSameDay, isFalse);
    expect(result.streak, streak);
  });

  test(
    'returns milestones only when a qualifying update reaches a threshold',
    () {
      final result = calculator.recordOpen(
        streak: DailyStreak(
          currentStreak: 6,
          longestStreak: 6,
          lastOpenedDate: DateTime(2026, 1, 1),
        ),
        openedAt: DateTime(2026, 1, 2),
      );

      expect(result.newlyReachedMilestone, DailyStreakMilestone.sevenDays);
      expect(
        calculator
            .recordOpen(streak: result.streak, openedAt: DateTime(2026, 1, 2))
            .newlyReachedMilestone,
        isNull,
      );
    },
  );
}
