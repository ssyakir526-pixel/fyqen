import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/infrastructure/dtos/daily_streak_dto.dart';
import 'package:fyqen/features/streak/infrastructure/mappers/daily_streak_mapper.dart';

void main() {
  const DailyStreakMapper mapper = DailyStreakMapper();

  test('serializes and deserializes deterministic typed data', () {
    final DateTime opened = DateTime(2026, 3, 4, 14, 30);
    final DailyStreakDto dto = DailyStreakDto(
      currentStreak: 7,
      longestStreak: 30,
      lastOpenedDate: opened,
    );

    final Map<String, Object?> map = dto.toMap();
    expect(map['lastOpenedDate'], isA<DateTime>());
    expect(map['lastOpenedDate'], isNot(isA<String>()));
    expect(DailyStreakDto.fromMap(map).currentStreak, 7);
    expect(DailyStreakDto.fromMap(map).longestStreak, 30);
  });

  test('supports missing counts and null date as the empty convention', () {
    final DailyStreakDto dto = DailyStreakDto.fromMap(<String, Object?>{
      'lastOpenedDate': null,
    });

    expect(dto.currentStreak, 0);
    expect(dto.longestStreak, 0);
    expect(dto.lastOpenedDate, isNull);
    expect(mapper.toDomain(dto), const DailyStreak.empty());
  });

  test('rejects invalid counts and field types', () {
    expect(
      () => DailyStreakDto.fromMap(<String, Object?>{'currentStreak': -1}),
      throwsFormatException,
    );
    expect(
      () => DailyStreakDto.fromMap(<String, Object?>{
        'currentStreak': 3,
        'longestStreak': 2,
      }),
      throwsFormatException,
    );
    expect(
      () => DailyStreakDto.fromMap(<String, Object?>{'lastOpenedDate': 'date'}),
      throwsFormatException,
    );
  });

  test('maps normalized dates without calculating updates or milestones', () {
    final DailyStreak domain = DailyStreak(
      currentStreak: 6,
      longestStreak: 8,
      lastOpenedDate: DateTime(2026, 3, 4, 23, 59),
    );
    final DailyStreakDto dto = mapper.toDto(domain);
    final DailyStreak roundTrip = mapper.toDomain(dto);

    expect(dto.lastOpenedDate, DateTime(2026, 3, 4));
    expect(roundTrip.currentStreak, 6);
    expect(roundTrip.longestStreak, 8);
    expect(roundTrip.lastOpenedDate, DateTime(2026, 3, 4));
  });
}
