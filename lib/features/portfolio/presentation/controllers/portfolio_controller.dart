import 'package:flutter/foundation.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/portfolio/application/errors/portfolio_persistence_exception.dart';
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
import 'package:fyqen/features/portfolio/presentation/state/portfolio_view_state.dart';

/// Coordinates one authenticated Portfolio presentation session.
final class PortfolioController extends ChangeNotifier {
  PortfolioController({
    required LoadPortfolioUseCase loadPortfolio,
    required SavePortfolioUseCase savePortfolio,
    required RenamePortfolioUseCase renamePortfolio,
    required AddAssetToPortfolioUseCase addAssetToPortfolio,
    required ReplaceAssetInPortfolioUseCase replaceAssetInPortfolio,
    required RemoveAssetFromPortfolioUseCase removeAssetFromPortfolio,
    required AddLiabilityToPortfolioUseCase addLiabilityToPortfolio,
    required ReplaceLiabilityInPortfolioUseCase replaceLiabilityInPortfolio,
    required RemoveLiabilityFromPortfolioUseCase removeLiabilityFromPortfolio,
    required DateTime Function() currentTime,
  }) : _loadPortfolio = loadPortfolio,
       _savePortfolio = savePortfolio,
       _renamePortfolio = renamePortfolio,
       _addAssetToPortfolio = addAssetToPortfolio,
       _replaceAssetInPortfolio = replaceAssetInPortfolio,
       _removeAssetFromPortfolio = removeAssetFromPortfolio,
       _addLiabilityToPortfolio = addLiabilityToPortfolio,
       _replaceLiabilityInPortfolio = replaceLiabilityInPortfolio,
       _removeLiabilityFromPortfolio = removeLiabilityFromPortfolio,
       _currentTime = currentTime;

  static const String _primaryPortfolioId = 'primary';
  static const String _initialPortfolioName = 'My Portfolio';

  final LoadPortfolioUseCase _loadPortfolio;
  final SavePortfolioUseCase _savePortfolio;
  final RenamePortfolioUseCase _renamePortfolio;
  final AddAssetToPortfolioUseCase _addAssetToPortfolio;
  final ReplaceAssetInPortfolioUseCase _replaceAssetInPortfolio;
  final RemoveAssetFromPortfolioUseCase _removeAssetFromPortfolio;
  final AddLiabilityToPortfolioUseCase _addLiabilityToPortfolio;
  final ReplaceLiabilityInPortfolioUseCase _replaceLiabilityInPortfolio;
  final RemoveLiabilityFromPortfolioUseCase _removeLiabilityFromPortfolio;
  final DateTime Function() _currentTime;

  PortfolioViewState _state = const PortfolioViewState.initial();
  bool _isDisposed = false;

  PortfolioViewState get state => _state;

  Future<void> load() async {
    if (_isDisposed ||
        _state.status == PortfolioStatus.loading ||
        _state.status == PortfolioStatus.saving) {
      return;
    }

    _setState(const PortfolioViewState.loading());

    try {
      final Portfolio? portfolio = await _loadPortfolio(_primaryPortfolioId);
      if (_isDisposed) {
        return;
      }

      if (portfolio != null) {
        _setState(PortfolioViewState.ready(portfolio));
        return;
      }

      final DateTime timestamp = _currentTime().toUtc();
      final Portfolio initialPortfolio = Portfolio(
        id: _primaryPortfolioId,
        name: _initialPortfolioName,
        assets: const <Asset>[],
        liabilities: const <Liability>[],
        createdAt: timestamp,
        updatedAt: timestamp,
      );
      await _savePortfolio(initialPortfolio);
      if (_isDisposed) {
        return;
      }
      _setState(PortfolioViewState.ready(initialPortfolio));
    } on PortfolioPersistenceException catch (failure) {
      _setState(PortfolioViewState.failure(failure: failure));
    }
  }

  Future<void> retryLoad() => load();

  Future<bool> renamePortfolio(String name) {
    return _saveMutation(
      (Portfolio portfolio, DateTime timestamp) => _renamePortfolio(
        portfolio: portfolio,
        name: name,
        updatedAt: timestamp,
      ),
    );
  }

  Future<bool> addAsset(Asset asset) {
    return _saveMutation(
      (Portfolio portfolio, DateTime timestamp) => _addAssetToPortfolio(
        portfolio: portfolio,
        asset: asset,
        updatedAt: timestamp,
      ),
    );
  }

  Future<bool> replaceAsset(Asset asset) {
    return _saveMutation(
      (Portfolio portfolio, DateTime timestamp) => _replaceAssetInPortfolio(
        portfolio: portfolio,
        asset: asset,
        updatedAt: timestamp,
      ),
    );
  }

  Future<bool> removeAsset(String assetId) {
    return _saveMutation(
      (Portfolio portfolio, DateTime timestamp) => _removeAssetFromPortfolio(
        portfolio: portfolio,
        assetId: assetId,
        updatedAt: timestamp,
      ),
    );
  }

  Future<bool> addLiability(Liability liability) {
    return _saveMutation(
      (Portfolio portfolio, DateTime timestamp) => _addLiabilityToPortfolio(
        portfolio: portfolio,
        liability: liability,
        updatedAt: timestamp,
      ),
    );
  }

  Future<bool> replaceLiability(Liability liability) {
    return _saveMutation(
      (Portfolio portfolio, DateTime timestamp) => _replaceLiabilityInPortfolio(
        portfolio: portfolio,
        liability: liability,
        updatedAt: timestamp,
      ),
    );
  }

  Future<bool> removeLiability(String liabilityId) {
    return _saveMutation(
      (Portfolio portfolio, DateTime timestamp) =>
          _removeLiabilityFromPortfolio(
            portfolio: portfolio,
            liabilityId: liabilityId,
            updatedAt: timestamp,
          ),
    );
  }

  Future<bool> _saveMutation(
    Portfolio Function(Portfolio portfolio, DateTime timestamp) mutate,
  ) async {
    final Portfolio? currentPortfolio = _state.portfolio;
    if (_isDisposed ||
        currentPortfolio == null ||
        _state.status == PortfolioStatus.saving) {
      return false;
    }

    final Portfolio updatedPortfolio = mutate(
      currentPortfolio,
      _currentTime().toUtc(),
    );
    _setState(PortfolioViewState.saving(currentPortfolio));

    try {
      await _savePortfolio(updatedPortfolio);
      if (_isDisposed) {
        return false;
      }
      _setState(PortfolioViewState.ready(updatedPortfolio));
      return true;
    } on PortfolioPersistenceException catch (failure) {
      _setState(
        PortfolioViewState.failure(
          portfolio: currentPortfolio,
          failure: failure,
        ),
      );
      return false;
    }
  }

  void _setState(PortfolioViewState state) {
    if (_isDisposed) {
      return;
    }
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
