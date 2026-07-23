import 'package:flutter/material.dart';
import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/shared/widgets/app_button.dart';
import 'package:fyqen/shared/widgets/app_text_field.dart';

/// Shared add and edit form that constructs an immutable Asset after validation.
final class AssetForm extends StatefulWidget {
  const AssetForm({
    required this.onSubmit,
    required this.createAssetId,
    required this.currentTime,
    super.key,
    this.initialAsset,
    this.isSaving = false,
  });

  final Future<bool> Function(Asset asset) onSubmit;
  final String Function() createAssetId;
  final DateTime Function() currentTime;
  final Asset? initialAsset;
  final bool isSaving;

  @override
  State<AssetForm> createState() => _AssetFormState();
}

final class _AssetFormState extends State<AssetForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _symbolController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final String _assetId;
  late final DateTime _createdAt;
  late AssetType _assetType;
  bool _isSubmitting = false;
  bool _hasFailure = false;

  @override
  void initState() {
    super.initState();
    final Asset? asset = widget.initialAsset;
    _nameController = TextEditingController(text: asset?.name);
    _symbolController = TextEditingController(text: asset?.symbol);
    _quantityController = TextEditingController(text: asset?.quantity.value);
    _priceController = TextEditingController(text: asset?.unitPrice.amount);
    _currencyController = TextEditingController(
      text: asset?.unitPrice.currencyCode,
    );
    _assetId = asset?.id ?? widget.createAssetId();
    _createdAt = asset?.createdAt ?? widget.currentTime().toUtc();
    _assetType = asset?.type ?? AssetType.cash;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting ||
        widget.isSaving ||
        !_formKey.currentState!.validate()) {
      return;
    }

    final Asset asset;
    try {
      asset = Asset(
        id: _assetId,
        name: _nameController.text.trim(),
        symbol: _symbolController.text.trim(),
        type: _assetType,
        quantity: AssetQuantity(_quantityController.text.trim()),
        unitPrice: AssetUnitPrice(
          amount: _priceController.text.trim(),
          currencyCode: _currencyController.text.trim(),
        ),
        createdAt: _createdAt,
        updatedAt: widget.currentTime().toUtc(),
      );
    } on ArgumentError {
      setState(() => _hasFailure = true);
      return;
    } on FormatException {
      setState(() => _hasFailure = true);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _hasFailure = false;
    });
    final bool didSave = await widget.onSubmit(asset);
    if (!mounted) {
      return;
    }
    if (didSave) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isSubmitting = false;
      _hasFailure = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.initialAsset != null;
    final bool isBusy = _isSubmitting || widget.isSaving;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          top: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: const Key('asset-form'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isEditing ? 'Edit Asset' : 'Add Asset',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Asset name',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: _requiredTextValidator('Enter an asset name.'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Symbol (optional)',
                  controller: _symbolController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<AssetType>(
                  initialValue: _assetType,
                  decoration: const InputDecoration(labelText: 'Asset type'),
                  items: AssetType.values
                      .map(
                        (AssetType type) => DropdownMenuItem<AssetType>(
                          value: type,
                          child: Text(_typeLabel(type)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: isBusy
                      ? null
                      : (AssetType? value) {
                          if (value != null) {
                            setState(() => _assetType = value);
                          }
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Quantity',
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _positiveDecimalValidator,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Current price',
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _nonNegativeDecimalValidator,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Currency',
                  controller: _currencyController,
                  textInputAction: TextInputAction.done,
                  validator: _currencyValidator,
                ),
                if (_hasFailure) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'We could not save this asset. Please check the details and try again.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: isEditing ? 'Save changes' : 'Add Asset',
                  onPressed: _submit,
                  isLoading: isBusy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String? Function(String?) _requiredTextValidator(String message) {
    return (String? value) =>
        value == null || value.trim().isEmpty ? message : null;
  }

  static String? _positiveDecimalValidator(String? value) {
    try {
      AssetQuantity(value?.trim() ?? '');
      return null;
    } on ArgumentError {
      return 'Enter a valid quantity greater than zero.';
    } on FormatException {
      return 'Enter a valid quantity greater than zero.';
    }
  }

  static String? _nonNegativeDecimalValidator(String? value) {
    try {
      AssetUnitPrice(amount: value?.trim() ?? '', currencyCode: 'USD');
      return null;
    } on ArgumentError {
      return 'Enter a valid non-negative price.';
    } on FormatException {
      return 'Enter a valid non-negative price.';
    }
  }

  static String? _currencyValidator(String? value) {
    final String currency = value?.trim() ?? '';
    return RegExp(r'^[A-Za-z]{3}$').hasMatch(currency)
        ? null
        : 'Enter a three-letter currency code.';
  }

  static String _typeLabel(AssetType type) {
    final String name = type.name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (Match match) => '${match[1]} ${match[2]}',
    );
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }
}
