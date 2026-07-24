/// Immutable persisted engagement state for one authenticated user.
final class DailyStreak {
  const DailyStreak({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastOpenedDate,
  }) : assert(currentStreak >= 0),
       assert(longestStreak >= 0),
       assert(longestStreak >= currentStreak),
       assert(currentStreak == 0 || lastOpenedDate != null);

  const DailyStreak.empty()
    : currentStreak = 0,
      longestStreak = 0,
      lastOpenedDate = null;

  final int currentStreak;
  final int longestStreak;
  final DateTime? lastOpenedDate;

  DailyStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastOpenedDate,
    bool clearLastOpenedDate = false,
  }) {
    return DailyStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastOpenedDate: clearLastOpenedDate
          ? null
          : lastOpenedDate ?? this.lastOpenedDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is DailyStreak &&
            other.currentStreak == currentStreak &&
            other.longestStreak == longestStreak &&
            other.lastOpenedDate == lastOpenedDate;
  }

  @override
  int get hashCode => Object.hash(currentStreak, longestStreak, lastOpenedDate);
}
