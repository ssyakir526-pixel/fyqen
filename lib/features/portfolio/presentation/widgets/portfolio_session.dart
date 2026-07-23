import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fyqen/app/navigation/fyqen_shell.dart';
import 'package:fyqen/features/portfolio/application/use_cases/add_asset_to_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/add_liability_to_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/load_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/remove_asset_from_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/remove_liability_from_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/rename_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/replace_asset_in_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/replace_liability_in_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/save_portfolio.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:fyqen/features/portfolio/presentation/state/portfolio_view_state.dart';

import 'portfolio_failure_view.dart';
import 'portfolio_loading_view.dart';

/// Owns one PortfolioController for the authenticated shell lifecycle.
final class PortfolioSession extends StatefulWidget {
  const PortfolioSession({
    required this.loadPortfolio,
    required this.savePortfolio,
    required this.renamePortfolio,
    required this.addAssetToPortfolio,
    required this.replaceAssetInPortfolio,
    required this.removeAssetFromPortfolio,
    required this.addLiabilityToPortfolio,
    required this.replaceLiabilityInPortfolio,
    required this.removeLiabilityFromPortfolio,
    required this.onSignOut,
    super.key,
    this.currentTime = DateTime.now,
  });

  final LoadPortfolioUseCase loadPortfolio;
  final SavePortfolioUseCase savePortfolio;
  final RenamePortfolioUseCase renamePortfolio;
  final AddAssetToPortfolioUseCase addAssetToPortfolio;
  final ReplaceAssetInPortfolioUseCase replaceAssetInPortfolio;
  final RemoveAssetFromPortfolioUseCase removeAssetFromPortfolio;
  final AddLiabilityToPortfolioUseCase addLiabilityToPortfolio;
  final ReplaceLiabilityInPortfolioUseCase replaceLiabilityInPortfolio;
  final RemoveLiabilityFromPortfolioUseCase removeLiabilityFromPortfolio;
  final VoidCallback onSignOut;
  final DateTime Function() currentTime;

  @override
  State<PortfolioSession> createState() => _PortfolioSessionState();
}

final class _PortfolioSessionState extends State<PortfolioSession> {
  late final PortfolioController _controller;
  int _portfolioItemIdSequence = 0;

  @override
  void initState() {
    super.initState();
    _controller = PortfolioController(
      loadPortfolio: widget.loadPortfolio,
      savePortfolio: widget.savePortfolio,
      renamePortfolio: widget.renamePortfolio,
      addAssetToPortfolio: widget.addAssetToPortfolio,
      replaceAssetInPortfolio: widget.replaceAssetInPortfolio,
      removeAssetFromPortfolio: widget.removeAssetFromPortfolio,
      addLiabilityToPortfolio: widget.addLiabilityToPortfolio,
      replaceLiabilityInPortfolio: widget.replaceLiabilityInPortfolio,
      removeLiabilityFromPortfolio: widget.removeLiabilityFromPortfolio,
      currentTime: widget.currentTime,
    );
    unawaited(_controller.load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final PortfolioViewState state = _controller.state;
        final Portfolio? portfolio = state.portfolio;

        if (state.status == PortfolioStatus.initial ||
            state.status == PortfolioStatus.loading) {
          return const PortfolioLoadingView();
        }

        if (state.status == PortfolioStatus.failure && portfolio == null) {
          return PortfolioFailureView(
            failure: state.failure!,
            onRetry: _controller.retryLoad,
          );
        }

        return FyqenShell(
          onSignOut: widget.onSignOut,
          portfolio: portfolio!,
          isPortfolioSaving: state.status == PortfolioStatus.saving,
          onAddAsset: _controller.addAsset,
          onReplaceAsset: _controller.replaceAsset,
          onRemoveAsset: _controller.removeAsset,
          onAddLiability: _controller.addLiability,
          onReplaceLiability: _controller.replaceLiability,
          onRemoveLiability: _controller.removeLiability,
          createAssetId: _createAssetId,
          createLiabilityId: _createLiabilityId,
          currentTime: widget.currentTime,
        );
      },
    );
  }

  String _createAssetId() {
    return _createPortfolioItemId('asset');
  }

  String _createLiabilityId() {
    return _createPortfolioItemId('liability');
  }

  String _createPortfolioItemId(String prefix) {
    final int timestamp = widget.currentTime().toUtc().microsecondsSinceEpoch;
    final String itemId = '$prefix-$timestamp-$_portfolioItemIdSequence';
    _portfolioItemIdSequence += 1;
    return itemId;
  }
}
