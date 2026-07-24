/// Persistence-neutral representation of one Daily Streak document.
final class DailyStreakDto {
  DailyStreakDto({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastOpenedDate,
  }) : assert(currentStreak >= 0),
       assert(longestStreak >= 0),
       assert(longestStreak >= currentStreak);

  factory DailyStreakDto.fromMap(Map<String, Object?> map) {
    final Object? current = map['currentStreak'];
    final Object? longest = map['longestStreak'];
    final Object? lastOpenedDate = map['lastOpenedDate'];
    if ((current != null && current is! int) ||
        (longest != null && longest is! int)) {
      throw const FormatException('Daily Streak counts are invalid.');
    }
    if (lastOpenedDate != null && lastOpenedDate is! DateTime) {
      throw const FormatException('Daily Streak date is invalid.');
    }
    final int currentStreak = current as int? ?? 0;
    final int longestStreak = longest as int? ?? 0;
    if (currentStreak < 0 ||
        longestStreak < 0 ||
        longestStreak < currentStreak) {
      throw const FormatException('Daily Streak counts violate invariants.');
    }
    return DailyStreakDto(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastOpenedDate: lastOpenedDate as DateTime?,
    );
  }

  final int currentStreak;
  final int longestStreak;
  final DateTime? lastOpenedDate;

  Map<String, Object?> toMap() => <String, Object?>{
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastOpenedDate': lastOpenedDate,
  };
}
