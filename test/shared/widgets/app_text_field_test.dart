import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/core/validation/app_validators.dart';
import 'package:fyqen/shared/widgets/app_text_field.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }

  testWidgets('renders values and reports text changes', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: 'Start',
    );
    String? changedValue;
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildTestApp(
        AppTextField(
          label: 'Example field',
          hintText: 'Enter a value',
          controller: controller,
          onChanged: (String value) => changedValue = value,
        ),
      ),
    );

    expect(find.text('Example field'), findsOneWidget);
    expect(find.text('Enter a value'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Updated');
    expect(changedValue, 'Updated');
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows validation feedback and respects disabled state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        AppTextField(
          label: 'Required field',
          validator: AppValidators.requiredField,
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), ' ');
    await tester.pump();
    expect(find.text('This field is required.'), findsOneWidget);

    await tester.pumpWidget(
      buildTestApp(const AppTextField(label: 'Disabled field', enabled: false)),
    );
    final TextFormField textField = tester.widget<TextFormField>(
      find.byType(TextFormField),
    );
    expect(textField.enabled, isFalse);
    expect(tester.takeException(), isNull);
  });
}
