import 'package:fyqen/features/authentication/domain/entities/authenticated_user.dart';

/// Defines the authentication capabilities required by the application layer.
abstract interface class AuthenticationRepository {
  Stream<AuthenticatedUser?> watchAuthenticationState();

  AuthenticatedUser? getCurrentUser();

  Future<AuthenticatedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthenticatedUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
