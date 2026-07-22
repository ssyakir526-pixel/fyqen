import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/app/fyqen_app.dart';
import 'package:fyqen/core/constants/app_constants.dart';
import 'package:fyqen/core/theme/app_colors.dart';

void main() {
  testWidgets('renders the initial Fyqen dashboard placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FyqenApp());

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appSlogan), findsOneWidget);
    expect(find.text('FINANCIAL FREEDOM'), findsOneWidget);
    expect(find.text('Your journey starts here'), findsOneWidget);
    expect(find.text('Foundation ready'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);

    final BuildContext scaffoldContext = tester.element(find.byType(Scaffold));
    final ThemeData theme = Theme.of(scaffoldContext);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(tester.takeException(), isNull);
  });
}
