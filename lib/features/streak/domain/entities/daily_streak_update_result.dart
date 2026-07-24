import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak_milestone.dart';

/// Structured output from one deterministic qualifying-open evaluation.
final class DailyStreakUpdateResult {
  const DailyStreakUpdateResult({
    required this.previousStreak,
    required this.streak,
    required this.didChange,
    required this.didIncrement,
    required this.didReset,
    required this.isFirstOpen,
    required this.isSameDay,
    required this.newlyReachedMilestone,
  });

  final DailyStreak previousStreak;
  final DailyStreak streak;
  final bool didChange;
  final bool didIncrement;
  final bool didReset;
  final bool isFirstOpen;
  final bool isSameDay;
  final DailyStreakMilestone? newlyReachedMilestone;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is DailyStreakUpdateResult &&
            other.previousStreak == previousStreak &&
            other.streak == streak &&
            other.didChange == didChange &&
            other.didIncrement == didIncrement &&
            other.didReset == didReset &&
            other.isFirstOpen == isFirstOpen &&
            other.isSameDay == isSameDay &&
            other.newlyReachedMilestone == newlyReachedMilestone;
  }

  @override
  int get hashCode => Object.hash(
    previousStreak,
    streak,
    didChange,
    didIncrement,
    didReset,
    isFirstOpen,
    isSameDay,
    newlyReachedMilestone,
  );
}
