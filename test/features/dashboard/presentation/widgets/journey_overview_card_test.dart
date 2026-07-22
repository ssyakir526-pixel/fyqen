import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/features/dashboard/presentation/widgets/journey_overview_card.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );
  }

  testWidgets('renders the unavailable state without progress', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const JourneyOverviewCard(hasData: false)),
    );

    expect(find.text('Journey unavailable'), findsOneWidget);
    expect(
      find.text(
        'Complete your setup to see your current stage and next direction.',
      ),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders all supplied available-state content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const JourneyOverviewCard(
          hasData: true,
          stageLabel: 'Stage supplied by a future feature layer',
          nextStepTitle: 'Next direction supplied',
          description: 'Journey information is presentation-only.',
          progress: 0.5,
          progressLabel: 'Journey progress supplied',
        ),
      ),
    );

    final LinearProgressIndicator progressIndicator = tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));

    expect(find.text('Journey'), findsOneWidget);
    expect(find.text('Current stage'), findsOneWidget);
    expect(
      find.text('Stage supplied by a future feature layer'),
      findsOneWidget,
    );
    expect(find.text('Next direction'), findsOneWidget);
    expect(find.text('Next direction supplied'), findsOneWidget);
    expect(
      find.text('Journey information is presentation-only.'),
      findsOneWidget,
    );
    expect(find.text('Journey progress supplied'), findsOneWidget);
    expect(progressIndicator.value, 0.5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders supplied content when progress is omitted', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const JourneyOverviewCard(
          hasData: true,
          stageLabel: 'Stage supplied by a future feature layer',
          nextStepTitle: 'Next direction supplied',
        ),
      ),
    );

    expect(
      find.text('Stage supplied by a future feature layer'),
      findsOneWidget,
    );
    expect(find.text('Next direction supplied'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the available-but-empty state safely', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const JourneyOverviewCard(hasData: true)),
    );

    expect(find.text('Journey'), findsOneWidget);
    expect(find.text('Journey details are not available yet.'), findsOneWidget);
    expect(find.text('Current stage'), findsNothing);
    expect(find.text('Next direction'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wraps long supplied values safely in a narrow layout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const SingleChildScrollView(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 280,
              child: JourneyOverviewCard(
                hasData: true,
                stageLabel:
                    'A long neutral stage supplied by a future feature layer',
                nextStepTitle:
                    'A long neutral next direction supplied by a future feature layer',
                progress: 0.5,
                progressLabel:
                    'A long neutral progress label supplied by a future feature layer',
                description:
                    'A long neutral description supplied by a future feature layer.',
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('A long neutral stage supplied by a future feature layer'),
      findsOneWidget,
    );
    expect(
      find.text(
        'A long neutral next direction supplied by a future feature layer',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'A long neutral progress label supplied by a future feature layer',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'A long neutral description supplied by a future feature layer.',
      ),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('builds a semantic tree safely', (WidgetTester tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    try {
      await tester.pumpWidget(
        buildTestApp(
          const JourneyOverviewCard(
            hasData: true,
            stageLabel: 'Stage supplied by a future feature layer',
            progressLabel: 'Journey progress supplied',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
