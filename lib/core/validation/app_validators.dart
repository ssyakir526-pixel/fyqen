/// Generic validation rules shared by future form components.
abstract final class AppValidators {
  const AppValidators._();

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? requiredField(
    String? value, {
    String message = 'This field is required.',
  }) {
    return value == null || value.trim().isEmpty ? message : null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    return _emailPattern.hasMatch(value.trim())
        ? null
        : 'Enter a valid email address.';
  }

  static String? minimumLength(
    String? value, {
    required int minimum,
    String? message,
  }) {
    assert(minimum > 0);

    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }

    return value.length < minimum
        ? message ?? 'Use at least $minimum characters.'
        : null;
  }
}
