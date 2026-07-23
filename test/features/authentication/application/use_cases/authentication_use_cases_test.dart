import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/authentication/application/errors/authentication_exception.dart';
import 'package:fyqen/features/authentication/application/repositories/authentication_repository.dart';
import 'package:fyqen/features/authentication/application/use_cases/get_current_authenticated_user.dart';
import 'package:fyqen/features/authentication/application/use_cases/register_with_email_and_password.dart';
import 'package:fyqen/features/authentication/application/use_cases/sign_in_with_email_and_password.dart';
import 'package:fyqen/features/authentication/application/use_cases/sign_out.dart';
import 'package:fyqen/features/authentication/application/use_cases/watch_authentication_state.dart';
import 'package:fyqen/features/authentication/domain/entities/authenticated_user.dart';

void main() {
  final AuthenticatedUser user = AuthenticatedUser(
    id: 'user-1',
    email: 'user@example.com',
  );

  group('authentication use cases', () {
    test('watch delegates once and preserves stream events and identity', () async {
      final Stream<AuthenticatedUser?> stream =
          Stream<AuthenticatedUser?>.fromIterable(<AuthenticatedUser?>[user, null]);
      final _FakeAuthenticationRepository repository =
          _FakeAuthenticationRepository(authenticationState: stream);
      final WatchAuthenticationStateUseCase useCase =
          WatchAuthenticationStateUseCase(repository);

      final Stream<AuthenticatedUser?> result = useCase();

      expect(identical(result, stream), isTrue);
      expect(repository.watchCalls, 1);
      await expectLater(result, emitsInOrder(<Object?>[same(user), isNull]));
    });

    test('watch preserves repository stream errors', () async {
      final AuthenticationException error = const AuthenticationException(
        code: AuthenticationFailureCode.networkRequestFailed,
        message: 'Network unavailable.',
      );
      final _FakeAuthenticationRepository repository =
          _FakeAuthenticationRepository(
            authenticationState: Stream<AuthenticatedUser?>.error(error),
          );

      await expectLater(
        WatchAuthenticationStateUseCase(repository)(),
        emitsError(same(error)),
      );
    });

    test('gets the current user or null and preserves exceptions', () {
      final _FakeAuthenticationRepository signedIn =
          _FakeAuthenticationRepository(currentUser: user);
      final _FakeAuthenticationRepository signedOut = _FakeAuthenticationRepository();
      final ArgumentError error = ArgumentError('current user failed');
      final _FakeAuthenticationRepository failing =
          _FakeAuthenticationRepository(currentUserError: error);

      expect(GetCurrentAuthenticatedUserUseCase(signedIn)(), same(user));
      expect(GetCurrentAuthenticatedUserUseCase(signedOut)(), isNull);
      expect(() => GetCurrentAuthenticatedUserUseCase(failing)(), throwsA(same(error)));
      expect(signedIn.currentUserCalls, 1);
      expect(signedOut.currentUserCalls, 1);
      expect(failing.currentUserCalls, 1);
    });

    test('sign-in forwards credentials exactly and preserves errors', () async {
      final _FakeAuthenticationRepository repository =
          _FakeAuthenticationRepository(signInUser: user);
      final SignInWithEmailAndPasswordUseCase useCase =
          SignInWithEmailAndPasswordUseCase(repository);

      final AuthenticatedUser result = await useCase(
        email: 'user@example.com',
        password: 'test-password',
      );

      expect(result, same(user));
      expect(repository.signInCalls, 1);
      expect(repository.receivedSignInEmail, 'user@example.com');
      expect(repository.receivedSignInPassword, 'test-password');
      expect(repository.registerCalls, 0);
      expect(repository.signOutCalls, 0);
      expect(repository.watchCalls, 0);

      final AuthenticationException error = const AuthenticationException(
        code: AuthenticationFailureCode.invalidCredential,
        message: 'Invalid credential.',
      );
      await expectLater(
        SignInWithEmailAndPasswordUseCase(
          _FakeAuthenticationRepository(signInError: error),
        )(email: 'user@example.com', password: 'test-password'),
        throwsA(same(error)),
      );
    });

    test('registration forwards credentials exactly and preserves errors', () async {
      final _FakeAuthenticationRepository repository =
          _FakeAuthenticationRepository(registrationUser: user);
      final RegisterWithEmailAndPasswordUseCase useCase =
          RegisterWithEmailAndPasswordUseCase(repository);

      final AuthenticatedUser result = await useCase(
        email: 'user@example.com',
        password: 'test-password',
      );

      expect(result, same(user));
      expect(repository.registerCalls, 1);
      expect(repository.receivedRegistrationEmail, 'user@example.com');
      expect(repository.receivedRegistrationPassword, 'test-password');
      expect(repository.signInCalls, 0);
      expect(repository.signOutCalls, 0);
      expect(repository.watchCalls, 0);

      final AuthenticationException error = const AuthenticationException(
        code: AuthenticationFailureCode.emailAlreadyInUse,
        message: 'Email already in use.',
      );
      await expectLater(
        RegisterWithEmailAndPasswordUseCase(
          _FakeAuthenticationRepository(registrationError: error),
        )(email: 'user@example.com', password: 'test-password'),
        throwsA(same(error)),
      );
    });

    test('sign-out delegates once and preserves errors', () async {
      final _FakeAuthenticationRepository repository =
          _FakeAuthenticationRepository();

      await SignOutUseCase(repository)();

      expect(repository.signOutCalls, 1);
      expect(repository.watchCalls, 0);
      expect(repository.currentUserCalls, 0);
      expect(repository.signInCalls, 0);
      expect(repository.registerCalls, 0);

      final AuthenticationException error = const AuthenticationException(
        code: AuthenticationFailureCode.unknown,
        message: 'Sign-out failed.',
      );
      await expectLater(
        SignOutUseCase(_FakeAuthenticationRepository(signOutError: error))(),
        throwsA(same(error)),
      );
    });
  });
}

