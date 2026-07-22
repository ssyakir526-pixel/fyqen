import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/app/fyqen_app.dart';
import 'package:fyqen/core/constants/app_constants.dart';

void main() {
  testWidgets('renders the initial Fyqen dashboard placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FyqenApp());

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appSlogan), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
