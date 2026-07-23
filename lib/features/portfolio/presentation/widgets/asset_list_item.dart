import 'package:flutter/material.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/dashboard/presentation/models/dashboard_portfolio_summary.dart';
import 'package:fyqen/shared/widgets/app_card.dart';

/// Displays immutable Asset data with supplied edit and delete intents.
final class AssetListItem extends StatelessWidget {
  const AssetListItem({
    required this.asset,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Asset asset;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final String typeLabel = _labelForType(asset.type.name);
    final String symbolLabel = asset.symbol == null ? '' : ' • ${asset.symbol}';

    return AppCard(
      key: Key('asset-list-item-${asset.id}'),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('${asset.name}$symbolLabel'),
        subtitle: Text(
          '$typeLabel • Quantity: ${asset.quantity.value} • '
          'Price: ${asset.unitPrice.currencyCode} ${asset.unitPrice.amount}\n'
          'Total: ${DashboardPortfolioSummary.assetValueLabel(asset)}',
        ),
        isThreeLine: true,
        trailing: Wrap(
          children: <Widget>[
            IconButton(
              tooltip: 'Edit asset',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete asset',
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
