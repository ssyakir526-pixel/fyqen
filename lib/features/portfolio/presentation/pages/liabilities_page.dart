import 'package:flutter/material.dart';
import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/features/dashboard/presentation/models/dashboard_portfolio_summary.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/presentation/widgets/delete_liability_confirmation_dialog.dart';
import 'package:fyqen/features/portfolio/presentation/widgets/liabilities_empty_state.dart';
import 'package:fyqen/features/portfolio/presentation/widgets/liability_form.dart';
import 'package:fyqen/features/portfolio/presentation/widgets/liability_list_item.dart';
import 'package:fyqen/shared/widgets/app_button.dart';

/// Displays and manages the immutable Liability collection of one Portfolio.
final class LiabilitiesPage extends StatelessWidget {
  const LiabilitiesPage({
    required this.portfolio,
    required this.onAddLiability,
    required this.onReplaceLiability,
    required this.onRemoveLiability,
    required this.createLiabilityId,
    required this.currentTime,
    super.key,
    this.isSaving = false,
    this.showAppBar = true,
  });

  final Portfolio portfolio;
  final Future<bool> Function(Liability liability) onAddLiability;
  final Future<bool> Function(Liability liability) onReplaceLiability;
  final Future<bool> Function(String liabilityId) onRemoveLiability;
  final String Function() createLiabilityId;
  final DateTime Function() currentTime;
  final bool isSaving;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final DashboardPortfolioSummary summary =
        DashboardPortfolioSummary.fromPortfolio(portfolio);
    final Widget body = SafeArea(
      child: portfolio.liabilities.isEmpty
          ? LiabilitiesEmptyState(
              onAddLiability: isSaving ? null : () => _openForm(context),
              isSaving: isSaving,
            )
          : ListView.separated(
              key: const Key('liability-list'),
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: portfolio.liabilities.length + 1,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return _LiabilitySummary(
                    liabilityCount: summary.liabilityCount,
                    totalLiabilitiesLabel: summary.totalLiabilitiesLabel,
                    isSaving: isSaving,
                    onAddLiability: () => _openForm(context),
                  );
                }

                final Liability liability = portfolio.liabilities[index - 1];
                return LiabilityListItem(
                  liability: liability,
                  onEdit: isSaving ? null : () => _openForm(context, liability),
                  onDelete: isSaving
                      ? null
                      : () => _confirmDelete(context, liability),
                );
              },
            ),
    );

    if (!showAppBar) {
      return body;
    }

    return Scaffold(
      key: const Key('liabilities-page'),
      appBar: AppBar(
        title: const Text('Liabilities'),
        actions: <Widget>[
          IconButton(
            key: const Key('liabilities-page-add-button'),
            tooltip: 'Add Liability',
            onPressed: isSaving ? null : () => _openForm(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: body,
    );
  }

  Future<void> _openForm(BuildContext context, [Liability? liability]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return LiabilityForm(
          initialLiability: liability,
          createLiabilityId: createLiabilityId,
          currentTime: currentTime,
          onSubmit: liability == null ? onAddLiability : onReplaceLiability,
          isSaving: isSaving,
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Liability liability) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DeleteLiabilityConfirmationDialog(
          liabilityId: liability.id,
          onDelete: onRemoveLiability,
        );
      },
    );
  }
}

final class _LiabilitySummary extends StatelessWidget {
  const _LiabilitySummary({
    required this.liabilityCount,
    required this.totalLiabilitiesLabel,
    required this.isSaving,
    required this.onAddLiability,
  });

  final int liabilityCount;
  final String totalLiabilitiesLabel;
  final bool isSaving;
  final VoidCallback onAddLiability;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Track the debts that reduce your net worth.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Text('$liabilityCount liabilities • Total: $totalLiabilitiesLabel'),
        if (isSaving) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          const LinearProgressIndicator(
            key: Key('liabilities-saving-indicator'),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Add Liability',
          icon: Icons.add,
          onPressed: isSaving ? null : onAddLiability,
          expand: false,
        ),
      ],
    );
  }
}
