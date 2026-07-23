import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

/// Renames a Portfolio through its immutable aggregate operation.
final class RenamePortfolioUseCase {
  const RenamePortfolioUseCase();

  Portfolio call({
    required Portfolio portfolio,
    required String name,
    required DateTime updatedAt,
  }) {
    return portfolio.rename(name: name, updatedAt: updatedAt);
  }
}
