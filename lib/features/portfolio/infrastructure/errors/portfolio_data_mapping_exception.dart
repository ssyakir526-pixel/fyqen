/// Describes malformed Portfolio persistence data at a precise field path.
final class PortfolioDataMappingException implements Exception {
  const PortfolioDataMappingException({
    required this.path,
    required this.message,
    this.cause,
  });

  final String path;
  final String message;
  final Object? cause;

  @override
  String toString() {
    return 'PortfolioDataMappingException(path: $path, message: $message)';
  }
}
