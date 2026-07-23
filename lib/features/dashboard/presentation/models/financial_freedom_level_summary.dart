import 'package:fyqen/features/dashboard/presentation/models/dashboard_portfolio_summary.dart';

/// Immutable Dashboard-only level derivation from comparable FI progress.
final class FinancialFreedomLevelSummary {
  const FinancialFreedomLevelSummary._({
    required this.isAvailable,
    required this.currentLevel,
    required this.nextLevel,
    required this.isMaximumLevel,
    required this.progressToNextLevelRatio,
    required this.progressToNextLevelLabel,
    required this.unavailableReason,
  });

  factory FinancialFreedomLevelSummary.fromDashboardSummary(
    DashboardPortfolioSummary summary,
  ) {
    final String? netWorthAmount = summary.netWorthAmount;
    final String? targetAmount = summary.financialIndependenceTargetAmount;
    if (!summary.hasFinancialIndependenceTarget) {
      return const FinancialFreedomLevelSummary._(
        isAvailable: false,
        currentLevel: null,
        nextLevel: null,
        isMaximumLevel: false,
        progressToNextLevelRatio: null,
        progressToNextLevelLabel: null,
        unavailableReason: 'Set an FI target to calculate your level.',
      );
    }

    if (!summary.isFinancialIndependenceProgressAvailable ||
        netWorthAmount == null ||
        targetAmount == null) {
      return const FinancialFreedomLevelSummary._(
        isAvailable: false,
        currentLevel: null,
        nextLevel: null,
        isMaximumLevel: false,
        progressToNextLevelRatio: null,
        progressToNextLevelLabel: null,
        unavailableReason:
            'Level cannot be calculated across different currencies.',
      );
    }

    return _fromComparableAmounts(netWorthAmount, targetAmount);
  }

  static const int minimumLevel = 1;
  static const int maximumLevel = 100;

  final bool isAvailable;
  final int? currentLevel;
  final int? nextLevel;
  final bool isMaximumLevel;
  final double? progressToNextLevelRatio;
  final String? progressToNextLevelLabel;
  final String? unavailableReason;

  static FinancialFreedomLevelSummary _fromComparableAmounts(
    String netWorthAmount,
    String targetAmount,
  ) {
    final _ExactDecimal netWorth = _ExactDecimal.parse(netWorthAmount);
    final _ExactDecimal target = _ExactDecimal.parse(targetAmount);
    if (netWorth.unscaled <= BigInt.zero) {
      return const FinancialFreedomLevelSummary._(
        isAvailable: true,
        currentLevel: minimumLevel,
        nextLevel: 2,
        isMaximumLevel: false,
        progressToNextLevelRatio: 0,
        progressToNextLevelLabel: '0% toward Level 2',
        unavailableReason: null,
      );
    }

    final BigInt percentNumerator =
        netWorth.unscaled *
        BigInt.from(10).pow(target.scale) *
        BigInt.from(100);
    final BigInt percentDenominator =
        target.unscaled * BigInt.from(10).pow(netWorth.scale);
    final BigInt wholePercent = percentNumerator ~/ percentDenominator;
    if (wholePercent >= BigInt.from(maximumLevel)) {
      return const FinancialFreedomLevelSummary._(
        isAvailable: true,
        currentLevel: maximumLevel,
        nextLevel: null,
        isMaximumLevel: true,
        progressToNextLevelRatio: 1,
        progressToNextLevelLabel: 'Maximum level reached',
        unavailableReason: null,
      );
    }

    final int level = wholePercent < BigInt.one
        ? minimumLevel
        : wholePercent.toInt();
    final BigInt numeratorForBand = level == minimumLevel
        ? percentNumerator
        : percentNumerator - wholePercent * percentDenominator;
    final BigInt denominatorForBand = level == minimumLevel
        ? percentDenominator * BigInt.from(2)
        : percentDenominator;
    final BigInt progressPercent =
        (numeratorForBand * BigInt.from(100)) ~/ denominatorForBand;
    final double ratio = progressPercent.toDouble() / 100;
    final int nextLevel = level + 1;

    return FinancialFreedomLevelSummary._(
      isAvailable: true,
      currentLevel: level,
      nextLevel: nextLevel,
      isMaximumLevel: false,
      progressToNextLevelRatio: ratio,
      progressToNextLevelLabel: '$progressPercent% toward Level $nextLevel',
      unavailableReason: null,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is FinancialFreedomLevelSummary &&
            other.isAvailable == isAvailable &&
            other.currentLevel == currentLevel &&
            other.nextLevel == nextLevel &&
            other.isMaximumLevel == isMaximumLevel &&
            other.progressToNextLevelRatio == progressToNextLevelRatio &&
            other.progressToNextLevelLabel == progressToNextLevelLabel &&
            other.unavailableReason == unavailableReason;
  }

  @override
  int get hashCode => Object.hash(
    isAvailable,
    currentLevel,
    nextLevel,
    isMaximumLevel,
    progressToNextLevelRatio,
    progressToNextLevelLabel,
    unavailableReason,
  );
}

final class _ExactDecimal {
  const _ExactDecimal._(this.unscaled, this.scale);

  factory _ExactDecimal.parse(String value) {
    final List<String> parts = value.split('.');
    final String fraction = parts.length == 2 ? parts.last : '';
    return _ExactDecimal._(
      BigInt.parse('${parts.first}$fraction'),
      fraction.length,
    );
  }

  final BigInt unscaled;
  final int scale;
}
