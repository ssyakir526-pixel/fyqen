import 'package:flutter/material.dart';

import 'package:fyqen/core/constants/app_constants.dart';
import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/core/validation/app_validators.dart';
import 'package:fyqen/features/authentication/application/errors/authentication_exception.dart';
import 'package:fyqen/features/authentication/presentation/mappers/authentication_failure_message_mapper.dart';
import 'package:fyqen/shared/widgets/app_button.dart';
import 'package:fyqen/shared/widgets/app_card.dart';
import 'package:fyqen/shared/widgets/app_page.dart';
import 'package:fyqen/shared/widgets/app_text_field.dart';

final class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    required this.isSubmitting,
    required this.failure,
    required this.onSubmit,
    required this.onOpenLogin,
    super.key,
    this.onFailureConsumed,
  });

  final bool isSubmitting;
  final AuthenticationException? failure;
  final Future<bool> Function({required String email, required String password})
  onSubmit;
  final VoidCallback onOpenLogin;
  final VoidCallback? onFailureConsumed;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

final class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.isSubmitting || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await widget.onSubmit(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _consumeFailure(String _) {
    if (widget.failure != null) {
      widget.onFailureConsumed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthenticationException? failure = widget.failure;
    return Scaffold(
      body: AppPage(
        children: <Widget>[
          const Text(AppConstants.appName, style: TextStyle(fontSize: 32)),
          const SizedBox(height: AppSpacing.xs),
          const Text(AppConstants.appSlogan),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Create account', style: TextStyle(fontSize: 24)),
                  if (failure != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      AuthenticationFailureMessageMapper.forRegistration(
                        failure,
                      ),
                      key: const Key('register_failure_message'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    key: const Key('register_email_field'),
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const <String>[AutofillHints.email],
                    enabled: !widget.isSubmitting,
                    validator: AppValidators.email,
                    onChanged: _consumeFailure,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    key: const Key('register_password_field'),
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    autofillHints: const <String>[AutofillHints.newPassword],
                    enabled: !widget.isSubmitting,
                    validator: (String? value) {
                      return AppValidators.minimumLength(value, minimum: 6);
                    },
                    onChanged: _consumeFailure,
                    suffixIcon: IconButton(
                      key: const Key('register_password_visibility_toggle'),
                      onPressed: widget.isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    key: const Key('register_confirm_password_field'),
                    controller: _confirmPasswordController,
                    label: 'Confirm password',
                    obscureText: _obscureConfirmation,
                    textInputAction: TextInputAction.done,
                    enabled: !widget.isSubmitting,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required.';
                      }
                      return value == _passwordController.text
                          ? null
                          : 'Passwords do not match.';
                    },
                    onChanged: _consumeFailure,
                    onSubmitted: (_) => _submit(),
                    suffixIcon: IconButton(
                      key: const Key('register_confirm_visibility_toggle'),
                      onPressed: widget.isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _obscureConfirmation = !_obscureConfirmation;
                              });
                            },
                      icon: Icon(
                        _obscureConfirmation
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    key: const Key('register_submit_button'),
                    label: 'Create account',
                    onPressed: _submit,
                    isLoading: widget.isSubmitting,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    key: const Key('open_login_button'),
                    label: 'Already have an account? Sign in',
                    onPressed: widget.isSubmitting ? null : widget.onOpenLogin,
                    variant: AppButtonVariant.text,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
