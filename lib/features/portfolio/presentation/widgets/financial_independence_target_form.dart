import 'package:flutter/material.dart';
import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';
import 'package:fyqen/shared/widgets/app_button.dart';
import 'package:fyqen/shared/widgets/app_text_field.dart';

/// Reusable set and edit form for the Portfolio Financial Independence target.
final class FinancialIndependenceTargetForm extends StatefulWidget {
  const FinancialIndependenceTargetForm({
    required this.onSubmit,
    super.key,
    this.initialTarget,
    this.isSaving = false,
  });

  final Future<bool> Function(FinancialIndependenceTarget target) onSubmit;
  final FinancialIndependenceTarget? initialTarget;
  final bool isSaving;

  @override
  State<FinancialIndependenceTargetForm> createState() =>
      _FinancialIndependenceTargetFormState();
}

final class _FinancialIndependenceTargetFormState
    extends State<FinancialIndependenceTargetForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;
  bool _isSubmitting = false;
  bool _hasFailure = false;

  @override
  void initState() {
    super.initState();
    final FinancialIndependenceTarget? target = widget.initialTarget;
    _amountController = TextEditingController(text: target?.amount ?? '');
    _currencyController = TextEditingController(
      text: target?.currencyCode ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
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

    final FinancialIndependenceTarget target;
    try {
      target = FinancialIndependenceTarget(
        amount: _amountController.text.trim(),
        currencyCode: _currencyController.text.trim(),
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
    final bool didSave = await widget.onSubmit(target);
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
    final bool isEditing = widget.initialTarget != null;
    final bool isBusy = _isSubmitting || widget.isSaving;

    return SafeArea(
      key: const Key('financial-independence-target-form'),
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
                  isEditing ? 'Edit FI Target' : 'Set FI Target',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isEditing
                      ? 'Update your financial independence target. Your progress will be recalculated automatically.'
                      : 'Choose the net worth you want to reach on your journey to financial freedom.',
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  key: const Key('financial-independence-target-amount-field'),
                  label: 'Target amount',
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _amountValidator,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  key: const Key(
                    'financial-independence-target-currency-field',
                  ),
                  label: 'Currency',
                  controller: _currencyController,
                  textInputAction: TextInputAction.done,
                  validator: _currencyValidator,
                ),
                if (_hasFailure) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'We could not save your FI target. Please try again.',
                    key: const Key(
                      'financial-independence-target-failure-message',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    AppButton(
                      key: const Key(
                        'financial-independence-target-cancel-button',
                      ),
                      label: 'Cancel',
                      onPressed: isBusy
                          ? null
                          : () => Navigator.of(context).pop(),
                      variant: AppButtonVariant.text,
                      expand: false,
                    ),
                    AppButton(
                      key: const Key(
                        'financial-independence-target-submit-button',
                      ),
                      label: isEditing ? 'Save Changes' : 'Set Target',
                      onPressed: _submit,
                      isLoading: isBusy,
                      expand: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String? _amountValidator(String? value) {
    final String amount = value?.trim() ?? '';
    if (amount.isEmpty) {
      return 'Enter your FI target.';
    }
    try {
      FinancialIndependenceTarget(amount: amount, currencyCode: 'USD');
      return null;
    } on ArgumentError {
      return 'FI target must be greater than zero.';
    } on FormatException {
      return 'Enter a valid amount.';
    }
  }

  static String? _currencyValidator(String? value) {
    final String currencyCode = value?.trim() ?? '';
    if (currencyCode.isEmpty) {
      return 'Enter a valid three-letter currency code.';
    }
    try {
      FinancialIndependenceTarget(amount: '1', currencyCode: currencyCode);
      return null;
    } on FormatException {
      return 'Enter a valid three-letter currency code.';
    }
  }
}
