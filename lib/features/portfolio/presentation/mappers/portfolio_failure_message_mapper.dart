import 'package:fyqen/features/portfolio/application/errors/portfolio_persistence_exception.dart';

/// Converts persistence failures into stable, user-safe presentation text.
abstract final class PortfolioFailureMessageMapper {
  const PortfolioFailureMessageMapper._();

  static String messageFor(PortfolioPersistenceFailureCode code) {
    return switch (code) {
      PortfolioPersistenceFailureCode.unauthenticated =>
        'Your session is no longer available. Please sign in again.',
      PortfolioPersistenceFailureCode.permissionDenied =>
        'We could not access your portfolio.',
      PortfolioPersistenceFailureCode.unavailable =>
        'The portfolio service is temporarily unavailable.',
      PortfolioPersistenceFailureCode.notFound =>
        'Your portfolio could not be found.',
      PortfolioPersistenceFailureCode.invalidData =>
        'Your portfolio data could not be read safely.',
      PortfolioPersistenceFailureCode.cancelled =>
        'The portfolio request was cancelled.',
      PortfolioPersistenceFailureCode.deadlineExceeded =>
        'The request took too long. Please try again.',
      PortfolioPersistenceFailureCode.unknown =>
        'We could not load your portfolio. Please try again.',
    };
  }
}
