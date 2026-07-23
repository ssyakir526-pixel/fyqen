import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';
import 'package:fyqen/features/portfolio/application/use_cases/add_asset_to_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/add_liability_to_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/delete_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/load_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/remove_asset_from_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/remove_liability_from_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/rename_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/replace_asset_in_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/replace_liability_in_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/save_portfolio.dart';
import 'package:fyqen/features/portfolio/infrastructure/repositories/in_memory_portfolio_repository.dart';

/// Explicitly composes the current Portfolio application dependency graph.
final class AppCompositionRoot {
  AppCompositionRoot({PortfolioRepository? portfolioRepository})
    : portfolioRepository = portfolioRepository ?? InMemoryPortfolioRepository() {
    loadPortfolio = LoadPortfolioUseCase(this.portfolioRepository);
    savePortfolio = SavePortfolioUseCase(this.portfolioRepository);
    deletePortfolio = DeletePortfolioUseCase(this.portfolioRepository);

    renamePortfolio = const RenamePortfolioUseCase();
    addAssetToPortfolio = const AddAssetToPortfolioUseCase();
    replaceAssetInPortfolio = const ReplaceAssetInPortfolioUseCase();
    removeAssetFromPortfolio = const RemoveAssetFromPortfolioUseCase();
    addLiabilityToPortfolio = const AddLiabilityToPortfolioUseCase();
    replaceLiabilityInPortfolio = const ReplaceLiabilityInPortfolioUseCase();
    removeLiabilityFromPortfolio = const RemoveLiabilityFromPortfolioUseCase();
  }

  final PortfolioRepository portfolioRepository;

  late final LoadPortfolioUseCase loadPortfolio;
  late final SavePortfolioUseCase savePortfolio;
  late final DeletePortfolioUseCase deletePortfolio;

  late final RenamePortfolioUseCase renamePortfolio;
  late final AddAssetToPortfolioUseCase addAssetToPortfolio;
  late final ReplaceAssetInPortfolioUseCase replaceAssetInPortfolio;
  late final RemoveAssetFromPortfolioUseCase removeAssetFromPortfolio;
  late final AddLiabilityToPortfolioUseCase addLiabilityToPortfolio;
  late final ReplaceLiabilityInPortfolioUseCase replaceLiabilityInPortfolio;
  late final RemoveLiabilityFromPortfolioUseCase removeLiabilityFromPortfolio;
}
