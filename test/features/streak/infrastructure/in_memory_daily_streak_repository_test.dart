import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/streak/infrastructure/repositories/in_memory_daily_streak_repository.dart';

void main() {
  test(
    'loads, watches, and records one effective open per calendar day',
    () async {
      final InMemoryDailyStreakRepository repository =
          InMemoryDailyStreakRepository();
      final List<int> watched = <int>[];
      final subscription = repository.watchDailyStreak().listen(
        (streak) => watched.add(streak.currentStreak),
      );

      expect((await repository.loadDailyStreak()).currentStreak, 0);
      final first = await repository.recordDailyOpen(
        openedAt: DateTime(2026, 1, 1, 9),
      );
      final duplicate = await repository.recordDailyOpen(
        openedAt: DateTime(2026, 1, 1, 20),
      );
      final next = await repository.recordDailyOpen(
        openedAt: DateTime(2026, 1, 2, 1),
      );
      final reset = await repository.recordDailyOpen(
        openedAt: DateTime(2026, 1, 4),
      );

      expect(first.streak.currentStreak, 1);
      expect(duplicate.didChange, isFalse);
      expect(next.streak.currentStreak, 2);
      expect(reset.streak.currentStreak, 1);
      expect(reset.streak.longestStreak, 2);
      expect(watched, isNotEmpty);
      await subscription.cancel();
      await repository.dispose();
    },
  );

  test('keeps concurrent same-day calls idempotent', () async {
    final InMemoryDailyStreakRepository repository =
        InMemoryDailyStreakRepository();
    final results = await Future.wait([
      repository.recordDailyOpen(openedAt: DateTime(2026, 1, 1, 8)),
      repository.recordDailyOpen(openedAt: DateTime(2026, 1, 1, 9)),
    ]);

    expect(results.where((result) => result.didChange), hasLength(1));
    expect((await repository.loadDailyStreak()).currentStreak, 1);
    await repository.dispose();
  });
}
