import 'package:fyqen/features/authentication/application/repositories/authentication_repository.dart';
import 'package:fyqen/features/authentication/domain/entities/authenticated_user.dart';

/// Observes the current authentication state through the application contract.
final class WatchAuthenticationStateUseCase {
  const WatchAuthenticationStateUseCase(this._repository);

  final AuthenticationRepository _repository;

  Stream<AuthenticatedUser?> call() {
    return _repository.watchAuthenticationState();
  }
}
