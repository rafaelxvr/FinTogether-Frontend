import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_goal_provider.dart';
import '../providers/savings_goal_state.dart';
import 'savings_goal_progress_bar.dart';

class ContributeBottomSheet extends ConsumerStatefulWidget {
  final SavingsGoal goal;
  final String budgetId;
  final bool isWithdrawal;

  const ContributeBottomSheet({
    super.key,
    required this.goal,
    required this.budgetId,
    this.isWithdrawal = false,
  });

  @override
  ConsumerState<ContributeBottomSheet> createState() =>
      _ContributeBottomSheetState();
}

class _ContributeBottomSheetState extends ConsumerState<ContributeBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  double get _enteredAmount {
    final text = _amountController.text.replaceAll(',', '.');
    return double.tryParse(text) ?? 0;
  }

  double get _previewAmount {
    if (widget.isWithdrawal) {
      return (widget.goal.currentAmount - _enteredAmount)
          .clamp(0, double.infinity);
    }
    return widget.goal.currentAmount + _enteredAmount;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SavingsGoalState>(savingsGoalProvider, (previous, next) {
      if (next is ContributionSuccess || next is WithdrawalSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isWithdrawal
                ? 'Withdrawal successful!'
                : 'Contribution successful!'),
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

    final isLoading = ref.watch(savingsGoalProvider) is SavingsGoalLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              widget.isWithdrawal ? 'Withdraw' : 'Contribute',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.goal.name,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Current progress
            SavingsGoalProgressBar(
              currentAmount: widget.goal.currentAmount,
              targetAmount: widget.goal.targetAmount,
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.goal.formattedCurrentAmount} of ${widget.goal.formattedTargetAmount}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Amount field
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '${widget.goal.currency} ',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required';
                }
                final amount =
                    double.tryParse(value.replaceAll(',', '.'));
                if (amount == null || amount <= 0) {
                  return 'Enter a valid positive amount';
                }
                if (widget.isWithdrawal &&
                    amount > widget.goal.currentAmount) {
                  return 'Amount exceeds current balance';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Note field
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
              maxLength: 255,
            ),
            const SizedBox(height: 8),

            // Preview
            if (_enteredAmount > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('After:',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      '${widget.goal.currency} ${_previewAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Submit button
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    widget.isWithdrawal ? Colors.orange : Colors.green,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      widget.isWithdrawal ? 'Withdraw' : 'Contribute',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount =
        double.parse(_amountController.text.replaceAll(',', '.'));
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();
    final notifier = ref.read(savingsGoalProvider.notifier);

    if (widget.isWithdrawal) {
      notifier.withdraw(
        budgetId: widget.budgetId,
        id: widget.goal.id,
        amount: amount,
        note: note,
      );
    } else {
      notifier.contribute(
        budgetId: widget.budgetId,
        id: widget.goal.id,
        amount: amount,
        note: note,
      );
    }
  }
}

void showContributeBottomSheet(
  BuildContext context, {
  required SavingsGoal goal,
  required String budgetId,
  bool isWithdrawal = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => ContributeBottomSheet(
      goal: goal,
      budgetId: budgetId,
      isWithdrawal: isWithdrawal,
    ),
  );
}
