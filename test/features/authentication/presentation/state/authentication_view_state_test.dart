import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/authentication/application/errors/authentication_exception.dart';
import 'package:fyqen/features/authentication/domain/entities/authenticated_user.dart';
import 'package:fyqen/features/authentication/presentation/state/authentication_view_state.dart';

void main() {
  test('authentication view states preserve their invariants', () {
    final AuthenticatedUser user = AuthenticatedUser(
      id: 'user-1',
      email: 'user@example.com',
    );
    final AuthenticationException failure = const AuthenticationException(
      code: AuthenticationFailureCode.invalidCredential,
      message: 'Invalid credential.',
    );

    const AuthenticationViewState restoring =
        AuthenticationViewState.restoring();
    final AuthenticationViewState signedOut = AuthenticationViewState.signedOut(
      failure: failure,
    );
    const AuthenticationViewState authenticating =
        AuthenticationViewState.authenticating();
    final AuthenticationViewState authenticated =
        AuthenticationViewState.authenticated(user);

    expect(restoring.status, AuthenticationStatus.restoring);
    expect(restoring.user, isNull);
    expect(restoring.failure, isNull);
    expect(signedOut.status, AuthenticationStatus.signedOut);
    expect(signedOut.user, isNull);
    expect(signedOut.failure, same(failure));
    expect(authenticating.status, AuthenticationStatus.authenticating);
    expect(authenticating.user, isNull);
    expect(authenticating.failure, isNull);
    expect(authenticated.status, AuthenticationStatus.authenticated);
    expect(authenticated.user, same(user));
    expect(authenticated.failure, isNull);
  });
}
