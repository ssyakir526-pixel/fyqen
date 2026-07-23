import 'package:fyqen/features/authentication/application/repositories/authentication_repository.dart';

/// Signs out through the application contract.
final class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthenticationRepository _repository;

  Future<void> call() {
    return _repository.signOut();
  }
}
