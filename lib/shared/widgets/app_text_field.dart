import 'package:flutter/material.dart';

/// A generic text field that inherits Fyqen's centralized input styling.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    super.key,
    this.controller,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autofillHints,
  }) : assert(maxLines == null || maxLines > 0),
       assert(!obscureText || maxLines == 1);

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      autovalidateMode: validator == null
          ? AutovalidateMode.disabled
          : AutovalidateMode.onUserInteraction,
      autofillHints: autofillHints,
    );
  }
}
