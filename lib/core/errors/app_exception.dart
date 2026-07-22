/// A controlled application failure that is safe to present to users.
final class AppException implements Exception {
  const AppException({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'AppException: $message';
}
