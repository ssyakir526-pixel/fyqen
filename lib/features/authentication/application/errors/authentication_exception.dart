/// Stable categories for failures occurring at the authentication boundary.
enum AuthenticationFailureCode {
  invalidEmail,
  weakPassword,
  emailAlreadyInUse,
  userNotFound,
  wrongPassword,
  invalidCredential,
  userDisabled,
  operationNotAllowed,
  networkRequestFailed,
  tooManyRequests,
  unknown,
}

/// A Firebase-independent failure safe for future presentation handling.
final class AuthenticationException implements Exception {
  const AuthenticationException({required this.code, required this.message});

  final AuthenticationFailureCode code;
  final String message;

  @override
  String toString() {
    return 'AuthenticationException(code: $code, message: $message)';
  }
}
