import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyqen/features/authentication/application/providers/authenticated_user_id_provider.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak_update_result.dart';
import 'package:fyqen/features/streak/domain/repositories/daily_streak_repository.dart';
import 'package:fyqen/features/streak/domain/services/daily_streak_calculator.dart';
import 'package:fyqen/features/streak/infrastructure/data_sources/firestore_daily_streak_data_source.dart';
import 'package:fyqen/features/streak/infrastructure/dtos/daily_streak_dto.dart';
import 'package:fyqen/features/streak/infrastructure/mappers/daily_streak_mapper.dart';

/// Transaction-backed persistence for the current authenticated user's streak.
final class FirestoreDailyStreakRepository implements DailyStreakRepository {
  FirestoreDailyStreakRepository({
    required FirebaseFirestore firestore,
    required AuthenticatedUserIdProvider authenticatedUserIdProvider,
    DailyStreakMapper mapper = const DailyStreakMapper(),
    DailyStreakCalculator calculator = const DailyStreakCalculator(),
  }) : _dataSource = FirestoreDailyStreakDataSource(
         firestore: firestore,
         authenticatedUserIdProvider: authenticatedUserIdProvider,
       ),
       _mapper = mapper,
       _calculator = calculator;

  final FirestoreDailyStreakDataSource _dataSource;
  final DailyStreakMapper _mapper;
  final DailyStreakCalculator _calculator;

  @override
  Future<DailyStreak> loadDailyStreak() async {
    final DailyStreakDto? dto = await _dataSource.load();
    return dto == null ? const DailyStreak.empty() : _mapper.toDomain(dto);
  }

  @override
  Stream<DailyStreak> watchDailyStreak() {
    return _dataSource.watch().map(
      (DailyStreakDto? dto) =>
          dto == null ? const DailyStreak.empty() : _mapper.toDomain(dto),
    );
  }

  @override
  Future<DailyStreakUpdateResult> recordDailyOpen({
    required DateTime openedAt,
  }) async {
    late DailyStreakUpdateResult result;
    await _dataSource.transaction((DailyStreakDto? dto) {
      final DailyStreak current = dto == null
          ? const DailyStreak.empty()
          : _mapper.toDomain(dto);
      result = _calculator.recordOpen(streak: current, openedAt: openedAt);
      return result.didChange ? _mapper.toDto(result.streak) : null;
    });
    return result;
  }
}
