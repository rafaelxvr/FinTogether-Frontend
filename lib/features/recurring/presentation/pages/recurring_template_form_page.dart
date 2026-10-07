import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/recurring_transaction_template.dart';
import '../providers/recurring_transaction_provider.dart';
import '../providers/recurring_transaction_state.dart';
import '../widgets/recurrence_rule_form_widget.dart';

/// Page for creating or editing a recurring transaction template.
class RecurringTemplateFormPage extends ConsumerStatefulWidget {
  final String budgetId;
  final RecurringTransactionTemplate? template;

  const RecurringTemplateFormPage({
    super.key,
    required this.budgetId,
    this.template,
  });

  @override
  ConsumerState<RecurringTemplateFormPage> createState() =>
      _RecurringTemplateFormPageState();
}

class _RecurringTemplateFormPageState
    extends ConsumerState<RecurringTemplateFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  RecurringTransactionType _type = RecurringTransactionType.expense;
  RecurrenceFrequency _frequency = RecurrenceFrequency.monthly;
  int _interval = 1;
  int? _dayOfMonth;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isFixedExpense = false;
  String? _selectedCategoryId;

  bool get _isEditMode => widget.template != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final t = widget.template!;
      _descriptionController.text = t.description;
      _amountController.text = t.amount.toStringAsFixed(2);
      _type = t.type;
      _frequency = t.frequency;
      _interval = t.interval;
      _dayOfMonth = t.dayOfMonth;
      _startDate = t.startDate;
      _endDate = t.endDate;
      _isFixedExpense = t.isFixedExpense;
      _selectedCategoryId = t.categoryId;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _amount {
    final text = _amountController.text.replaceAll(',', '.');
    return double.tryParse(text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<RecurringTransactionState>(recurringTransactionProvider,
        (previous, next) {
      if (next is TemplateCreated) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? l10n.templateUpdatedSuccessfully
                  : l10n.templateCreatedSuccessfully,
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (next is RecurringError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final state = ref.watch(recurringTransactionProvider);
    final isLoading = state is RecurringLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? l10n.editTemplate : l10n.newRecurringExpense),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Amount
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n.amount,
                prefixText: 'R\$ ',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              validator: (val) {
                if (val == null || val.isEmpty) return l10n.required;
                final amount = double.tryParse(val.replaceAll(',', '.'));
                if (amount == null) return l10n.invalidNumber;
                if (amount <= 0) return l10n.mustBeGreaterThanZero;
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Type (Expense/Income)
            SegmentedButton<RecurringTransactionType>(
              segments: [
                ButtonSegment(
                  value: RecurringTransactionType.expense,
                  label: Text(l10n.expense),
                  icon: const Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: RecurringTransactionType.income,
                  label: Text(l10n.income),
                  icon: const Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) {
                setState(() => _type = selection.first);
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: 'e.g., Rent, Netflix, Salary, etc.',
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

            // Recurrence rule section
            RecurrenceRuleFormWidget(
              frequency: _frequency,
              interval: _interval,
              dayOfMonth: _dayOfMonth,
              onFrequencyChanged: (freq) {
                setState(() {
                  _frequency = freq;
                  if (freq != RecurrenceFrequency.monthly) {
                    _dayOfMonth = null;
                  }
                });
              },
              onIntervalChanged: (val) {
                setState(() => _interval = val);
              },
              onDayOfMonthChanged: (val) {
                setState(() => _dayOfMonth = val);
              },
            ),
            const SizedBox(height: 16),

            // Start date
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
                      DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                }
              },
            ),
            const SizedBox(height: 16),

            // End date (optional)
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              leading: const Icon(Icons.event_busy),
              title: Text(l10n.endDateOptional),
              subtitle: Text(
                _endDate != null
                    ? DateFormat('MMM dd, yyyy').format(_endDate!)
                    : l10n.noEndDate,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_endDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _endDate = null),
                    ),
                  const Icon(Icons.edit_calendar),
                ],
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate:
                      _endDate ?? _startDate.add(const Duration(days: 365)),
                  firstDate: _startDate,
                  lastDate:
                      DateTime.now().add(const Duration(days: 365 * 10)),
                );
                if (date != null) {
                  setState(() => _endDate = date);
                }
              },
            ),
            const SizedBox(height: 16),

            // Mark as Fixed Expense switch
            SwitchListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              title: Text(l10n.markAsFixedExpense),
              subtitle: Text(l10n.fixedExpenseDescription),
              secondary: Icon(
                Icons.lock,
                color: _isFixedExpense ? Colors.orange : Colors.grey,
              ),
              value: _isFixedExpense,
              onChanged: (val) => setState(() => _isFixedExpense = val),
            ),
            const SizedBox(height: 24),

            // Submit button
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
                  isLoading
                      ? (_isEditMode ? l10n.updating : l10n.creating)
                      : (_isEditMode ? l10n.updateTemplate : l10n.createTemplate),
                ),
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

    final notifier = ref.read(recurringTransactionProvider.notifier);

    if (_isEditMode) {
      notifier.updateTemplate(
        id: widget.template!.id,
        budgetId: widget.budgetId,
        amount: _amount,
        type: _type,
        description: _descriptionController.text.trim(),
        frequency: _frequency,
        interval: _interval,
        dayOfMonth: _dayOfMonth,
        startDate: _startDate,
        endDate: _endDate,
        isFixedExpense: _isFixedExpense,
        categoryId: _selectedCategoryId,
      );
    } else {
      notifier.createTemplate(
        budgetId: widget.budgetId,
        amount: _amount,
        type: _type,
        description: _descriptionController.text.trim(),
        frequency: _frequency,
        interval: _interval,
        dayOfMonth: _dayOfMonth,
        startDate: _startDate,
        endDate: _endDate,
        isFixedExpense: _isFixedExpense,
        categoryId: _selectedCategoryId,
      );
    }
  }
}
