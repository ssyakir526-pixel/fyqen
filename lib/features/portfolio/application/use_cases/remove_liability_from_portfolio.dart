import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

/// Removes a Liability through the Portfolio aggregate.
final class RemoveLiabilityFromPortfolioUseCase {
  const RemoveLiabilityFromPortfolioUseCase();

  Portfolio call({
    required Portfolio portfolio,
    required String liabilityId,
    required DateTime updatedAt,
  }) {
    return portfolio.removeLiability(
      liabilityId: liabilityId,
      updatedAt: updatedAt,
    );
  }
}
