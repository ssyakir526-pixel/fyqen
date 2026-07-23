import 'package:flutter/material.dart';
import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/shared/widgets/app_button.dart';
import 'package:fyqen/shared/widgets/app_text_field.dart';

/// Reusable add and edit form for one immutable Liability entity.
final class LiabilityForm extends StatefulWidget {
  const LiabilityForm({
    required this.onSubmit,
    required this.createLiabilityId,
    required this.currentTime,
    super.key,
    this.initialLiability,
    this.isSaving = false,
  });

  final Future<bool> Function(Liability liability) onSubmit;
  final String Function() createLiabilityId;
  final DateTime Function() currentTime;
  final Liability? initialLiability;
  final bool isSaving;

  @override
  State<LiabilityForm> createState() => _LiabilityFormState();
}

final class _LiabilityFormState extends State<LiabilityForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _lenderController;
  late final TextEditingController _balanceController;
  late final TextEditingController _originalAmountController;
  late final TextEditingController _currencyController;
  late LiabilityType _liabilityType;
  bool _isSubmitting = false;
  bool _hasFailure = false;

  @override
  void initState() {
    super.initState();
    final Liability? liability = widget.initialLiability;
    _nameController = TextEditingController(text: liability?.name ?? '');
    _lenderController = TextEditingController(
      text: liability?.lenderName ?? '',
    );
    _balanceController = TextEditingController(
      text: liability?.outstandingBalance.amount ?? '',
    );
    _originalAmountController = TextEditingController(
      text: liability?.originalAmount.amount ?? '',
    );
    _currencyController = TextEditingController(
      text: liability?.outstandingBalance.currencyCode ?? '',
    );
    _liabilityType = liability?.type ?? LiabilityType.creditCard;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lenderController.dispose();
    _balanceController.dispose();
    _originalAmountController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || widget.isSaving) {
      return;
    }

    final FormState? formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final DateTime timestamp = widget.currentTime().toUtc();
    final Liability? initialLiability = widget.initialLiability;
    final Liability liability;
    try {
      liability = Liability(
        id: initialLiability?.id ?? widget.createLiabilityId(),
        name: _nameController.text.trim(),
        type: _liabilityType,
        outstandingBalance: LiabilityAmount(
          amount: _balanceController.text.trim(),
          currencyCode: _currencyController.text.trim(),
        ),
        originalAmount: LiabilityAmount(
          amount: _originalAmountController.text.trim(),
          currencyCode: _currencyController.text.trim(),
        ),
        lenderName: _lenderController.text.trim(),
        dueDate: initialLiability?.dueDate,
        createdAt: initialLiability?.createdAt ?? timestamp,
        updatedAt: timestamp,
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
    final bool didSave = await widget.onSubmit(liability);
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
    final bool isEditing = widget.initialLiability != null;
    final bool isBusy = _isSubmitting || widget.isSaving;

    return SafeArea(
      key: const Key('liability-form'),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          top: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isEditing ? 'Edit Liability' : 'Add Liability',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  key: const Key('liability-name-field'),
                  label: 'Liability name',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: _requiredTextValidator('Enter a liability name.'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  key: const Key('liability-lender-name-field'),
                  label: 'Lender (optional)',
                  controller: _lenderController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<LiabilityType>(
                  key: const Key('liability-type-field'),
                  initialValue: _liabilityType,
                  decoration: const InputDecoration(
                    labelText: 'Liability type',
                  ),
                  items: LiabilityType.values
                      .map(
                        (LiabilityType type) => DropdownMenuItem<LiabilityType>(
                          value: type,
                          child: Text(_typeLabel(type)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: isBusy
                      ? null
                      : (LiabilityType? value) {
                          if (value != null) {
                            setState(() => _liabilityType = value);
                          }
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  key: const Key('liability-balance-field'),
                  label: 'Outstanding balance',
                  controller: _balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _amountValidator,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  key: const Key('liability-original-amount-field'),
                  label: 'Original amount',
                  controller: _originalAmountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _amountValidator,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  key: const Key('liability-currency-field'),
                  label: 'Currency',
                  controller: _currencyController,
                  textInputAction: TextInputAction.done,
                  validator: _currencyValidator,
                ),
                if (_hasFailure) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'We could not save this liability. Please check the details and try again.',
                    key: const Key('liability-form-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  key: const Key('liability-submit-button'),
                  label: isEditing ? 'Save Changes' : 'Add Liability',
                  onPressed: _submit,
                  isLoading: isBusy,
                ),
                if (isBusy)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.sm),
                    child: Center(
                      child: SizedBox.square(
                        key: Key('liability-form-saving-indicator'),
                        dimension: AppSpacing.md,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
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

  static String? _amountValidator(String? value) {
    try {
      LiabilityAmount(amount: value?.trim() ?? '', currencyCode: 'USD');
      return null;
    } on ArgumentError {
      return 'Enter a valid non-negative amount.';
    } on FormatException {
      return 'Enter a valid non-negative amount.';
    }
  }

  static String? _currencyValidator(String? value) {
    try {
      LiabilityAmount(amount: '0', currencyCode: value?.trim() ?? '');
      return null;
    } on FormatException {
      return 'Enter a three-letter currency code.';
    }
  }

  static String _typeLabel(LiabilityType type) {
    final String name = type.name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (Match match) => '${match[1]} ${match[2]}',
    );
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }
}
