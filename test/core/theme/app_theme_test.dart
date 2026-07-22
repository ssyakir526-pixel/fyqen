import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/core/theme/app_colors.dart';
import 'package:fyqen/core/theme/app_theme.dart';

void main() {
  test('provides the Dark Purple design-system contracts', () {
    final ThemeData theme = AppTheme.dark;
    final ButtonStyle? filledButtonStyle = theme.filledButtonTheme.style;
    final Size? minimumSize = filledButtonStyle?.minimumSize?.resolve(
      <WidgetState>{},
    );

    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.colorScheme.surface, AppColors.surface);
    expect(theme.colorScheme.error, AppColors.error);
    expect(theme.cardTheme.color, AppColors.surface);
    expect(theme.textTheme.displaySmall, isNotNull);
    expect(theme.textTheme.headlineMedium, isNotNull);
    expect(theme.textTheme.titleLarge, isNotNull);
    expect(theme.textTheme.bodyLarge, isNotNull);
    expect(theme.inputDecorationTheme.filled, isTrue);
    expect(minimumSize?.height, greaterThanOrEqualTo(48));
  });
}
