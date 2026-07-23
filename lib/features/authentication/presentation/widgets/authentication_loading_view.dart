import 'package:flutter/material.dart';

import 'package:fyqen/core/constants/app_constants.dart';
import 'package:fyqen/core/theme/app_spacing.dart';

/// Minimal loading content shown while authentication state is restoring.
final class AuthenticationLoadingView extends StatelessWidget {
  const AuthenticationLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Semantics(
          key: const Key('authentication_loading_view'),
          label: 'Restoring your session',
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.md),
              Text(AppConstants.appName),
            ],
          ),
        ),
      ),
    );
  }
}
