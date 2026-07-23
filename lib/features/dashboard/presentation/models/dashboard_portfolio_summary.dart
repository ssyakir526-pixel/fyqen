import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';

/// Exact, presentation-only summary values derived from one Portfolio snapshot.
final class DashboardPortfolioSummary {
  const DashboardPortfolioSummary._({
    required this.assetCount,
    required this.liabilityCount,
    required this.totalAssetsLabel,
    required this.totalLiabilitiesLabel,
    required this.netWorthLabel,
    required this.hasFinancialIndependenceTarget,
    required this.financialIndependenceTargetLabel,
    required this.isFinancialIndependenceProgressAvailable,
    required this.financialIndependenceProgress,
    required this.financialIndependenceProgressLabel,
    required this.netWorthAmount,
    required this.financialIndependenceTargetAmount,
  });

  factory DashboardPortfolioSummary.fromPortfolio(Portfolio portfolio) {
    final Set<String> currencies = <String>{
      ...portfolio.assets.map((asset) => asset.unitPrice.currencyCode),
      ...portfolio.liabilities.map(
        (liability) => liability.outstandingBalance.currencyCode,
      ),
    };

    final bool hasMixedCurrencies = currencies.length > 1;
    final FinancialIndependenceTarget? target =
        portfolio.financialIndependenceTarget;
    final String? currencyCode = hasMixedCurrencies || currencies.isEmpty
        ? null
        : currencies.single;
    final _ExactDecimal totalAssets = portfolio.assets.fold<_ExactDecimal>(
      _ExactDecimal.zero,
      (_ExactDecimal total, asset) =>
          total +
          _ExactDecimal.parse(asset.quantity.value) *
              _ExactDecimal.parse(asset.unitPrice.amount),
    );
    final _ExactDecimal totalLiabilities = portfolio.liabilities
        .fold<_ExactDecimal>(
          _ExactDecimal.zero,
          (_ExactDecimal total, liability) =>
              total + _ExactDecimal.parse(liability.outstandingBalance.amount),
        );

    final _ExactDecimal netWorth = totalAssets - totalLiabilities;
    final _FinancialIndependenceProgress? progress =
        target == null ||
            hasMixedCurrencies ||
            (currencyCode != null && currencyCode != target.currencyCode)
        ? null
        : _FinancialIndependenceProgress.fromValues(
            netWorth: netWorth,
            target: _ExactDecimal.parse(target.amount),
          );

    return DashboardPortfolioSummary._(
      assetCount: portfolio.assets.length,
      liabilityCount: portfolio.liabilities.length,
      totalAssetsLabel: hasMixedCurrencies
          ? 'Unavailable across currencies'
          : _format(totalAssets, currencyCode ?? target?.currencyCode),
      totalLiabilitiesLabel: hasMixedCurrencies
          ? 'Unavailable across currencies'
          : _format(totalLiabilities, currencyCode ?? target?.currencyCode),
      netWorthLabel: hasMixedCurrencies
          ? 'Unavailable across currencies'
          : _format(netWorth, currencyCode ?? target?.currencyCode),
      hasFinancialIndependenceTarget: target != null,
      financialIndependenceTargetLabel: target == null
          ? null
          : _format(_ExactDecimal.parse(target.amount), target.currencyCode),
      isFinancialIndependenceProgressAvailable: progress != null,
      financialIndependenceProgress: progress?.indicatorValue,
      financialIndependenceProgressLabel: progress?.label,
      netWorthAmount: hasMixedCurrencies ? null : netWorth.toDisplayString(),
      financialIndependenceTargetAmount: target?.amount,
    );
  }

  final int assetCount;
  final int liabilityCount;
  final String totalAssetsLabel;
  final String totalLiabilitiesLabel;
  final String netWorthLabel;
  final bool hasFinancialIndependenceTarget;
  final String? financialIndependenceTargetLabel;
  final bool isFinancialIndependenceProgressAvailable;
  final double? financialIndependenceProgress;
  final String? financialIndependenceProgressLabel;
  final String? netWorthAmount;
  final String? financialIndependenceTargetAmount;

  static String assetValueLabel(Asset asset) {
    final _ExactDecimal value =
        _ExactDecimal.parse(asset.quantity.value) *
        _ExactDecimal.parse(asset.unitPrice.amount);
    return _format(value, asset.unitPrice.currencyCode);
  }

  static String liabilityValueLabel(Liability liability) {
    return _format(
      _ExactDecimal.parse(liability.outstandingBalance.amount),
      liability.outstandingBalance.currencyCode,
    );
  }

  static String _format(_ExactDecimal value, String? currencyCode) {
    final String amount = value.toDisplayString();
    return currencyCode == null ? amount : '$currencyCode $amount';
  }
}

final class _FinancialIndependenceProgress {
  const _FinancialIndependenceProgress({
    required this.indicatorValue,
    required this.label,
  });

  factory _FinancialIndependenceProgress.fromValues({
    required _ExactDecimal netWorth,
    required _ExactDecimal target,
  }) {
    if (netWorth.unscaled <= BigInt.zero) {
      return const _FinancialIndependenceProgress(
        indicatorValue: 0,
        label: '0%',
      );
    }

    final BigInt numerator =
        netWorth.unscaled *
        BigInt.from(10).pow(target.scale) *
        BigInt.from(100);
    final BigInt denominator =
        target.unscaled * BigInt.from(10).pow(netWorth.scale);
    final BigInt percentage = numerator ~/ denominator;
    final double indicatorValue = percentage >= BigInt.from(100)
        ? 1
        : percentage.toDouble() / 100;

    return _FinancialIndependenceProgress(
      indicatorValue: indicatorValue,
      label: '$percentage%',
    );
  }

  final double indicatorValue;
  final String label;
}

final class _ExactDecimal {
  const _ExactDecimal._(this.unscaled, this.scale);

  static final _ExactDecimal zero = _ExactDecimal._(BigInt.zero, 0);

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

  _ExactDecimal operator +(_ExactDecimal other) {
    final int targetScale = scale > other.scale ? scale : other.scale;
    return _ExactDecimal._(
      _expand(unscaled, targetScale - scale) +
          _expand(other.unscaled, targetScale - other.scale),
      targetScale,
    );
  }

  _ExactDecimal operator -(_ExactDecimal other) {
    final int targetScale = scale > other.scale ? scale : other.scale;
    return _ExactDecimal._(
      _expand(unscaled, targetScale - scale) -
          _expand(other.unscaled, targetScale - other.scale),
      targetScale,
    );
  }

  _ExactDecimal operator *(_ExactDecimal other) {
    return _ExactDecimal._(unscaled * other.unscaled, scale + other.scale);
  }

  String toDisplayString() {
    final bool isNegative = unscaled.isNegative;
    final String digits = unscaled.abs().toString().padLeft(scale + 1, '0');
    if (scale == 0) {
      return isNegative ? '-$digits' : digits;
    }

    final int separator = digits.length - scale;
    final String integer = digits.substring(0, separator);
    final String fraction = digits
        .substring(separator)
        .replaceFirst(RegExp(r'0+$'), '');
    final String value = fraction.isEmpty ? integer : '$integer.$fraction';
    return isNegative ? '-$value' : value;
  }

  static BigInt _expand(BigInt value, int amount) {
    return value * BigInt.from(10).pow(amount);
  }
}
