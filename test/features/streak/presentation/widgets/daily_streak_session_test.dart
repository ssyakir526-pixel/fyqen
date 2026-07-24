import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak_update_result.dart';
import 'package:fyqen/features/streak/domain/repositories/daily_streak_repository.dart';
import 'package:fyqen/features/streak/domain/services/daily_streak_calculator.dart';
import 'package:fyqen/features/streak/presentation/state/daily_streak_view_state.dart';
import 'package:fyqen/features/streak/presentation/widgets/daily_streak_session.dart';

import '../../test_support.dart';

void main() {
  testWidgets(
    'initializes once, ignores parent rebuilds, and cancels on disposal',
    (WidgetTester tester) async {
      final _CountingRepository repository = _CountingRepository();
      final FakeAppClock clock = FakeAppClock(DateTime(2026, 1, 1));

      Widget build({required Key key}) => DailyStreakSession(
        key: key,
        repository: repository,
        clock: clock,
        builder: (_, DailyStreakViewState state, _) => Text(
          '${state.status}-${state.streak?.currentStreak ?? 0}',
          key: const Key('session-state'),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: build(key: const Key('user-a'))),
      );
      await tester.pumpAndSettle();
      expect(repository.recordCalls, 1);
      expect(find.text('DailyStreakStatus.ready-1'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(home: build(key: const Key('user-a'))),
      );
      await tester.pumpAndSettle();
      expect(repository.recordCalls, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(repository.cancelledSubscriptions, 1);
      repository.emit(const DailyStreak.empty());
      expect(find.byKey(const Key('session-state')), findsNothing);
      await repository.dispose();
    },
  );

  testWidgets('replacing a user session removes stale user state', (
    WidgetTester tester,
  ) async {
    final _CountingRepository userA = _CountingRepository();
    final _CountingRepository userB = _CountingRepository();
    final FakeAppClock clock = FakeAppClock(DateTime(2026, 1, 1));

    Widget session(String user, _CountingRepository repository) {
      return DailyStreakSession(
        key: ValueKey<String>(user),
        repository: repository,
        clock: clock,
        builder: (_, DailyStreakViewState state, _) => Text(
          '$user:${state.streak?.currentStreak ?? 0}',
          key: const Key('session-user-state'),
        ),
      );
    }

    await tester.pumpWidget(MaterialApp(home: session('A', userA)));
    await tester.pumpAndSettle();
    expect(find.text('A:1'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: session('B', userB)));
    await tester.pumpAndSettle();
    expect(userA.cancelledSubscriptions, 1);
    expect(find.text('A:1'), findsNothing);
    expect(find.text('B:1'), findsOneWidget);
    expect(userA.recordCalls, 1);
    expect(userB.recordCalls, 1);
    await userA.dispose();
    await userB.dispose();
  });
}

final class _CountingRepository implements DailyStreakRepository {
  _CountingRepository() {
    _stream.onCancel = () {
      cancelledSubscriptions += 1;
    };
  }

  final StreamController<DailyStreak> _stream =
      StreamController<DailyStreak>.broadcast();
  final DailyStreakCalculator _calculator = const DailyStreakCalculator();
  DailyStreak _streak = const DailyStreak.empty();
  int recordCalls = 0;
  int cancelledSubscriptions = 0;

  @override
  Future<DailyStreak> loadDailyStreak() async => _streak;

  @override
  Stream<DailyStreak> watchDailyStreak() async* {
    yield _streak;
    yield* _stream.stream;
  }

  @override
  Future<DailyStreakUpdateResult> recordDailyOpen({
    required DateTime openedAt,
  }) async {
    recordCalls += 1;
    final DailyStreakUpdateResult result = _calculator.recordOpen(
      streak: _streak,
      openedAt: openedAt,
    );
    _streak = result.streak;
    return result;
  }

  void emit(DailyStreak streak) => _stream.add(streak);

  Future<void> dispose() => _stream.close();
}
