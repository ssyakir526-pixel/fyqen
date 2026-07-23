import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';

/// Replaces the Financial Independence target through the Portfolio aggregate.
final class SetFinancialIndependenceTargetUseCase {
  const SetFinancialIndependenceTargetUseCase();

  Portfolio call({
    required Portfolio portfolio,
    required FinancialIndependenceTarget target,
    required DateTime updatedAt,
  }) {
    return portfolio.setFinancialIndependenceTarget(
      target: target,
      updatedAt: updatedAt,
    );
  }
}
