import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

/// Replaces a Liability through the Portfolio aggregate.
final class ReplaceLiabilityInPortfolioUseCase {
  const ReplaceLiabilityInPortfolioUseCase();

  Portfolio call({
    required Portfolio portfolio,
    required Liability liability,
    required DateTime updatedAt,
  }) {
    return portfolio.replaceLiability(
      liability: liability,
      updatedAt: updatedAt,
    );
  }
}
