import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyqen/features/authentication/application/repositories/authentication_repository.dart';
import 'package:fyqen/features/authentication/application/use_cases/get_current_authenticated_user.dart';
import 'package:fyqen/features/authentication/application/use_cases/register_with_email_and_password.dart';
import 'package:fyqen/features/authentication/application/use_cases/sign_in_with_email_and_password.dart';
import 'package:fyqen/features/authentication/application/use_cases/sign_out.dart';
import 'package:fyqen/features/authentication/application/use_cases/watch_authentication_state.dart';
import 'package:fyqen/features/authentication/infrastructure/repositories/firebase_authentication_repository.dart';
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

/// Explicitly composes the current application dependency graph.
final class AppCompositionRoot {
  AppCompositionRoot({
    PortfolioRepository? portfolioRepository,
    AuthenticationRepository? authenticationRepository,
    FirebaseAuth? firebaseAuth,
  }) : portfolioRepository = portfolioRepository ?? InMemoryPortfolioRepository(),
       authenticationRepository =
           authenticationRepository ??
           FirebaseAuthenticationRepository(firebaseAuth ?? FirebaseAuth.instance) {
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

    watchAuthenticationState = WatchAuthenticationStateUseCase(
      this.authenticationRepository,
    );
    getCurrentAuthenticatedUser = GetCurrentAuthenticatedUserUseCase(
      this.authenticationRepository,
    );
    signInWithEmailAndPassword = SignInWithEmailAndPasswordUseCase(
      this.authenticationRepository,
    );
    registerWithEmailAndPassword = RegisterWithEmailAndPasswordUseCase(
      this.authenticationRepository,
    );
    signOut = SignOutUseCase(this.authenticationRepository);
  }

  final PortfolioRepository portfolioRepository;
  final AuthenticationRepository authenticationRepository;

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

  late final WatchAuthenticationStateUseCase watchAuthenticationState;
  late final GetCurrentAuthenticatedUserUseCase getCurrentAuthenticatedUser;
  late final SignInWithEmailAndPasswordUseCase signInWithEmailAndPassword;
  late final RegisterWithEmailAndPasswordUseCase registerWithEmailAndPassword;
  late final SignOutUseCase signOut;
}
