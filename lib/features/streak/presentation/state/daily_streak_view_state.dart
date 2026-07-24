import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak_update_result.dart';

enum DailyStreakStatus { initial, loading, ready, failure }

final class DailyStreakViewState {
  const DailyStreakViewState._({
    required this.status,
    required this.streak,
    required this.latestUpdate,
  });

  const DailyStreakViewState.initial()
    : this._(
        status: DailyStreakStatus.initial,
        streak: null,
        latestUpdate: null,
      );

  const DailyStreakViewState.loading()
    : this._(
        status: DailyStreakStatus.loading,
        streak: null,
        latestUpdate: null,
      );

  const DailyStreakViewState.failure()
    : this._(
        status: DailyStreakStatus.failure,
        streak: null,
        latestUpdate: null,
      );

  const DailyStreakViewState.ready({
    required DailyStreak streak,
    DailyStreakUpdateResult? latestUpdate,
  }) : this._(
         status: DailyStreakStatus.ready,
         streak: streak,
         latestUpdate: latestUpdate,
       );

  final DailyStreakStatus status;
  final DailyStreak? streak;
  final DailyStreakUpdateResult? latestUpdate;
}
