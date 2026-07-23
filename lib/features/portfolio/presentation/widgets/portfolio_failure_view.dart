import 'package:flutter/material.dart';
import 'package:fyqen/features/portfolio/application/errors/portfolio_persistence_exception.dart';
import 'package:fyqen/features/portfolio/presentation/mappers/portfolio_failure_message_mapper.dart';
import 'package:fyqen/shared/widgets/app_error_state.dart';

/// Safe authenticated-area failure state for Portfolio loading.
final class PortfolioFailureView extends StatelessWidget {
  const PortfolioFailureView({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final PortfolioPersistenceException failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppErrorState(
        title: 'Portfolio unavailable',
        message: PortfolioFailureMessageMapper.messageFor(failure.code),
        onRetry: onRetry,
      ),
    );
  }
}
