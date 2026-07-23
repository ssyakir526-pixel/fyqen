import 'package:flutter/material.dart';
import 'package:fyqen/shared/widgets/app_loading_indicator.dart';

/// Authenticated-area loading state while a Portfolio session resolves.
final class PortfolioLoadingView extends StatelessWidget {
  const PortfolioLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: AppLoadingIndicator(message: 'Loading your portfolio...'),
    );
  }
}
