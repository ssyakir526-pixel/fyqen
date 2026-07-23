import 'package:fyqen/features/authentication/application/repositories/authentication_repository.dart';
import 'package:fyqen/features/authentication/domain/entities/authenticated_user.dart';

/// Gets the current authentication snapshot through the application contract.
final class GetCurrentAuthenticatedUserUseCase {
  const GetCurrentAuthenticatedUserUseCase(this._repository);

  final AuthenticationRepository _repository;

  AuthenticatedUser? call() {
    return _repository.getCurrentUser();
  }
}
