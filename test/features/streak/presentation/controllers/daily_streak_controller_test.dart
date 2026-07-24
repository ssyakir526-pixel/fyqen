import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak_update_result.dart';
import 'package:fyqen/features/streak/domain/repositories/daily_streak_repository.dart';
import 'package:fyqen/features/streak/infrastructure/repositories/in_memory_daily_streak_repository.dart';
import 'package:fyqen/features/streak/presentation/controllers/daily_streak_controller.dart';
import 'package:fyqen/features/streak/presentation/state/daily_streak_view_state.dart';

import '../../test_support.dart';

void main() {
  test('initializes once and uses the injected clock', () async {
    final FakeAppClock clock = FakeAppClock(DateTime(2026, 1, 1, 9));
    final InMemoryDailyStreakRepository repository =
        InMemoryDailyStreakRepository();
    final DailyStreakController controller = DailyStreakController(
      repository: repository,
      clock: clock,
    );

    expect(controller.state.status, DailyStreakStatus.initial);
    await controller.initialize();
    expect(controller.state.status, DailyStreakStatus.ready);
    expect(controller.state.streak?.currentStreak, 1);

    await controller.initialize();
    expect(controller.state.streak?.currentStreak, 1);

    clock.value = DateTime(2026, 1, 2, 9);
    await controller.retry();
    expect(controller.state.streak?.currentStreak, 2);

    clock.value = DateTime(2026, 1, 4, 9);
    await controller.retry();
    expect(controller.state.streak?.currentStreak, 1);
    expect(controller.state.streak?.longestStreak, 2);
    controller.dispose();
    await repository.dispose();
  });

  test(
    'maps repository failures to a safe failure state and retries',
    () async {
      final _FailOnceRepository repository = _FailOnceRepository();
      final DailyStreakController controller = DailyStreakController(
        repository: repository,
        clock: FakeAppClock(DateTime(2026, 1, 1)),
      );

      await controller.initialize();
      expect(controller.state.status, DailyStreakStatus.failure);
      expect(controller.state.streak, isNull);

      await controller.retry();
      expect(controller.state.status, DailyStreakStatus.ready);
      expect(controller.state.streak?.currentStreak, 1);
      controller.dispose();
      await repository.dispose();
    },
  );
}

final class _FailOnceRepository implements DailyStreakRepository {
  bool _shouldFail = true;
  final InMemoryDailyStreakRepository _delegate =
      InMemoryDailyStreakRepository();

  @override
  Future<DailyStreak> loadDailyStreak() => _delegate.loadDailyStreak();

  @override
  Stream<DailyStreak> watchDailyStreak() => _delegate.watchDailyStreak();

  @override
  Future<DailyStreakUpdateResult> recordDailyOpen({
    required DateTime openedAt,
  }) {
    if (_shouldFail) {
      _shouldFail = false;
      return Future.error(StateError('internal failure'));
    }
    return _delegate.recordDailyOpen(openedAt: openedAt);
  }

  Future<void> dispose() => _delegate.dispose();
}
