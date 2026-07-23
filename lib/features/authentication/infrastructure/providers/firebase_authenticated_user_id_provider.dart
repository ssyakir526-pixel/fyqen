import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyqen/features/authentication/application/providers/authenticated_user_id_provider.dart';

/// Reads the current Firebase identity through an application-owned contract.
final class FirebaseAuthenticatedUserIdProvider
    implements AuthenticatedUserIdProvider {
  const FirebaseAuthenticatedUserIdProvider({
    required FirebaseAuth firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  final FirebaseAuth _firebaseAuth;

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;
}
