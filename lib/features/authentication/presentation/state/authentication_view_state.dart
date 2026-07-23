import 'package:fyqen/features/authentication/application/errors/authentication_exception.dart';
import 'package:fyqen/features/authentication/domain/entities/authenticated_user.dart';

enum AuthenticationStatus {
  restoring,
  signedOut,
  authenticating,
  authenticated,
}

/// Immutable presentation state for the authentication gate.
final class AuthenticationViewState {
  const AuthenticationViewState._({
    required this.status,
    required this.user,
    required this.failure,
  });

  const AuthenticationViewState.restoring()
    : this._(status: AuthenticationStatus.restoring, user: null, failure: null);

  const AuthenticationViewState.signedOut({AuthenticationException? failure})
    : this._(
        status: AuthenticationStatus.signedOut,
        user: null,
        failure: failure,
      );

  const AuthenticationViewState.authenticating()
    : this._(
        status: AuthenticationStatus.authenticating,
        user: null,
        failure: null,
      );

  const AuthenticationViewState.authenticated(AuthenticatedUser user)
    : this._(
        status: AuthenticationStatus.authenticated,
        user: user,
        failure: null,
      );

  final AuthenticationStatus status;
  final AuthenticatedUser? user;
  final AuthenticationException? failure;
}
