import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_goal_provider.dart';
import '../providers/savings_goal_state.dart';

class CreateSavingsGoalPage extends ConsumerStatefulWidget {
  final String budgetId;
  final SavingsGoal? goal; // null for create, non-null for edit

  const CreateSavingsGoalPage({
    super.key,
    required this.budgetId,
    this.goal,
  });

  @override
  ConsumerState<CreateSavingsGoalPage> createState() =>
      _CreateSavingsGoalPageState();
}

class _CreateSavingsGoalPageState
    extends ConsumerState<CreateSavingsGoalPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _targetAmountController;
  late final TextEditingController _currencyController;
  late final TextEditingController _iconController;
  late final TextEditingController _colorController;
  DateTime? _deadline;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.goal?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.goal?.description ?? '');
    _targetAmountController = TextEditingController(
        text: widget.goal != null
            ? widget.goal!.targetAmount.toStringAsFixed(2)
            : '');
    _currencyController =
        TextEditingController(text: widget.goal?.currency ?? 'BRL');
    _iconController =
        TextEditingController(text: widget.goal?.icon ?? '');
    _colorController =
        TextEditingController(text: widget.goal?.color ?? '');
    _deadline = widget.goal?.deadline;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _currencyController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<SavingsGoalState>(savingsGoalProvider, (previous, next) {
      if (next is SavingsGoalCreated || next is SavingsGoalUpdated) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? l10n.savingsGoalUpdated
                : l10n.savingsGoalCreated),
          ),
        );
      } else if (next is SavingsGoalError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final isLoading =
        ref.watch(savingsGoalProvider) is SavingsGoalLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editSavingsGoal : l10n.createSavingsGoal),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${l10n.name} *',
                  hintText: 'e.g., Emergency Fund',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.nameRequired;
                  }
                  if (value.trim().length < 2) {
                    return l10n.nameMinLengthGeneric;
                  }
                  if (value.length > 255) {
                    return l10n.nameMaxLengthGeneric;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.descriptionOptional,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 16),

              // Target amount
              TextFormField(
                controller: _targetAmountController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                decoration: InputDecoration(
                  labelText: '${l10n.targetAmount} *',
                  prefixText: 'R\$ ',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.targetAmountRequired;
                  }
                  final amount =
                      double.tryParse(value.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) {
                    return l10n.enterValidPositiveAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Currency
              TextFormField(
                controller: _currencyController,
                decoration: InputDecoration(
                  labelText: l10n.currency,
                  hintText: 'BRL',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length != 3) {
                    return l10n.currencyMustBe3Letters;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deadline
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.deadlineOptional),
                subtitle: Text(
                  _deadline != null
                      ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                      : l10n.noDeadlineSet,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_deadline != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _deadline = null),
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDeadline,
                    ),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Icon
              TextFormField(
                controller: _iconController,
                decoration: InputDecoration(
                  labelText: l10n.iconOptional,
                  hintText: 'Emoji or icon name',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Color
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(
                  labelText: l10n.colorOptional,
                  hintText: '#4CAF50',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? l10n.updateGoal : l10n.createGoal,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(savingsGoalProvider.notifier);
    final targetAmount = double.parse(
        _targetAmountController.text.replaceAll(',', '.'));

    if (_isEditing) {
      notifier.updateSavingsGoal(
        budgetId: widget.budgetId,
        id: widget.goal!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        targetAmount: targetAmount,
        deadline: _deadline,
        icon: _iconController.text.trim().isEmpty
            ? null
            : _iconController.text.trim(),
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
      );
    } else {
      notifier.createSavingsGoal(
        budgetId: widget.budgetId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        targetAmount: targetAmount,
        currency: _currencyController.text.trim().toUpperCase(),
        deadline: _deadline,
        icon: _iconController.text.trim().isEmpty
            ? null
            : _iconController.text.trim(),
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
      );
    }
  }
}
