import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/authentication/application/errors/authentication_exception.dart';
import 'package:fyqen/features/authentication/application/repositories/authentication_repository.dart';
import 'package:fyqen/features/authentication/application/use_cases/register_with_email_and_password.dart';
import 'package:fyqen/features/authentication/application/use_cases/sign_in_with_email_and_password.dart';
import 'package:fyqen/features/authentication/application/use_cases/sign_out.dart';
import 'package:fyqen/features/authentication/application/use_cases/watch_authentication_state.dart';
import 'package:fyqen/features/authentication/domain/entities/authenticated_user.dart';
import 'package:fyqen/features/authentication/presentation/controllers/authentication_controller.dart';
import 'package:fyqen/features/authentication/presentation/state/authentication_view_state.dart';

void main() {
  test('uses auth-state events as the source of truth and cancels on dispose', () async {
    final StreamController<AuthenticatedUser?> stream =
        StreamController<AuthenticatedUser?>();
    final _AuthenticationFake repository = _AuthenticationFake(stream.stream);
    final AuthenticationController controller = _controller(repository);
    final AuthenticatedUser user = AuthenticatedUser(
      id: 'user-1',
      email: 'user@example.com',
    );

    expect(controller.state.status, AuthenticationStatus.restoring);
    controller.start();
    controller.start();
    expect(repository.watchCalls, 1);

    stream.add(user);
    await pumpEventQueue();
    expect(controller.state.status, AuthenticationStatus.authenticated);
    expect(controller.state.user, same(user));

    stream.add(null);
    await pumpEventQueue();
    expect(controller.state.status, AuthenticationStatus.signedOut);

    controller.dispose();
    await stream.close();
  });

  test('forwards credentials and exposes authentication failures safely', () async {
    final StreamController<AuthenticatedUser?> stream =
        StreamController<AuthenticatedUser?>();
    final AuthenticationException failure = const AuthenticationException(
      code: AuthenticationFailureCode.invalidCredential,
      message: 'Invalid credential.',
    );
    final _AuthenticationFake repository = _AuthenticationFake(
      stream.stream,
      signInError: failure,
    );
    final AuthenticationController controller = _controller(repository);
    controller.start();

    final bool succeeded = await controller.signIn(
      email: 'user@example.com',
      password: 'test-password',
    );

    expect(succeeded, isFalse);
    expect(repository.signInCalls, 1);
    expect(repository.email, 'user@example.com');
    expect(repository.password, 'test-password');
    expect(controller.state.status, AuthenticationStatus.signedOut);
    expect(controller.state.failure, same(failure));
    expect(repository.registerCalls, 0);
    expect(repository.signOutCalls, 0);

    controller.dispose();
    await stream.close();
  });
}

AuthenticationController _controller(_AuthenticationFake repository) {
  return AuthenticationController(
    watchAuthenticationState: WatchAuthenticationStateUseCase(repository),
    signInWithEmailAndPassword: SignInWithEmailAndPasswordUseCase(repository),
    registerWithEmailAndPassword: RegisterWithEmailAndPasswordUseCase(repository),
    signOut: SignOutUseCase(repository),
  );
}

final class _AuthenticationFake implements AuthenticationRepository {
  _AuthenticationFake(this._stream, {this.signInError});

  final Stream<AuthenticatedUser?> _stream;
  final AuthenticationException? signInError;
  int watchCalls = 0;
  int signInCalls = 0;
  int registerCalls = 0;
  int signOutCalls = 0;
  String? email;
  String? password;

  @override
  Stream<AuthenticatedUser?> watchAuthenticationState() {
    watchCalls += 1;
    return _stream;
  }

  @override
  AuthenticatedUser? getCurrentUser() => null;

  @override
  Future<AuthenticatedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    signInCalls += 1;
    this.email = email;
    this.password = password;
    return signInError == null
        ? Future<AuthenticatedUser>.error(StateError('Unexpected sign-in.'))
        : Future<AuthenticatedUser>.error(signInError!);
  }

  @override
  Future<AuthenticatedUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    registerCalls += 1;
    return Future<AuthenticatedUser>.error(StateError('Unexpected registration.'));
  }

  @override
  Future<void> signOut() {
    signOutCalls += 1;
    return Future<void>.value();
  }
}
