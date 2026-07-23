import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

/// Removes an Asset through the Portfolio aggregate.
final class RemoveAssetFromPortfolioUseCase {
  const RemoveAssetFromPortfolioUseCase();

  Portfolio call({
    required Portfolio portfolio,
    required String assetId,
    required DateTime updatedAt,
  }) {
    return portfolio.removeAsset(assetId: assetId, updatedAt: updatedAt);
  }
}
