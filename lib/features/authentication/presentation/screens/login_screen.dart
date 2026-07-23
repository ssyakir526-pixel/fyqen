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

final class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.isSubmitting,
    required this.failure,
    required this.onSubmit,
    required this.onOpenRegistration,
    super.key,
    this.onFailureConsumed,
  });

  final bool isSubmitting;
  final AuthenticationException? failure;
  final Future<bool> Function({required String email, required String password})
  onSubmit;
  final VoidCallback onOpenRegistration;
  final VoidCallback? onFailureConsumed;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  const Text('Sign in', style: TextStyle(fontSize: 24)),
                  if (failure != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      AuthenticationFailureMessageMapper.forSignIn(failure),
                      key: const Key('login_failure_message'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    key: const Key('login_email_field'),
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
                    key: const Key('login_password_field'),
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const <String>[AutofillHints.password],
                    enabled: !widget.isSubmitting,
                    validator: AppValidators.requiredField,
                    onChanged: _consumeFailure,
                    onSubmitted: (_) => _submit(),
                    suffixIcon: IconButton(
                      key: const Key('login_password_visibility_toggle'),
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
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    key: const Key('login_submit_button'),
                    label: 'Sign in',
                    onPressed: _submit,
                    isLoading: widget.isSubmitting,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    key: const Key('open_registration_button'),
                    label: 'Create an account',
                    onPressed: widget.isSubmitting
                        ? null
                        : widget.onOpenRegistration,
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
