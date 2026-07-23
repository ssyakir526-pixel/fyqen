import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

/// Adds a Liability through the Portfolio aggregate.
final class AddLiabilityToPortfolioUseCase {
  const AddLiabilityToPortfolioUseCase();

  Portfolio call({
    required Portfolio portfolio,
    required Liability liability,
    required DateTime updatedAt,
  }) {
    return portfolio.addLiability(liability: liability, updatedAt: updatedAt);
  }
}
