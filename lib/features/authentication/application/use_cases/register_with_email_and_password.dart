import 'package:fyqen/features/authentication/application/repositories/authentication_repository.dart';
import 'package:fyqen/features/authentication/domain/entities/authenticated_user.dart';

/// Registers with email and password through the application contract.
final class RegisterWithEmailAndPasswordUseCase {
  const RegisterWithEmailAndPasswordUseCase(this._repository);

  final AuthenticationRepository _repository;

  Future<AuthenticatedUser> call({
    required String email,
    required String password,
  }) {
    return _repository.registerWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
