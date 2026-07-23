import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fyqen/features/authentication/application/errors/authentication_exception.dart';
import 'package:fyqen/features/authentication/application/use_cases/register_with_email_and_password.dart';
import 'package:fyqen/features/authentication/application/use_cases/sign_in_with_email_and_password.dart';
import 'package:fyqen/features/authentication/application/use_cases/sign_out.dart';
import 'package:fyqen/features/authentication/application/use_cases/watch_authentication_state.dart';
import 'package:fyqen/features/authentication/domain/entities/authenticated_user.dart';
import 'package:fyqen/features/authentication/presentation/state/authentication_view_state.dart';

/// Coordinates authentication presentation state through application use cases.
final class AuthenticationController extends ChangeNotifier {
  AuthenticationController({
    required WatchAuthenticationStateUseCase watchAuthenticationState,
    required SignInWithEmailAndPasswordUseCase signInWithEmailAndPassword,
    required RegisterWithEmailAndPasswordUseCase registerWithEmailAndPassword,
    required SignOutUseCase signOut,
  }) : _watchAuthenticationState = watchAuthenticationState,
       _signInWithEmailAndPassword = signInWithEmailAndPassword,
       _registerWithEmailAndPassword = registerWithEmailAndPassword,
       _signOut = signOut;

  final WatchAuthenticationStateUseCase _watchAuthenticationState;
  final SignInWithEmailAndPasswordUseCase _signInWithEmailAndPassword;
  final RegisterWithEmailAndPasswordUseCase _registerWithEmailAndPassword;
  final SignOutUseCase _signOut;

  AuthenticationViewState _state = const AuthenticationViewState.restoring();
  StreamSubscription<AuthenticatedUser?>? _subscription;
  bool _operationInProgress = false;
  bool _isDisposed = false;

  AuthenticationViewState get state => _state;

  void start() {
    if (_subscription != null || _isDisposed) {
      return;
    }
    _subscription = _watchAuthenticationState().listen(
      _handleAuthenticationState,
      onError: _handleAuthenticationError,
    );
  }

  Future<bool> signIn({required String email, required String password}) {
    return _submit(
      () => _signInWithEmailAndPassword(email: email, password: password),
    );
  }

  Future<bool> register({required String email, required String password}) {
    return _submit(
      () => _registerWithEmailAndPassword(email: email, password: password),
    );
  }

  Future<void> signOut() async {
    if (_operationInProgress ||
        _state.status != AuthenticationStatus.authenticated) {
      return;
    }
    _operationInProgress = true;
    try {
      await _signOut();
    } on AuthenticationException {
      _operationInProgress = false;
    }
  }

  void clearFailure() {
    if (_state.status == AuthenticationStatus.signedOut &&
        _state.failure != null) {
      _setState(const AuthenticationViewState.signedOut());
    }
  }

  Future<bool> _submit(Future<AuthenticatedUser> Function() operation) async {
    if (_operationInProgress || _isDisposed) {
      return false;
    }
    _operationInProgress = true;
    _setState(const AuthenticationViewState.authenticating());
    try {
      await operation();
      return true;
    } on AuthenticationException catch (exception) {
      _operationInProgress = false;
      _setState(AuthenticationViewState.signedOut(failure: exception));
      return false;
    }
  }

  void _handleAuthenticationState(AuthenticatedUser? user) {
    _operationInProgress = false;
    _setState(
      user == null
          ? const AuthenticationViewState.signedOut()
          : AuthenticationViewState.authenticated(user),
    );
  }

  void _handleAuthenticationError(Object error, StackTrace _) {
    _operationInProgress = false;
    final AuthenticationException failure = error is AuthenticationException
        ? error
        : const AuthenticationException(
            code: AuthenticationFailureCode.unknown,
            message: 'Authentication state could not be restored.',
          );
    _setState(AuthenticationViewState.signedOut(failure: failure));
  }

  void _setState(AuthenticationViewState state) {
    if (_isDisposed || identical(_state, state)) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
