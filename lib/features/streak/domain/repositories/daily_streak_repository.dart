import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak_update_result.dart';

abstract interface class DailyStreakRepository {
  Future<DailyStreak> loadDailyStreak();

  Stream<DailyStreak> watchDailyStreak();

  Future<DailyStreakUpdateResult> recordDailyOpen({required DateTime openedAt});
}
