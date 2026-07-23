enum PortfolioPersistenceFailureCode {
  unauthenticated,
  permissionDenied,
  unavailable,
  notFound,
  invalidData,
  cancelled,
  deadlineExceeded,
  unknown,
}

/// A Firebase-independent persistence failure safe for application handling.
final class PortfolioPersistenceException implements Exception {
  const PortfolioPersistenceException({
    required this.code,
    required this.message,
  });

  final PortfolioPersistenceFailureCode code;
  final String message;

  @override
  String toString() {
    return 'PortfolioPersistenceException(code: $code, message: $message)';
  }
}
