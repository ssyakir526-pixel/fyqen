import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/authentication/presentation/widgets/authentication_gate.dart';
import '../features/portfolio/presentation/widgets/portfolio_session.dart';
import '../features/streak/presentation/state/daily_streak_view_state.dart';
import '../features/streak/presentation/widgets/daily_streak_session.dart';
import 'app_composition_root.dart';

/// The root widget for the Fyqen application.
class FyqenApp extends StatefulWidget {
  const FyqenApp({super.key, this.compositionRoot});

  final AppCompositionRoot? compositionRoot;

  @override
  State<FyqenApp> createState() => _FyqenAppState();
}

final class _FyqenAppState extends State<FyqenApp> {
  late final AppCompositionRoot _compositionRoot;

  @override
  void initState() {
    super.initState();
    _compositionRoot =
        widget.compositionRoot ?? AppCompositionRoot.production();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: AuthenticationGate(
        watchAuthenticationState: _compositionRoot.watchAuthenticationState,
        signInWithEmailAndPassword: _compositionRoot.signInWithEmailAndPassword,
        registerWithEmailAndPassword:
            _compositionRoot.registerWithEmailAndPassword,
        signOut: _compositionRoot.signOut,
        authenticatedBuilder: (BuildContext context, VoidCallback onSignOut) {
          return DailyStreakSession(
            key: const Key('daily_streak_session'),
            repository: _compositionRoot.dailyStreakRepository,
            clock: _compositionRoot.appClock,
            builder:
                (
                  BuildContext context,
                  DailyStreakViewState streakState,
                  Future<void> Function() onRetry,
                ) {
                  return PortfolioSession(
                    loadPortfolio: _compositionRoot.loadPortfolio,
                    savePortfolio: _compositionRoot.savePortfolio,
                    renamePortfolio: _compositionRoot.renamePortfolio,
                    addAssetToPortfolio: _compositionRoot.addAssetToPortfolio,
                    replaceAssetInPortfolio:
                        _compositionRoot.replaceAssetInPortfolio,
                    removeAssetFromPortfolio:
                        _compositionRoot.removeAssetFromPortfolio,
                    addLiabilityToPortfolio:
                        _compositionRoot.addLiabilityToPortfolio,
                    replaceLiabilityInPortfolio:
                        _compositionRoot.replaceLiabilityInPortfolio,
                    removeLiabilityFromPortfolio:
                        _compositionRoot.removeLiabilityFromPortfolio,
                    setFinancialIndependenceTarget:
                        _compositionRoot.setFinancialIndependenceTarget,
                    onSignOut: onSignOut,
                    dailyStreakState: streakState,
                    onRetryDailyStreak: onRetry,
                  );
                },
          );
        },
      ),
    );
  }
}