final class _FakeAuthenticationRepository implements AuthenticationRepository {
  _FakeAuthenticationRepository({
    Stream<AuthenticatedUser?>? authenticationState,
    this.currentUser,
    this.currentUserError,
    this.signInUser,
    this.signInError,
    this.registrationUser,
    this.registrationError,
    this.signOutError,
  }) : _authenticationState =
           authenticationState ?? Stream<AuthenticatedUser?>.empty();

  final Stream<AuthenticatedUser?> _authenticationState;
  final AuthenticatedUser? currentUser;
  final Object? currentUserError;
  final AuthenticatedUser? signInUser;
  final Object? signInError;
  final AuthenticatedUser? registrationUser;
  final Object? registrationError;
  final Object? signOutError;
  int watchCalls = 0;
  int currentUserCalls = 0;
  int signInCalls = 0;
  int registerCalls = 0;
  int signOutCalls = 0;
  String? receivedSignInEmail;
  String? receivedSignInPassword;
  String? receivedRegistrationEmail;
  String? receivedRegistrationPassword;

  @override
  Stream<AuthenticatedUser?> watchAuthenticationState() {
    watchCalls += 1;
    return _authenticationState;
  }

  @override
  AuthenticatedUser? getCurrentUser() {
    currentUserCalls += 1;
    if (currentUserError != null) {
      throw currentUserError!;
    }
    return currentUser;
  }

  @override
  Future<AuthenticatedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    signInCalls += 1;
    receivedSignInEmail = email;
    receivedSignInPassword = password;
    return signInError == null
        ? Future<AuthenticatedUser>.value(signInUser!)
        : Future<AuthenticatedUser>.error(signInError!);
  }

  @override
  Future<AuthenticatedUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    registerCalls += 1;
    receivedRegistrationEmail = email;
    receivedRegistrationPassword = password;
    return registrationError == null
        ? Future<AuthenticatedUser>.value(registrationUser!)
        : Future<AuthenticatedUser>.error(registrationError!);
  }

  @override
  Future<void> signOut() {
    signOutCalls += 1;
    return signOutError == null
        ? Future<void>.value()
        : Future<void>.error(signOutError!);
  }
}
