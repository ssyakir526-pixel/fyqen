import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/app/navigation/fyqen_shell.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak_update_result.dart';
import 'package:fyqen/features/streak/domain/repositories/daily_streak_repository.dart';
import 'package:fyqen/features/streak/domain/services/daily_streak_calculator.dart';
import 'package:fyqen/features/streak/presentation/state/daily_streak_view_state.dart';
import 'package:fyqen/features/streak/presentation/widgets/daily_streak_session.dart';

import '../test_support.dart';

void main() {
  final DateTime timestamp = DateTime.utc(2026, 1, 1);

  Portfolio portfolio(String name) => Portfolio(
    id: 'primary',
    name: name,
    assets: const [],
    liabilities: const [],
    createdAt: timestamp,
    updatedAt: timestamp,
  );

  testWidgets('navigation and Portfolio snapshots never record another open', (
    WidgetTester tester,
  ) async {
    final _CountingRepository repository = _CountingRepository();
    Portfolio currentPortfolio = portfolio('Initial');

    Widget build() => MaterialApp(
      home: DailyStreakSession(
        repository: repository,
        clock: FakeAppClock(DateTime(2026, 1, 1, 9)),
        builder: (_, DailyStreakViewState state, _) =>
            FyqenShell(portfolio: currentPortfolio, dailyStreakState: state),
      ),
    );

    await tester.pumpWidget(build());
    await tester.pumpAndSettle();
    expect(repository.recordCalls, 1);

    for (final String destination in <String>[
      'dashboard',
      'portfolio',
      'journey',
      'history',
      'achievements',
      'settings',
      'dashboard',
    ]) {
      await tester.tap(find.byKey(Key('${destination}_destination')));
      await tester.pumpAndSettle();
      expect(repository.recordCalls, 1);
    }

    currentPortfolio = portfolio('Asset added');
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();
    expect(repository.recordCalls, 1);

    currentPortfolio = portfolio('Asset updated');
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();
    expect(repository.recordCalls, 1);

    currentPortfolio = portfolio('Asset deleted and summary refreshed');
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();
    expect(repository.recordCalls, 1);
    await repository.dispose();
  });

  test(
    'explicit user-scoped fake storage keeps streaks and streams isolated',
    () async {
      final _UserScopedRepository storage = _UserScopedRepository();
      final List<int> userAEvents = <int>[];
      final List<int> userBEvents = <int>[];
      final StreamSubscription<DailyStreak> aSubscription = storage
          .watch('A')
          .listen(
            (DailyStreak streak) => userAEvents.add(streak.currentStreak),
          );
      final StreamSubscription<DailyStreak> bSubscription = storage
          .watch('B')
          .listen(
            (DailyStreak streak) => userBEvents.add(streak.currentStreak),
          );

      expect((await storage.load('A')).currentStreak, 0);
      expect((await storage.load('B')).currentStreak, 0);
      await storage.record('A', DateTime(2026, 1, 1));
      expect((await storage.load('A')).currentStreak, 1);
      expect((await storage.load('B')).currentStreak, 0);
      await storage.record('B', DateTime(2026, 1, 1));
      expect((await storage.load('A')).currentStreak, 1);
      expect((await storage.load('B')).currentStreak, 1);
      await Future<void>.value();
      expect(userAEvents, <int>[0, 1]);
      expect(userBEvents, <int>[0, 1]);

      await Future.wait(<Future<DailyStreakUpdateResult>>[
        storage.record('A', DateTime(2026, 1, 1, 12)),
        storage.record('A', DateTime(2026, 1, 1, 13)),
        storage.record('B', DateTime(2026, 1, 1, 12)),
        storage.record('B', DateTime(2026, 1, 1, 13)),
      ]);
      expect((await storage.load('A')).currentStreak, 1);
      expect((await storage.load('B')).currentStreak, 1);
      await Future<void>.value();
      expect(userAEvents, <int>[0, 1]);
      expect(userBEvents, <int>[0, 1]);
      await aSubscription.cancel();
      await bSubscription.cancel();
      await storage.dispose();
    },
  );
}

final class _CountingRepository implements DailyStreakRepository {
  int recordCalls = 0;
  DailyStreak _streak = const DailyStreak.empty();
  final DailyStreakCalculator _calculator = const DailyStreakCalculator();

  @override
  Future<DailyStreak> loadDailyStreak() async => _streak;

  @override
  Stream<DailyStreak> watchDailyStreak() async* {
    yield _streak;
  }

  @override
  Future<DailyStreakUpdateResult> recordDailyOpen({
    required DateTime openedAt,
  }) async {
    recordCalls += 1;
    final result = _calculator.recordOpen(streak: _streak, openedAt: openedAt);
    _streak = result.streak;
    return result;
  }

  Future<void> dispose() async {}
}

final class _UserScopedRepository {
  final Map<String, DailyStreak> _storage = <String, DailyStreak>{};
  final Map<String, StreamController<DailyStreak>> _streams =
      <String, StreamController<DailyStreak>>{};
  final DailyStreakCalculator _calculator = const DailyStreakCalculator();

  Future<DailyStreak> load(String userId) async =>
      _storage[userId] ?? const DailyStreak.empty();

  Stream<DailyStreak> watch(String userId) async* {
    yield await load(userId);
    yield* _streamFor(userId).stream;
  }

  Future<DailyStreakUpdateResult> record(
    String userId,
    DateTime openedAt,
  ) async {
    final result = _calculator.recordOpen(
      streak: await load(userId),
      openedAt: openedAt,
    );
    if (result.didChange) {
      _storage[userId] = result.streak;
      _streamFor(userId).add(result.streak);
    }
    return result;
  }

  StreamController<DailyStreak> _streamFor(String userId) =>
      _streams.putIfAbsent(userId, StreamController<DailyStreak>.broadcast);

  Future<void> dispose() async {
    for (final StreamController<DailyStreak> stream in _streams.values) {
      await stream.close();
    }
  }
}
