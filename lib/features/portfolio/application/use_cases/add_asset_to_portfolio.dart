import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

/// Adds an Asset through the Portfolio aggregate.
final class AddAssetToPortfolioUseCase {
  const AddAssetToPortfolioUseCase();

  Portfolio call({
    required Portfolio portfolio,
    required Asset asset,
    required DateTime updatedAt,
  }) {
    return portfolio.addAsset(asset: asset, updatedAt: updatedAt);
  }
}
