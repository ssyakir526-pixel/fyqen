import 'package:fyqen/features/authentication/application/errors/authentication_exception.dart';

abstract final class AuthenticationFailureMessageMapper {
  const AuthenticationFailureMessageMapper._();

  static String forSignIn(AuthenticationException failure) {
    return switch (failure.code) {
      AuthenticationFailureCode.invalidEmail => 'Enter a valid email address.',
      AuthenticationFailureCode.userNotFound => 'No account was found for this email.',
      AuthenticationFailureCode.wrongPassword ||
      AuthenticationFailureCode.invalidCredential =>
        'The email or password is incorrect.',
      AuthenticationFailureCode.userDisabled => 'This account is currently disabled.',
      AuthenticationFailureCode.networkRequestFailed =>
        'Check your internet connection and try again.',
      AuthenticationFailureCode.tooManyRequests =>
        'Too many attempts. Please try again later.',
      AuthenticationFailureCode.operationNotAllowed =>
        'Email sign-in is currently unavailable.',
      _ => 'We could not sign you in. Please try again.',
    };
  }

  static String forRegistration(AuthenticationException failure) {
    return switch (failure.code) {
      AuthenticationFailureCode.weakPassword =>
        'Use a password with at least 6 characters.',
      AuthenticationFailureCode.emailAlreadyInUse =>
        'An account already exists for this email.',
      AuthenticationFailureCode.invalidEmail => 'Enter a valid email address.',
      AuthenticationFailureCode.operationNotAllowed =>
        'Email registration is currently unavailable.',
      AuthenticationFailureCode.networkRequestFailed =>
        'Check your internet connection and try again.',
      AuthenticationFailureCode.tooManyRequests =>
        'Too many attempts. Please try again later.',
      _ => 'We could not create your account. Please try again.',
    };
  }
}
