import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fyqen/features/authentication/application/use_cases/register_with_email_and_password.dart';
import 'package:fyqen/features/authentication/application/use_cases/sign_in_with_email_and_password.dart';
import 'package:fyqen/features/authentication/application/use_cases/sign_out.dart';
import 'package:fyqen/features/authentication/application/use_cases/watch_authentication_state.dart';
import 'package:fyqen/features/authentication/presentation/controllers/authentication_controller.dart';
import 'package:fyqen/features/authentication/presentation/screens/login_screen.dart';
import 'package:fyqen/features/authentication/presentation/screens/register_screen.dart';
import 'package:fyqen/features/authentication/presentation/state/authentication_view_state.dart';
import 'package:fyqen/features/authentication/presentation/widgets/authentication_loading_view.dart';

/// The presentation decision point between authentication and app content.
final class AuthenticationGate extends StatefulWidget {
  const AuthenticationGate({
    required this.watchAuthenticationState,
    required this.signInWithEmailAndPassword,
    required this.registerWithEmailAndPassword,
    required this.signOut,
    required this.authenticatedBuilder,
    super.key,
  });

  final WatchAuthenticationStateUseCase watchAuthenticationState;
  final SignInWithEmailAndPasswordUseCase signInWithEmailAndPassword;
  final RegisterWithEmailAndPasswordUseCase registerWithEmailAndPassword;
  final SignOutUseCase signOut;
  final Widget Function(BuildContext context, VoidCallback onSignOut)
  authenticatedBuilder;

  @override
  State<AuthenticationGate> createState() => _AuthenticationGateState();
}

final class _AuthenticationGateState extends State<AuthenticationGate> {
  late final AuthenticationController _controller;
  bool _showRegistration = false;

  @override
  void initState() {
    super.initState();
    _controller = AuthenticationController(
      watchAuthenticationState: widget.watchAuthenticationState,
      signInWithEmailAndPassword: widget.signInWithEmailAndPassword,
      registerWithEmailAndPassword: widget.registerWithEmailAndPassword,
      signOut: widget.signOut,
    )..start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openRegistration() {
    setState(() {
      _showRegistration = true;
    });
  }

  void _openLogin() {
    setState(() {
      _showRegistration = false;
    });
  }

  void _signOut() {
    unawaited(_controller.signOut());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final AuthenticationViewState state = _controller.state;
        return switch (state.status) {
          AuthenticationStatus.restoring => const AuthenticationLoadingView(),
          AuthenticationStatus.authenticated => KeyedSubtree(
            key: const Key('authenticated_app_shell'),
            child: KeyedSubtree(
              key: ValueKey<String>(state.user!.id),
              child: widget.authenticatedBuilder(context, _signOut),
            ),
          ),
          AuthenticationStatus.signedOut ||
          AuthenticationStatus.authenticating => _buildAuthenticationScreen(
            state,
          ),
        };
      },
    );
  }

  Widget _buildAuthenticationScreen(AuthenticationViewState state) {
    final bool isSubmitting =
        state.status == AuthenticationStatus.authenticating;
    return _showRegistration
        ? RegisterScreen(
            key: const Key('register_screen'),
            isSubmitting: isSubmitting,
            failure: state.failure,
            onSubmit: _controller.register,
            onOpenLogin: _openLogin,
            onFailureConsumed: _controller.clearFailure,
          )
        : LoginScreen(
            key: const Key('login_screen'),
            isSubmitting: isSubmitting,
            failure: state.failure,
            onSubmit: _controller.signIn,
            onOpenRegistration: _openRegistration,
            onFailureConsumed: _controller.clearFailure,
          );
  }
}
