import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_template.dart';
import '../providers/transaction_provider.dart';
import '../providers/transaction_state.dart';
import '../providers/transaction_template_provider.dart';
import '../widgets/currency_input_field.dart';
import '../widgets/template_selector_widget.dart';
import '../../../splitting/presentation/widgets/split_toggle_widget.dart';

/// Full-page transaction create/edit form replacing the old dialog.
class TransactionFormPage extends ConsumerStatefulWidget {
  final String budgetId;
  final Transaction? transaction;

  const TransactionFormPage({
    super.key,
    required this.budgetId,
    this.transaction,
  });

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  late TransactionType _selectedType;
  late DateTime _selectedDate;
  bool _saveAsTemplate = false;
  List<CreateSplitEntry>? _splitEntries;

  bool get _isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final t = widget.transaction!;
      _amountController.text = t.amount.toStringAsFixed(2);
      _descriptionController.text = t.description ?? '';
      _notesController.text = t.notes ?? '';
      _selectedType = t.type;
      _selectedDate = t.transactionDate;
    } else {
      _selectedType = TransactionType.expense;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<TransactionState>(transactionProvider, (previous, next) {
      if (next is TransactionCreated || next is TransactionUpdated) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next is TransactionCreated
                  ? l10n.transactionCreated
                  : l10n.transactionUpdated,
            ),
          ),
        );
      } else if (next is TransactionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? l10n.editTransaction : l10n.newTransaction),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: l10n.templates,
            onPressed: _showTemplatePicker,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type selector
              Text(
                l10n.type,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: TransactionType.values.map((type) {
                  final isSelected = _selectedType == type;
                  final color = type == TransactionType.income
                      ? Colors.green
                      : type == TransactionType.expense
                          ? Colors.red
                          : Colors.blue;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(type.displayName),
                        selected: isSelected,
                        onSelected: _isEditMode
                            ? null
                            : (val) {
                                if (val) setState(() => _selectedType = type);
                              },
                        selectedColor: color.withOpacity(0.2),
                        avatar: Icon(
                          type == TransactionType.income
                              ? Icons.trending_up
                              : type == TransactionType.expense
                                  ? Icons.trending_down
                                  : Icons.swap_horiz,
                          color: isSelected ? color : Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Amount field (prominent)
              CurrencyInputField(
                controller: _amountController,
                autofocus: !_isEditMode,
              ),
              const SizedBox(height: 16),

              // Split toggle (only for expenses in create mode)
              if (!_isEditMode && _selectedType == TransactionType.expense)
                SplitToggleWidget(
                  transactionAmount: CurrencyInputField.parseAmount(
                    _amountController.text.isEmpty ? '0' : _amountController.text,
                  ),
                  members: const [], // TODO: populate from budget members
                  onSplitsChanged: (entries) {
                    setState(() => _splitEntries = entries);
                  },
                ),
              const SizedBox(height: 24),

              // Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(l10n.date),
                subtitle: Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDate,
              ),
              const Divider(),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.descriptionOptional,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLength: 500,
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.notesOptional,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Save as template toggle
              if (!_isEditMode)
                SwitchListTile(
                  title: Text(l10n.saveAsTemplate),
                  subtitle: Text(l10n.reuseThisPatternLater),
                  value: _saveAsTemplate,
                  onChanged: (val) =>
                      setState(() => _saveAsTemplate = val),
                ),
              const SizedBox(height: 16),

              // Save button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditMode ? l10n.update : l10n.save,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              // Delete button (edit mode only)
              if (_isEditMode) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _confirmDelete,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text(l10n.deleteTransaction),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyInputField.parseAmount(_amountController.text);
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    if (_isEditMode) {
      ref.read(transactionProvider.notifier).updateTransaction(
            budgetId: widget.budgetId,
            id: widget.transaction!.id,
            transactionDate: _selectedDate,
            amount: amount,
            description: description,
            notes: notes,
          );
    } else {
      ref.read(transactionProvider.notifier).createTransaction(
            budgetId: widget.budgetId,
            transactionDate: _selectedDate,
            amount: amount,
            type: _selectedType,
            description: description,
            notes: notes,
          );

      // Save as template if toggled
      if (_saveAsTemplate) {
        _promptTemplateNameAndSave(amount, description);
      }
    }
  }

  void _promptTemplateNameAndSave(double amount, String? description) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(
      text: description ?? _selectedType.displayName,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.templateName),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: l10n.enterTemplateName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.skip),
          ),
          ElevatedButton(
            onPressed: () {
              final template = TransactionTemplate(
                id: const Uuid().v4(),
                name: nameController.text,
                amount: amount,
                type: _selectedType,
                description: description,
                createdAt: DateTime.now(),
              );
              ref
                  .read(transactionTemplateProvider.notifier)
                  .saveTemplate(template);
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showTemplatePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TemplateSelectorWidget(
        onSelect: (template) {
          setState(() {
            _selectedType = template.type;
            if (template.amount != null) {
              _amountController.text = template.amount!.toStringAsFixed(2);
            }
            if (template.description != null) {
              _descriptionController.text = template.description!;
            }
          });
        },
      ),
    );
  }

  void _confirmDelete() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTransaction),
        content: Text(l10n.areYouSure),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.heavyImpact();
              ref.read(transactionProvider.notifier).deleteTransaction(
                    budgetId: widget.budgetId,
                    id: widget.transaction!.id,
                  );
              Navigator.pop(this.context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
