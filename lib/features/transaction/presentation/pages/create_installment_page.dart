import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/installment_group_provider.dart';
import '../providers/installment_group_state.dart';
import '../widgets/installment_preview_card.dart';

/// Page for creating a new installment group with auto-generated transactions.
class CreateInstallmentPage extends ConsumerStatefulWidget {
  final String budgetId;

  const CreateInstallmentPage({super.key, required this.budgetId});

  @override
  ConsumerState<CreateInstallmentPage> createState() =>
      _CreateInstallmentPageState();
}

class _CreateInstallmentPageState
    extends ConsumerState<CreateInstallmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _interestController = TextEditingController(text: '0');

  int _installmentCount = 2;
  DateTime _startDate = DateTime.now();
  String? _selectedCategoryId;
  String? _selectedCardId;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    final text = _amountController.text.replaceAll(',', '.');
    return double.tryParse(text) ?? 0;
  }

  double get _interestRate {
    final text = _interestController.text.replaceAll(',', '.');
    return double.tryParse(text) ?? 0;
  }

  double get _totalWithInterest {
    if (_interestRate > 0) {
      return _totalAmount *
          pow(1 + _interestRate / 100, _installmentCount);
    }
    return _totalAmount;
  }

  double get _installmentAmount {
    if (_installmentCount <= 0 || _totalAmount <= 0) return 0;
    return _totalWithInterest / _installmentCount;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<InstallmentGroupState>(installmentGroupProvider,
        (previous, next) {
      if (next is InstallmentGroupCreated) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.installmentCreatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      } else if (next is InstallmentGroupError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final state = ref.watch(installmentGroupProvider);
    final isLoading = state is InstallmentGroupLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newInstallment),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: 'e.g., New laptop, TV, etc.',
                prefixIcon: const Icon(Icons.description),
                border: const OutlineInputBorder(),
              ),
              maxLength: 500,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10n.descriptionRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Total Amount
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n.totalAmount,
                prefixText: 'R\$ ',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              validator: (val) {
                if (val == null || val.isEmpty) return l10n.required;
                final amount =
                    double.tryParse(val.replaceAll(',', '.'));
                if (amount == null) return l10n.invalidNumber;
                if (amount <= 0) return l10n.mustBeGreaterThanZero;
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Number of Installments
            DropdownButtonFormField<int>(
              value: _installmentCount,
              decoration: InputDecoration(
                labelText: l10n.numberOfInstallments,
                prefixIcon: const Icon(Icons.format_list_numbered),
                border: const OutlineInputBorder(),
              ),
              items: List.generate(47, (i) => i + 2)
                  .map((count) => DropdownMenuItem(
                        value: count,
                        child: Text(l10n.nInstallments(count)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _installmentCount = val);
              },
            ),
            const SizedBox(height: 16),

            // Interest Rate
            TextFormField(
              controller: _interestController,
              decoration: InputDecoration(
                labelText: l10n.interestRate,
                suffixText: '%',
                prefixIcon: const Icon(Icons.percent),
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              validator: (val) {
                if (val == null || val.isEmpty) return null;
                final rate =
                    double.tryParse(val.replaceAll(',', '.'));
                if (rate == null) return l10n.invalidNumber;
                if (rate < 0 || rate > 100) {
                  return l10n.mustBeBetween0And100;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Start Date
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.startDate),
              subtitle: Text(
                DateFormat('MMM dd, yyyy').format(_startDate),
              ),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate:
                      DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                }
              },
            ),
            const SizedBox(height: 24),

            // Live Preview
            InstallmentPreviewCard(
              totalAmount: _totalAmount,
              installmentCount: _installmentCount,
              interestRate: _interestRate,
              startDate: _startDate,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(
                    isLoading ? l10n.creating : l10n.createInstallment),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(installmentGroupProvider.notifier).createGroup(
          budgetId: widget.budgetId,
          totalAmount: _totalAmount,
          installmentCount: _installmentCount,
          interestRate: _interestRate,
          startDate: _startDate,
          description: _descriptionController.text.trim(),
          categoryId: _selectedCategoryId,
          cardId: _selectedCardId,
        );
  }
}
