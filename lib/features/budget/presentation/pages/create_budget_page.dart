import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/budget_state.dart';

class CreateBudgetDialog extends ConsumerStatefulWidget {
  final Budget? budget; // If provided, we're editing

  const CreateBudgetDialog({super.key, this.budget});

  @override
  ConsumerState<CreateBudgetDialog> createState() => _CreateBudgetDialogState();
}

class _CreateBudgetDialogState extends ConsumerState<CreateBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  BudgetType _selectedType = BudgetType.personal;
  bool _isLoading = false;

  bool get isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.budget!.name;
      _selectedType = widget.budget!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Listen to budget state for feedback
    ref.listen<BudgetState>(budgetProvider, (previous, next) {
      if (next is BudgetCreated || next is BudgetUpdated) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? l10n.budgetUpdatedSuccessfully : l10n.budgetCreatedSuccessfully,
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (next is BudgetError) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return AlertDialog(
      title: Text(isEditing ? l10n.editBudget : l10n.createBudget),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.budgetName,
                hintText: l10n.budgetNameHint,
                prefixIcon: const Icon(Icons.account_balance_wallet),
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.budgetNameRequired;
                }
                if (value.trim().length < 2) {
                  return l10n.budgetNameMinLength;
                }
                if (value.length > 255) {
                  return l10n.budgetNameMaxLength;
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.budgetType,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _buildBudgetTypeSelector(),
            const SizedBox(height: 8),
            Text(
              _selectedType == BudgetType.personal
                  ? l10n.personalBudgetDescription
                  : l10n.sharedBudgetDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? l10n.update : l10n.create),
        ),
      ],
    );
  }

  Widget _buildBudgetTypeSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _buildTypeOption(
            type: BudgetType.personal,
            icon: Icons.person,
            label: l10n.personal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeOption(
            type: BudgetType.shared,
            icon: Icons.people,
            label: l10n.shared,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption({
    required BudgetType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: _isLoading ? null : () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final budgetNotifier = ref.read(budgetProvider.notifier);

      if (isEditing) {
        budgetNotifier.updateBudget(
          id: widget.budget!.id,
          name: _nameController.text.trim(),
          type: _selectedType,
        );
      } else {
        budgetNotifier.createBudget(
          name: _nameController.text.trim(),
          type: _selectedType,
        );
      }
    }
  }
}
