import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/authentication/domain/entities/authenticated_user.dart';

void main() {
  group('AuthenticatedUser', () {
    test('preserves a normalized stable ID and nullable email', () {
      final AuthenticatedUser user = AuthenticatedUser(
        id: ' user-1 ',
        email: null,
      );

      expect(user.id, 'user-1');
      expect(user.email, isNull);
    });

    test('rejects empty IDs and uses ID-based entity equality', () {
      final AuthenticatedUser first = AuthenticatedUser(
        id: 'user-1',
        email: 'user@example.com',
      );
      final AuthenticatedUser sameId = AuthenticatedUser(
        id: 'user-1',
        email: null,
      );

      expect(() => AuthenticatedUser(id: '  ', email: null), throwsArgumentError);
      expect(first, sameId);
      expect(first.hashCode, sameId.hashCode);
    });
  });
}
