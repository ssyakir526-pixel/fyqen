import 'package:flutter/material.dart';
import 'package:fyqen/features/dashboard/presentation/models/dashboard_portfolio_summary.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/shared/widgets/app_card.dart';

/// Displays immutable Liability data with supplied edit and delete intents.
final class LiabilityListItem extends StatelessWidget {
  const LiabilityListItem({
    required this.liability,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Liability liability;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final String lenderLabel = liability.lenderName == null
        ? ''
        : ' • ${liability.lenderName}';
    final String currency = liability.outstandingBalance.currencyCode;

    return AppCard(
      key: Key('liability-list-item-${liability.id}'),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('${liability.name}$lenderLabel'),
        subtitle: Text(
          '${_labelForType(liability.type.name)} • '
          'Balance: ${DashboardPortfolioSummary.liabilityValueLabel(liability)}\n'
          'Original: $currency ${liability.originalAmount.amount}',
        ),
        isThreeLine: true,
        trailing: Wrap(
          children: <Widget>[
            IconButton(
              key: Key('edit-liability-button-${liability.id}'),
              tooltip: 'Edit liability',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              key: Key('delete-liability-button-${liability.id}'),
              tooltip: 'Delete liability',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  static String _labelForType(String name) {
    final String spaced = name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (Match match) => '${match[1]} ${match[2]}',
    );
    return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }
}
