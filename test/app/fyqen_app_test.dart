import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/app/fyqen_app.dart';
import 'package:fyqen/app/navigation/fyqen_shell.dart';
import 'package:fyqen/core/constants/app_constants.dart';
import 'package:fyqen/core/theme/app_colors.dart';
import 'package:fyqen/features/dashboard/presentation/pages/dashboard_placeholder_page.dart';

void main() {
  testWidgets('renders the initial Fyqen dashboard placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FyqenApp());

    expect(find.byType(FyqenShell), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(6));
    expect(find.byType(DashboardPlaceholderPage), findsOneWidget);
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appSlogan), findsOneWidget);
    expect(find.text('FINANCIAL FREEDOM'), findsOneWidget);
    expect(find.text('Your journey starts here'), findsOneWidget);
    expect(find.text('Interaction foundation'), findsOneWidget);
    expect(find.text('Example field'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);

    final NavigationBar navigationBar = tester.widget<NavigationBar>(
      find.byKey(const Key('fyqen_navigation_bar')),
    );
    final BuildContext scaffoldContext = tester.element(find.byType(Scaffold));
    final ThemeData theme = Theme.of(scaffoldContext);
    expect(navigationBar.selectedIndex, 0);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(tester.takeException(), isNull);
  });
}
