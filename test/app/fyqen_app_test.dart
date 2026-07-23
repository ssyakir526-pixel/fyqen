import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/app/app_composition_root.dart';
import 'package:fyqen/app/fyqen_app.dart';
import 'package:fyqen/app/navigation/fyqen_shell.dart';
import 'package:fyqen/core/constants/app_constants.dart';
import 'package:fyqen/core/theme/app_colors.dart';
import 'package:fyqen/features/authentication/application/repositories/authentication_repository.dart';
import 'package:fyqen/features/authentication/domain/entities/authenticated_user.dart';
import 'package:fyqen/features/dashboard/presentation/pages/dashboard_placeholder_page.dart';
import 'package:fyqen/features/dashboard/presentation/widgets/journey_overview_card.dart';
import 'package:fyqen/features/dashboard/presentation/widgets/net_worth_hero_card.dart';
import 'package:fyqen/features/dashboard/presentation/widgets/quick_actions_card.dart';
import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/shared/widgets/section_title.dart';

void main() {
  testWidgets('renders the Dashboard layout foundation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      FyqenApp(
        compositionRoot: AppCompositionRoot(
          authenticationRepository: _AuthenticatedRepository(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(FyqenShell), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(6));
    expect(find.byType(DashboardPlaceholderPage), findsOneWidget);
    expect(find.text(AppConstants.appName), findsOneWidget);
    final List<SectionTitle> sectionTitles = tester
        .widgetList<SectionTitle>(find.byType(SectionTitle))
        .toList();
    final List<String> sectionLabels = sectionTitles
        .map((SectionTitle sectionTitle) => sectionTitle.title)
        .toList();
    final List<OutlinedButton> quickActionButtons = tester
        .widgetList<OutlinedButton>(find.byType(OutlinedButton))
        .toList();

    expect(find.text('Welcome back, My Portfolio'), findsOneWidget);
    expect(find.byType(NetWorthHeroCard), findsOneWidget);
    expect(find.text('Net worth unavailable'), findsNothing);
    expect(find.text('0'), findsOneWidget);
    expect(
      find.byKey(const Key('financial-independence-no-target-card')),
      findsOneWidget,
    );
    expect(find.text('Set your FI target'), findsOneWidget);
    expect(find.byType(JourneyOverviewCard), findsOneWidget);
    expect(find.text('Journey unavailable'), findsOneWidget);
    expect(find.byType(QuickActionsCard), findsOneWidget);
    expect(find.text('Add asset'), findsOneWidget);
    expect(find.text('Add liability'), findsOneWidget);
    expect(
      sectionLabels,
      containsAll(<String>[
        'Net Worth',
        'Financial Independence',
        'Journey',
        'Quick Actions',
      ]),
    );
    expect(quickActionButtons, hasLength(2));
    expect(
      quickActionButtons.every(
        (OutlinedButton button) => button.onPressed == null,
      ),
      isTrue,
    );
    expect(find.byType(MaterialApp), findsOneWidget);

    final NavigationBar navigationBar = tester.widget<NavigationBar>(
      find.byKey(const Key('fyqen_navigation_bar')),
    );
    final BuildContext scaffoldContext = tester.element(find.byType(Scaffold));
    final ThemeData theme = Theme.of(scaffoldContext);
    expect(navigationBar.selectedIndex, 0);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preserves an injected root through widget rebuilds', (
    WidgetTester tester,
  ) async {
    final _RecordingPortfolioRepository portfolioRepository =
        _RecordingPortfolioRepository();
    final _AuthenticatedRepository authenticationRepository =
        _AuthenticatedRepository();
    final AppCompositionRoot root = AppCompositionRoot(
      portfolioRepository: portfolioRepository,
      authenticationRepository: authenticationRepository,
    );

    await tester.pumpWidget(FyqenApp(compositionRoot: root));
    await tester.pump();
    await tester.pump();
    await tester.pumpWidget(FyqenApp(compositionRoot: root));
    await tester.pump();

    expect(identical(root.portfolioRepository, portfolioRepository), isTrue);
    expect(authenticationRepository.watchCalls, 1);
    expect(portfolioRepository.findCalls, 1);
    expect(portfolioRepository.saveCalls, 1);
    expect(find.byType(FyqenShell), findsOneWidget);
  });

  testWidgets('keeps signed-out users outside the authenticated shell', (
    WidgetTester tester,
  ) async {
    final _RecordingPortfolioRepository portfolioRepository =
        _RecordingPortfolioRepository();

    await tester.pumpWidget(
      FyqenApp(
        compositionRoot: AppCompositionRoot(
          portfolioRepository: portfolioRepository,
          authenticationRepository: _SignedOutRepository(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('login_screen')), findsOneWidget);
    expect(find.byType(FyqenShell), findsNothing);
    expect(portfolioRepository.totalCalls, 0);
  });
}

final class _AuthenticatedRepository implements AuthenticationRepository {
  final AuthenticatedUser _user = AuthenticatedUser(
    id: 'user-1',
    email: 'user@example.com',
  );

  int watchCalls = 0;

  @override
  Stream<AuthenticatedUser?> watchAuthenticationState() {
    watchCalls += 1;
    return Stream<AuthenticatedUser?>.value(_user);
  }

  @override
  AuthenticatedUser? getCurrentUser() => _user;

  @override
  Future<AuthenticatedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return Future<AuthenticatedUser>.value(_user);
  }

  @override
  Future<AuthenticatedUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return Future<AuthenticatedUser>.value(_user);
  }

  @override
  Future<void> signOut() => Future<void>.value();
}

final class _SignedOutRepository implements AuthenticationRepository {
  @override
  Stream<AuthenticatedUser?> watchAuthenticationState() {
    return Stream<AuthenticatedUser?>.value(null);
  }

  @override
  AuthenticatedUser? getCurrentUser() => null;

  @override
  Future<AuthenticatedUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return Future<AuthenticatedUser>.error(UnimplementedError());
  }

  @override
  Future<AuthenticatedUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return Future<AuthenticatedUser>.error(UnimplementedError());
  }

  @override
  Future<void> signOut() => Future<void>.value();
}

final class _RecordingPortfolioRepository implements PortfolioRepository {
  int findCalls = 0;
  int saveCalls = 0;
  int deleteCalls = 0;

  int get totalCalls => findCalls + saveCalls + deleteCalls;

  @override
  Future<Portfolio?> findById(String portfolioId) {
    findCalls += 1;
    return Future<Portfolio?>.value();
  }

  @override
  Future<void> save(Portfolio portfolio) {
    saveCalls += 1;
    return Future<void>.value();
  }

  @override
  Future<void> deleteById(String portfolioId) {
    deleteCalls += 1;
    return Future<void>.value();
  }
}
