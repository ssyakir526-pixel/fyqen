/// An immutable, Firebase-independent authenticated identity.
final class AuthenticatedUser {
  factory AuthenticatedUser({required String id, required String? email}) {
    final String normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Authenticated user ID must not be empty.');
    }

    return AuthenticatedUser._(id: normalizedId, email: email);
  }

  const AuthenticatedUser._({required this.id, required this.email});

  final String id;
  final String? email;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is AuthenticatedUser &&
            other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() => 'AuthenticatedUser(id: $id, email: $email)';
}
