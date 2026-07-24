import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/presentation/state/daily_streak_view_state.dart';
import 'package:fyqen/features/streak/presentation/widgets/daily_streak_card.dart';

void main() {
  Widget buildCard(DailyStreakViewState state) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: DailyStreakCard(state: state)),
    );
  }

  testWidgets('renders a ready daily streak with stable keys and semantics', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        buildCard(
          DailyStreakViewState.ready(
            streak: DailyStreak(
              currentStreak: 7,
              longestStreak: 30,
              lastOpenedDate: DateTime(2026, 1, 1),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('dashboard-daily-streak-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dashboard-daily-streak-heading')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dashboard-daily-streak-current-value')),
        findsOneWidget,
      );
      expect(find.text('7 days'), findsOneWidget);
      expect(find.text('30 days'), findsOneWidget);
      expect(find.text('30-Day Streak'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Daily Streak.*Current streak 7 days.*')),
        findsOneWidget,
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('renders loading and failure without blocking a card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildCard(const DailyStreakViewState.loading()));
    expect(
      find.byKey(const Key('dashboard-daily-streak-loading')),
      findsOneWidget,
    );

    await tester.pumpWidget(buildCard(const DailyStreakViewState.failure()));
    expect(
      find.byKey(const Key('dashboard-daily-streak-failure')),
      findsOneWidget,
    );
    expect(
      find.text('Streak information is temporarily unavailable.'),
      findsOneWidget,
    );
  });

  testWidgets('remains accessible on a small surface with large text', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 320),
              textScaler: TextScaler.linear(1.5),
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: DailyStreakCard(
                  state: DailyStreakViewState.ready(
                    streak: DailyStreak(
                      currentStreak: 2,
                      longestStreak: 30,
                      lastOpenedDate: DateTime(2026, 1, 1),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('2 days'), findsOneWidget);
      expect(
        find.byKey(const Key('dashboard-daily-streak-update-info')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('shows the all-milestones state without rewards or claims', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildCard(
        DailyStreakViewState.ready(
          streak: DailyStreak(
            currentStreak: 1000,
            longestStreak: 1000,
            lastOpenedDate: DateTime(2026, 1, 1),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('dashboard-daily-streak-all-milestones')),
      findsOneWidget,
    );
    expect(find.text('All milestones reached'), findsNWidgets(2));
    expect(find.textContaining('Claim'), findsNothing);
    expect(find.textContaining('Reward'), findsNothing);
  });
}
