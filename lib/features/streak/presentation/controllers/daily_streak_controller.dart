import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fyqen/features/streak/application/app_clock.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak_update_result.dart';
import 'package:fyqen/features/streak/domain/repositories/daily_streak_repository.dart';
import 'package:fyqen/features/streak/presentation/state/daily_streak_view_state.dart';

/// Owns one authenticated Daily Streak session and records one session open.
final class DailyStreakController extends ChangeNotifier {
  DailyStreakController({
    required DailyStreakRepository repository,
    required AppClock clock,
  }) : _repository = repository,
       _clock = clock;

  final DailyStreakRepository _repository;
  final AppClock _clock;
  DailyStreakViewState _state = const DailyStreakViewState.initial();
  StreamSubscription<DailyStreak>? _subscription;
  bool _initialized = false;
  bool _disposed = false;

  DailyStreakViewState get state => _state;

  Future<void> initialize() async {
    if (_initialized || _disposed) {
      return;
    }
    _initialized = true;
    _setState(const DailyStreakViewState.loading());
    _subscription = _repository.watchDailyStreak().listen(
      _handleStreak,
      onError: (_, _) => _setState(const DailyStreakViewState.failure()),
    );
    await _recordOpen();
  }

  Future<void> retry() async {
    if (_disposed) {
      return;
    }
    _setState(const DailyStreakViewState.loading());
    await _recordOpen();
  }

  Future<void> _recordOpen() async {
    try {
      final DailyStreakUpdateResult result = await _repository.recordDailyOpen(
        openedAt: _clock.now(),
      );
      _setState(
        DailyStreakViewState.ready(streak: result.streak, latestUpdate: result),
      );
    } catch (_) {
      _setState(const DailyStreakViewState.failure());
    }
  }

  void _handleStreak(DailyStreak streak) {
    if (_disposed) {
      return;
    }
    _setState(DailyStreakViewState.ready(streak: streak));
  }

  void _setState(DailyStreakViewState state) {
    if (_disposed) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
