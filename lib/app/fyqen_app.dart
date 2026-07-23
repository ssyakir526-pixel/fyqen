import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/authentication/presentation/widgets/authentication_gate.dart';
import 'app_composition_root.dart';
import 'navigation/fyqen_shell.dart';

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
        signInWithEmailAndPassword:
            _compositionRoot.signInWithEmailAndPassword,
        registerWithEmailAndPassword:
            _compositionRoot.registerWithEmailAndPassword,
        signOut: _compositionRoot.signOut,
        authenticatedBuilder: (BuildContext context, VoidCallback onSignOut) {
          return FyqenShell(onSignOut: onSignOut);
        },
      ),
    );
  }
}
