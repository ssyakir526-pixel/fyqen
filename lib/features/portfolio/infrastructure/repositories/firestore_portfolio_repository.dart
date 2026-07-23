import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyqen/features/authentication/application/providers/authenticated_user_id_provider.dart';
import 'package:fyqen/features/portfolio/application/errors/portfolio_persistence_exception.dart';
import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/infrastructure/errors/portfolio_data_mapping_exception.dart';
import 'package:fyqen/features/portfolio/infrastructure/mappers/portfolio_mapper.dart';

/// Firestore persistence for one complete Portfolio aggregate per user.
final class FirestorePortfolioRepository implements PortfolioRepository {
  FirestorePortfolioRepository({
    required FirebaseFirestore firestore,
    required AuthenticatedUserIdProvider authenticatedUserIdProvider,
    PortfolioMapper portfolioMapper = const PortfolioMapper(),
  }) : _firestore = firestore,
       _authenticatedUserIdProvider = authenticatedUserIdProvider,
       _portfolioMapper = portfolioMapper;

  static const String _usersCollection = 'users';
  static const String _portfolioCollection = 'portfolio';
  static const String _primaryPortfolioDocument = 'primary';

  final FirebaseFirestore _firestore;
  final AuthenticatedUserIdProvider _authenticatedUserIdProvider;
  final PortfolioMapper _portfolioMapper;

  @override
  Future<Portfolio?> findById(String portfolioId) async {
    final DocumentReference<Map<String, dynamic>> reference =
        _documentReference();
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await reference
          .get();
      if (!snapshot.exists) {
        return null;
      }
      final Map<String, dynamic>? data = snapshot.data();
      if (data == null) {
        throw const PortfolioPersistenceException(
          code: PortfolioPersistenceFailureCode.invalidData,
          message: 'Portfolio persistence data is missing.',
        );
      }
      try {
        return _portfolioMapper.fromMap(Map<String, Object?>.from(data));
      } on PortfolioDataMappingException catch (_) {
        throw PortfolioPersistenceException(
          code: PortfolioPersistenceFailureCode.invalidData,
          message: 'Portfolio persistence data is invalid.',
        );
      }
    } on FirebaseException catch (exception) {
      throw _translateException(exception);
    }
  }

  @override
  Future<void> save(Portfolio portfolio) async {
    final DocumentReference<Map<String, dynamic>> reference =
        _documentReference();
    try {
      await reference.set(
        Map<String, dynamic>.from(_portfolioMapper.toMap(portfolio)),
      );
    } on FirebaseException catch (exception) {
      throw _translateException(exception);
    }
  }

  @override
  Future<void> deleteById(String portfolioId) async {
    final DocumentReference<Map<String, dynamic>> reference =
        _documentReference();
    try {
      await reference.delete();
    } on FirebaseException catch (exception) {
      throw _translateException(exception);
    }
  }

  DocumentReference<Map<String, dynamic>> _documentReference() {
    final String? userId = _authenticatedUserIdProvider.currentUserId;
    final String? normalizedUserId = userId?.trim();
    if (normalizedUserId == null || normalizedUserId.isEmpty) {
      throw const PortfolioPersistenceException(
        code: PortfolioPersistenceFailureCode.unauthenticated,
        message: 'An authenticated user is required to access a portfolio.',
      );
    }
    return _firestore
        .collection(_usersCollection)
        .doc(normalizedUserId)
        .collection(_portfolioCollection)
        .doc(_primaryPortfolioDocument);
  }

  static PortfolioPersistenceException _translateException(
    FirebaseException exception,
  ) {
    return switch (exception.code) {
      'permission-denied' => const PortfolioPersistenceException(
        code: PortfolioPersistenceFailureCode.permissionDenied,
        message: 'Portfolio access is not permitted.',
      ),
      'unavailable' => const PortfolioPersistenceException(
        code: PortfolioPersistenceFailureCode.unavailable,
        message: 'Portfolio persistence is currently unavailable.',
      ),
      'not-found' => const PortfolioPersistenceException(
        code: PortfolioPersistenceFailureCode.notFound,
        message: 'Portfolio persistence data was not found.',
      ),
      'cancelled' => const PortfolioPersistenceException(
        code: PortfolioPersistenceFailureCode.cancelled,
        message: 'Portfolio persistence was cancelled.',
      ),
      'deadline-exceeded' => const PortfolioPersistenceException(
        code: PortfolioPersistenceFailureCode.deadlineExceeded,
        message: 'Portfolio persistence did not complete in time.',
      ),
      'unauthenticated' => const PortfolioPersistenceException(
        code: PortfolioPersistenceFailureCode.unauthenticated,
        message: 'An authenticated user is required to access a portfolio.',
      ),
      'invalid-argument' ||
      'failed-precondition' ||
      'data-loss' => const PortfolioPersistenceException(
        code: PortfolioPersistenceFailureCode.invalidData,
        message: 'Portfolio persistence data is invalid.',
      ),
      _ => const PortfolioPersistenceException(
        code: PortfolioPersistenceFailureCode.unknown,
        message: 'Portfolio persistence could not be completed.',
      ),
    };
  }
}
