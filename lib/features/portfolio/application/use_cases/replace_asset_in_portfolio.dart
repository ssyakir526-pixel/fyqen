import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

/// Replaces an Asset through the Portfolio aggregate.
final class ReplaceAssetInPortfolioUseCase {
  const ReplaceAssetInPortfolioUseCase();

  Portfolio call({
    required Portfolio portfolio,
    required Asset asset,
    required DateTime updatedAt,
  }) {
    return portfolio.replaceAsset(asset: asset, updatedAt: updatedAt);
  }
}
