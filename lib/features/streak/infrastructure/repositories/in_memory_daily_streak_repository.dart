import 'dart:async';

import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak_update_result.dart';
import 'package:fyqen/features/streak/domain/repositories/daily_streak_repository.dart';
import 'package:fyqen/features/streak/domain/services/daily_streak_calculator.dart';

/// Deterministic development and test persistence with the production contract.
final class InMemoryDailyStreakRepository implements DailyStreakRepository {
  InMemoryDailyStreakRepository({
    DailyStreak initialStreak = const DailyStreak.empty(),
    DailyStreakCalculator calculator = const DailyStreakCalculator(),
  }) : _streak = initialStreak,
       _calculator = calculator;

  DailyStreak _streak;
  final DailyStreakCalculator _calculator;
  final StreamController<DailyStreak> _controller =
      StreamController<DailyStreak>.broadcast();

  @override
  Future<DailyStreak> loadDailyStreak() async => _streak;

  @override
  Stream<DailyStreak> watchDailyStreak() async* {
    yield _streak;
    yield* _controller.stream;
  }

  @override
  Future<DailyStreakUpdateResult> recordDailyOpen({
    required DateTime openedAt,
  }) async {
    final DailyStreakUpdateResult result = _calculator.recordOpen(
      streak: _streak,
      openedAt: openedAt,
    );
    if (result.didChange) {
      _streak = result.streak;
      _controller.add(_streak);
    }
    return result;
  }

  Future<void> dispose() => _controller.close();
}
