/// The derived status of one fixed Financial Freedom Journey stage.
enum JourneyStageStatus { completed, current, upcoming }

/// Immutable presentation data for one Journey stage.
final class JourneyStageSummary {
  const JourneyStageSummary({
    required this.stageNumber,
    required this.name,
    required this.description,
    required this.checkpointLevel,
    required this.status,
  });

  final int stageNumber;
  final String name;
  final String description;
  final int checkpointLevel;
  final JourneyStageStatus status;

  JourneyStageSummary copyWith({JourneyStageStatus? status}) {
    return JourneyStageSummary(
      stageNumber: stageNumber,
      name: name,
      description: description,
      checkpointLevel: checkpointLevel,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is JourneyStageSummary &&
            other.stageNumber == stageNumber &&
            other.name == name &&
            other.description == description &&
            other.checkpointLevel == checkpointLevel &&
            other.status == status;
  }

  @override
  int get hashCode =>
      Object.hash(stageNumber, name, description, checkpointLevel, status);
}
