import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyqen/features/authentication/application/errors/authentication_exception.dart';
import 'package:fyqen/features/authentication/application/repositories/authentication_repository.dart';
import 'package:fyqen/features/authentication/domain/entities/authenticated_user.dart';

/// Firebase-backed implementation of the application authentication contract.
final class FirebaseAuthenticationRepository implements AuthenticationRepository {
  const FirebaseAuthenticationRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AuthenticatedUser?> watchAuthenticationState() {
    return _firebaseAuth.authStateChanges().map(_mapOptionalUser);
  }

  @override
  AuthenticatedUser? getCurrentUser() {
    return _mapOptionalUser(_firebaseAuth.currentUser);
  }

  @override
  Future<AuthenticatedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _firebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
      return _requireAuthenticatedUser(credential.user);
    } on FirebaseAuthException catch (exception) {
      throw _translateException(exception);
    }
  }

  @override
  Future<AuthenticatedUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
      return _requireAuthenticatedUser(credential.user);
    } on FirebaseAuthException catch (exception) {
      throw _translateException(exception);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (exception) {
      throw _translateException(exception);
    }
  }

  static AuthenticatedUser? _mapOptionalUser(User? user) {
    return user == null ? null : _mapUser(user);
  }

  static AuthenticatedUser _mapUser(User user) {
    return AuthenticatedUser(id: user.uid, email: user.email);
  }

  static AuthenticatedUser _requireAuthenticatedUser(User? user) {
    if (user == null) {
      throw const AuthenticationException(
        code: AuthenticationFailureCode.unknown,
        message: 'Authentication completed without an authenticated user.',
      );
    }
    return _mapUser(user);
  }

  static AuthenticationException _translateException(
    FirebaseAuthException exception,
  ) {
    switch (exception.code) {
      case 'invalid-email':
        return const AuthenticationException(
          code: AuthenticationFailureCode.invalidEmail,
          message: 'The email address is invalid.',
        );
      case 'weak-password':
        return const AuthenticationException(
          code: AuthenticationFailureCode.weakPassword,
          message: 'The password does not meet the required strength.',
        );
      case 'email-already-in-use':
        return const AuthenticationException(
          code: AuthenticationFailureCode.emailAlreadyInUse,
          message: 'An account already exists for this email address.',
        );
      case 'user-not-found':
        return const AuthenticationException(
          code: AuthenticationFailureCode.userNotFound,
          message: 'No account exists for this email address.',
        );
      case 'wrong-password':
        return const AuthenticationException(
          code: AuthenticationFailureCode.wrongPassword,
          message: 'The supplied password is incorrect.',
        );
      case 'invalid-credential':
        return const AuthenticationException(
          code: AuthenticationFailureCode.invalidCredential,
          message: 'The supplied authentication credential is invalid.',
        );
      case 'user-disabled':
        return const AuthenticationException(
          code: AuthenticationFailureCode.userDisabled,
          message: 'This account is disabled.',
        );
      case 'operation-not-allowed':
        return const AuthenticationException(
          code: AuthenticationFailureCode.operationNotAllowed,
          message: 'This authentication operation is not enabled.',
        );
      case 'network-request-failed':
        return const AuthenticationException(
          code: AuthenticationFailureCode.networkRequestFailed,
          message: 'The authentication request could not reach the network.',
        );
      case 'too-many-requests':
        return const AuthenticationException(
          code: AuthenticationFailureCode.tooManyRequests,
          message: 'Too many authentication attempts were made.',
        );
      default:
        return const AuthenticationException(
          code: AuthenticationFailureCode.unknown,
          message: 'The authentication operation could not be completed.',
        );
    }
  }
}
