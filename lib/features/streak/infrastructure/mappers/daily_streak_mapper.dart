import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/domain/services/daily_streak_calculator.dart';
import 'package:fyqen/features/streak/infrastructure/dtos/daily_streak_dto.dart';

final class DailyStreakMapper {
  const DailyStreakMapper();

  DailyStreak toDomain(DailyStreakDto dto) {
    return DailyStreak(
      currentStreak: dto.currentStreak,
      longestStreak: dto.longestStreak,
      lastOpenedDate: dto.lastOpenedDate == null
          ? null
          : DailyStreakCalculator.localDateOnly(dto.lastOpenedDate!),
    );
  }

  DailyStreakDto toDto(DailyStreak streak) {
    return DailyStreakDto(
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      lastOpenedDate: streak.lastOpenedDate == null
          ? null
          : DailyStreakCalculator.localDateOnly(streak.lastOpenedDate!),
    );
  }
}
