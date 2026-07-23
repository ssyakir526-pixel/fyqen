/// Provides the current stable authenticated user ID to infrastructure code.
abstract interface class AuthenticatedUserIdProvider {
  String? get currentUserId;
}
