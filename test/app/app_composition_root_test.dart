import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/app/app_composition_root.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/authentication/application/errors/authentication_exception.dart';
import 'package:fyqen/features/authentication/application/providers/authenticated_user_id_provider.dart';
import 'package:fyqen/features/authentication/application/repositories/authentication_repository.dart';
import 'package:fyqen/features/authentication/application/use_cases/get_current_authenticated_user.dart';
import 'package:fyqen/features/authentication/application/use_cases/register_with_email_and_password.dart';
import 'package:fyqen/features/authentication/application/use_cases/sign_in_with_email_and_password.dart';
import 'package:fyqen/features/authentication/application/use_cases/sign_out.dart';
import 'package:fyqen/features/authentication/application/use_cases/watch_authentication_state.dart';
import 'package:fyqen/features/authentication/domain/entities/authenticated_user.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
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
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/infrastructure/repositories/in_memory_portfolio_repository.dart';

void main() {
  Portfolio createPortfolio({String id = 'portfolio-1'}) {
    return Portfolio(
      id: id,
      name: 'Main Portfolio',
      assets: const <Asset>[],
      liabilities: const <Liability>[],
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  AppCompositionRoot createRoot({
    PortfolioRepository? portfolioRepository,
    AuthenticationRepository? authenticationRepository,
    AuthenticatedUserIdProvider? authenticatedUserIdProvider,
  }) {
    return AppCompositionRoot(
      portfolioRepository: portfolioRepository,
      authenticationRepository:
          authenticationRepository ?? _RecordingAuthenticationRepository(),
      authenticatedUserIdProvider: authenticatedUserIdProvider,
    );
  }

  group('AppCompositionRoot', () {
    test('creates the default graph with all Portfolio use cases', () {
      final AppCompositionRoot root = createRoot();

      expect(root.portfolioRepository, isA<InMemoryPortfolioRepository>());
      expect(root.portfolioRepository, isA<PortfolioRepository>());
      expect(root.loadPortfolio, isA<LoadPortfolioUseCase>());
      expect(root.savePortfolio, isA<SavePortfolioUseCase>());
      expect(root.deletePortfolio, isA<DeletePortfolioUseCase>());
      expect(root.renamePortfolio, isA<RenamePortfolioUseCase>());
      expect(root.addAssetToPortfolio, isA<AddAssetToPortfolioUseCase>());
      expect(root.replaceAssetInPortfolio, isA<ReplaceAssetInPortfolioUseCase>());
      expect(root.removeAssetFromPortfolio, isA<RemoveAssetFromPortfolioUseCase>());
      expect(
        root.addLiabilityToPortfolio,
        isA<AddLiabilityToPortfolioUseCase>(),
      );
      expect(
        root.replaceLiabilityInPortfolio,
        isA<ReplaceLiabilityInPortfolioUseCase>(),
      );
      expect(
        root.removeLiabilityFromPortfolio,
        isA<RemoveLiabilityFromPortfolioUseCase>(),
      );
    });

    test('preserves an explicitly supplied in-memory repository', () {
      final InMemoryPortfolioRepository repository =
          InMemoryPortfolioRepository();

      final AppCompositionRoot root = createRoot(
        portfolioRepository: repository,
      );

      expect(identical(root.portfolioRepository, repository), isTrue);
    });

    test('uses a supplied repository without construction side effects', () async {
      final _RecordingPortfolioRepository repository =
          _RecordingPortfolioRepository();
      final AppCompositionRoot root = createRoot(
        portfolioRepository: repository,
      );
      final Portfolio portfolio = createPortfolio();

      expect(identical(root.portfolioRepository, repository), isTrue);
      expect(repository.findCalls, 0);
      expect(repository.saveCalls, 0);
      expect(repository.deleteCalls, 0);

      await root.savePortfolio(portfolio);
      final Portfolio? loaded = await root.loadPortfolio(' portfolio-1 ');
      await root.deletePortfolio('portfolio-1');

      expect(repository.saveCalls, 1);
      expect(identical(repository.savedPortfolio, portfolio), isTrue);
      expect(repository.findCalls, 1);
      expect(repository.findId, ' portfolio-1 ');
      expect(identical(loaded, portfolio), isTrue);
      expect(repository.deleteCalls, 1);
      expect(repository.deleteId, 'portfolio-1');
    });

    test('preserves repository exceptions through composed workflows', () async {
      final ArgumentError error = ArgumentError('save failed');
      final AppCompositionRoot root = createRoot(
        portfolioRepository: _RecordingPortfolioRepository(saveError: error),
      );

      await expectLater(root.savePortfolio(createPortfolio()), throwsA(same(error)));
    });

    test('keeps aggregate operations synchronous and repository-free', () {
      final _RecordingPortfolioRepository repository =
          _RecordingPortfolioRepository();
      final AppCompositionRoot root = createRoot(
        portfolioRepository: repository,
      );
      final Portfolio original = createPortfolio();

      final Portfolio renamed = root.renamePortfolio(
        portfolio: original,
        name: 'Renamed Portfolio',
        updatedAt: DateTime.utc(2026, 1, 2),
      );

      expect(renamed.name, 'Renamed Portfolio');
      expect(identical(renamed, original), isFalse);
      expect(repository.findCalls, 0);
      expect(repository.saveCalls, 0);
      expect(repository.deleteCalls, 0);
    });

    test('shares default persistence within a root and isolates separate roots', () async {
      final AppCompositionRoot firstRoot = createRoot();
      final AppCompositionRoot secondRoot = createRoot();
      final Portfolio portfolio = createPortfolio();

      await firstRoot.savePortfolio(portfolio);

      expect(
        identical(firstRoot.portfolioRepository, secondRoot.portfolioRepository),
        isFalse,
      );
      expect(identical(await firstRoot.loadPortfolio('portfolio-1'), portfolio), isTrue);
      expect(await secondRoot.loadPortfolio('portfolio-1'), isNull);
    });

    test('composes supplied authentication dependencies without side effects', () async {
      final AuthenticatedUser user = AuthenticatedUser(
        id: 'user-1',
        email: 'user@example.com',
      );
      final _RecordingAuthenticationRepository repository =
          _RecordingAuthenticationRepository(
            currentUser: user,
            signInUser: user,
            registrationUser: user,
          );
      final AppCompositionRoot root = createRoot(
        authenticationRepository: repository,
      );

      expect(identical(root.authenticationRepository, repository), isTrue);
      expect(root.watchAuthenticationState, isA<WatchAuthenticationStateUseCase>());
      expect(
        root.getCurrentAuthenticatedUser,
        isA<GetCurrentAuthenticatedUserUseCase>(),
      );
      expect(
        root.signInWithEmailAndPassword,
        isA<SignInWithEmailAndPasswordUseCase>(),
      );
      expect(
        root.registerWithEmailAndPassword,
        isA<RegisterWithEmailAndPasswordUseCase>(),
      );
      expect(root.signOut, isA<SignOutUseCase>());
      expect(repository.totalCalls, 0);

      expect(root.getCurrentAuthenticatedUser(), same(user));
      expect(await root.signInWithEmailAndPassword(
        email: 'user@example.com',
        password: 'test-password',
      ), same(user));
      expect(await root.registerWithEmailAndPassword(
        email: 'user@example.com',
        password: 'test-password',
      ), same(user));
      await root.signOut();

      expect(repository.currentUserCalls, 1);
      expect(repository.signInCalls, 1);
      expect(repository.registerCalls, 1);
      expect(repository.signOutCalls, 1);
      expect(repository.watchCalls, 0);
    });

    test('preserves an identity-provider override without reading it', () {
      final _RecordingAuthenticatedUserIdProvider provider =
          _RecordingAuthenticatedUserIdProvider('user-1');

      final AppCompositionRoot root = createRoot(
        authenticatedUserIdProvider: provider,
      );

      expect(identical(root.authenticatedUserIdProvider, provider), isTrue);
      expect(provider.currentUserIdReads, 0);
    });

    test('keeps supplied authentication repositories isolated and propagates errors', () async {
      final AuthenticationException error = const AuthenticationException(
        code: AuthenticationFailureCode.unknown,
        message: 'Sign-out failed.',
      );
      final _RecordingAuthenticationRepository firstRepository =
          _RecordingAuthenticationRepository(signOutError: error);
      final _RecordingAuthenticationRepository secondRepository =
          _RecordingAuthenticationRepository();
      final AppCompositionRoot firstRoot = createRoot(
        authenticationRepository: firstRepository,
      );
      final AppCompositionRoot secondRoot = createRoot(
        authenticationRepository: secondRepository,
      );

      expect(
        identical(firstRoot.authenticationRepository, secondRoot.authenticationRepository),
        isFalse,
      );
      await expectLater(firstRoot.signOut(), throwsA(same(error)));
      await secondRoot.signOut();

      expect(firstRepository.signOutCalls, 1);
      expect(secondRepository.signOutCalls, 1);
    });
  });
}

final class _RecordingAuthenticatedUserIdProvider
    implements AuthenticatedUserIdProvider {
  _RecordingAuthenticatedUserIdProvider(this.userId);

  final String? userId;
  int currentUserIdReads = 0;

  @override
  String? get currentUserId {
    currentUserIdReads += 1;
    return userId;
  }
}

final class _RecordingPortfolioRepository implements PortfolioRepository {
  _RecordingPortfolioRepository({this.saveError});

  final Object? saveError;
  int findCalls = 0;
  int saveCalls = 0;
  int deleteCalls = 0;
  String? findId;
  String? deleteId;
  Portfolio? savedPortfolio;

  @override
  Future<Portfolio?> findById(String portfolioId) {
    findCalls += 1;
    findId = portfolioId;
    return Future<Portfolio?>.value(savedPortfolio);
  }

  @override
  Future<void> save(Portfolio portfolio) {
    saveCalls += 1;
    savedPortfolio = portfolio;
    return saveError == null
        ? Future<void>.value()
        : Future<void>.error(saveError!);
  }

  @override
  Future<void> deleteById(String portfolioId) {
    deleteCalls += 1;
    deleteId = portfolioId;
    return Future<void>.value();
  }
}

final class _RecordingAuthenticationRepository
    implements AuthenticationRepository {
  _RecordingAuthenticationRepository({
    this.currentUser,
    this.signInUser,
    this.registrationUser,
    this.signOutError,
    Stream<AuthenticatedUser?>? authenticationState,
  }) : _authenticationState =
           authenticationState ?? Stream<AuthenticatedUser?>.empty();

  final AuthenticatedUser? currentUser;
  final AuthenticatedUser? signInUser;
  final AuthenticatedUser? registrationUser;
  final Object? signOutError;
  final Stream<AuthenticatedUser?> _authenticationState;
  int watchCalls = 0;
  int currentUserCalls = 0;
  int signInCalls = 0;
  int registerCalls = 0;
  int signOutCalls = 0;

  int get totalCalls {
    return watchCalls + currentUserCalls + signInCalls + registerCalls + signOutCalls;
  }

  @override
  Stream<AuthenticatedUser?> watchAuthenticationState() {
    watchCalls += 1;
    return _authenticationState;
  }

  @override
  AuthenticatedUser? getCurrentUser() {
    currentUserCalls += 1;
    return currentUser;
  }

  @override
  Future<AuthenticatedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    signInCalls += 1;
    return Future<AuthenticatedUser>.value(signInUser!);
  }

  @override
  Future<AuthenticatedUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    registerCalls += 1;
    return Future<AuthenticatedUser>.value(registrationUser!);
  }

  @override
  Future<void> signOut() {
    signOutCalls += 1;
    return signOutError == null
        ? Future<void>.value()
        : Future<void>.error(signOutError!);
  }
}
