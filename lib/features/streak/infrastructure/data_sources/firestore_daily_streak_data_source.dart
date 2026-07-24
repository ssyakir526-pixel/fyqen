import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyqen/features/authentication/application/providers/authenticated_user_id_provider.dart';
import 'package:fyqen/features/streak/infrastructure/dtos/daily_streak_dto.dart';

/// User-scoped Firestore transport for the single Daily Streak document.
final class FirestoreDailyStreakDataSource {
  FirestoreDailyStreakDataSource({
    required FirebaseFirestore firestore,
    required AuthenticatedUserIdProvider authenticatedUserIdProvider,
  }) : _firestore = firestore,
       _authenticatedUserIdProvider = authenticatedUserIdProvider;

  final FirebaseFirestore _firestore;
  final AuthenticatedUserIdProvider _authenticatedUserIdProvider;

  Future<DailyStreakDto?> load() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _reference()
        .get();
    return _fromSnapshot(snapshot);
  }

  Stream<DailyStreakDto?> watch() {
    return _reference().snapshots().map(_fromSnapshot);
  }

  Future<DailyStreakDto?> transaction(
    DailyStreakDto? Function(DailyStreakDto? current) update,
  ) {
    final DocumentReference<Map<String, dynamic>> reference = _reference();
    return _firestore.runTransaction((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction
          .get(reference);
      final DailyStreakDto? updated = update(_fromSnapshot(snapshot));
      if (updated != null) {
        transaction.set(reference, _toFirestoreMap(updated));
      }
      return updated;
    });
  }

  DocumentReference<Map<String, dynamic>> _reference() {
    final String? userId = _authenticatedUserIdProvider.currentUserId?.trim();
    if (userId == null || userId.isEmpty) {
      throw StateError('An authenticated user is required for Daily Streak.');
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('engagement')
        .doc('dailyStreak');
  }

  static DailyStreakDto? _fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    if (!snapshot.exists) {
      return null;
    }
    final Map<String, dynamic>? data = snapshot.data();
    if (data == null) {
      return null;
    }
    final Map<String, Object?> mapped = Map<String, Object?>.from(data);
    final Object? timestamp = mapped['lastOpenedDate'];
    if (timestamp is Timestamp) {
      mapped['lastOpenedDate'] = timestamp.toDate();
    }
    return DailyStreakDto.fromMap(mapped);
  }

  static Map<String, dynamic> _toFirestoreMap(DailyStreakDto dto) {
    final Map<String, Object?> map = dto.toMap();
    final DateTime? lastOpenedDate = dto.lastOpenedDate;
    if (lastOpenedDate != null) {
      map['lastOpenedDate'] = Timestamp.fromDate(lastOpenedDate);
    }
    return Map<String, dynamic>.from(map);
  }
}
