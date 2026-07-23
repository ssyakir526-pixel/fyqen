import '../enums/liability_type.dart';
import '../value_objects/liability_amount.dart';

/// An immutable, persistence-independent financial liability entity.
final class Liability {
  const Liability._({
    required String id,
    required String name,
    required LiabilityType type,
    required LiabilityAmount outstandingBalance,
    required LiabilityAmount originalAmount,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String? lenderName,
    required DateTime? dueDate,
  }) : _id = id,
       _name = name,
       _type = type,
       _outstandingBalance = outstandingBalance,
       _originalAmount = originalAmount,
       _createdAt = createdAt,
       _updatedAt = updatedAt,
       _lenderName = lenderName,
       _dueDate = dueDate;

  factory Liability({
    required String id,
    required String name,
    required LiabilityType type,
    required LiabilityAmount outstandingBalance,
    required LiabilityAmount originalAmount,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? lenderName,
    DateTime? dueDate,
  }) {
    final String normalizedId = _requireText(id, 'id');
    final String normalizedName = _requireText(name, 'name');
    final DateTime normalizedCreatedAt = createdAt.toUtc();
    final DateTime normalizedUpdatedAt = updatedAt.toUtc();

    if (outstandingBalance.currencyCode != originalAmount.currencyCode) {
      throw ArgumentError(
        'Outstanding balance and original amount must use the same currency.',
      );
    }
    if (normalizedUpdatedAt.isBefore(normalizedCreatedAt)) {
      throw ArgumentError.value(
        updatedAt,
        'updatedAt',
        'Updated timestamp must not be earlier than created timestamp.',
      );
    }

    return Liability._(
      id: normalizedId,
      name: normalizedName,
      type: type,
      outstandingBalance: outstandingBalance,
      originalAmount: originalAmount,
      createdAt: normalizedCreatedAt,
      updatedAt: normalizedUpdatedAt,
      lenderName: _normalizeOptionalText(lenderName),
      dueDate: dueDate?.toUtc(),
    );
  }

  final String _id;
  final String _name;
  final LiabilityType _type;
  final LiabilityAmount _outstandingBalance;
  final LiabilityAmount _originalAmount;
  final DateTime _createdAt;
  final DateTime _updatedAt;
  final String? _lenderName;
  final DateTime? _dueDate;

  String get id => _id;

  String get name => _name;

  LiabilityType get type => _type;

  LiabilityAmount get outstandingBalance => _outstandingBalance;

  LiabilityAmount get originalAmount => _originalAmount;

  DateTime get createdAt => _createdAt;

  DateTime get updatedAt => _updatedAt;

  String? get lenderName => _lenderName;

  DateTime? get dueDate => _dueDate;

  static String _requireText(String value, String name) {
    final String normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(value, name, 'must not be empty');
    }

    return normalizedValue;
  }

  static String? _normalizeOptionalText(String? value) {
    final String? normalizedValue = value?.trim();

    return normalizedValue == null || normalizedValue.isEmpty
        ? null
        : normalizedValue;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is Liability &&
            other._id == _id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _id);

  @override
  String toString() {
    return 'Liability(id: $_id, name: $_name, type: $_type)';
  }
}
