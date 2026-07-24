import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fyqen/features/streak/application/app_clock.dart';
import 'package:fyqen/features/streak/domain/repositories/daily_streak_repository.dart';
import 'package:fyqen/features/streak/presentation/controllers/daily_streak_controller.dart';
import 'package:fyqen/features/streak/presentation/state/daily_streak_view_state.dart';

/// Provides independent Streak state to the authenticated app shell.
final class DailyStreakSession extends StatefulWidget {
  const DailyStreakSession({
    required this.repository,
    required this.clock,
    required this.builder,
    super.key,
  });

  final DailyStreakRepository repository;
  final AppClock clock;
  final Widget Function(
    BuildContext context,
    DailyStreakViewState state,
    Future<void> Function() onRetry,
  )
  builder;

  @override
  State<DailyStreakSession> createState() => _DailyStreakSessionState();
}

final class _DailyStreakSessionState extends State<DailyStreakSession> {
  late final DailyStreakController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DailyStreakController(
      repository: widget.repository,
      clock: widget.clock,
    );
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return widget.builder(context, _controller.state, _controller.retry);
      },
    );
  }
}
