import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account.dart';
import '../providers/account_provider.dart';
import '../providers/account_state.dart';

class TransferPage extends ConsumerStatefulWidget {
  final String budgetId;

  const TransferPage({
    super.key,
    required this.budgetId,
  });

  @override
  ConsumerState<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends ConsumerState<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Account? _fromAccount;
  Account? _toAccount;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(accountProvider.notifier).loadAccounts(widget.budgetId));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accounts = ref.read(accountProvider.notifier).activeAccounts;

    ref.listen<AccountState>(accountProvider, (previous, next) {
      if (next is TransferCompleted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.transferCompletedSuccessfully)),
        );
      } else if (next is AccountError) {
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
      title: Text(l10n.transferMoney),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // From Account
                Text(
                  l10n.fromAccount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Account>(
                  value: _fromAccount,
                  decoration: InputDecoration(
                    hintText: l10n.selectSourceAccount,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                  ),
                  items: accounts.map((account) {
                    return DropdownMenuItem(
                      value: account,
                      child: _buildAccountDropdownItem(account),
                    );
                  }).toList(),
                  onChanged: (account) {
                    setState(() {
                      _fromAccount = account;
                      // Clear to account if same as from
                      if (_toAccount?.id == account?.id) {
                        _toAccount = null;
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return l10n.pleaseSelectSourceAccount;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Swap Button
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.swap_vert),
                    onPressed: () {
                      setState(() {
                        final temp = _fromAccount;
                        _fromAccount = _toAccount;
                        _toAccount = temp;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // To Account
                Text(
                  l10n.toAccount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Account>(
                  value: _toAccount,
                  decoration: InputDecoration(
                    hintText: l10n.selectDestinationAccount,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.account_balance),
                  ),
                  items: accounts
                      .where((account) => account.id != _fromAccount?.id)
                      .map((account) {
                    return DropdownMenuItem(
                      value: account,
                      child: _buildAccountDropdownItem(account),
                    );
                  }).toList(),
                  onChanged: (account) {
                    setState(() => _toAccount = account);
                  },
                  validator: (value) {
                    if (value == null) {
                      return l10n.pleaseSelectDestinationAccount;
                    }
                    if (value.id == _fromAccount?.id) {
                      return l10n.cannotTransferSameAccount;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.amountRequired;
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null) {
                      return l10n.invalidNumber;
                    }
                    if (amount <= 0) {
                      return l10n.amountMustBePositive;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description (Optional)
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.descriptionOptional,
                    hintText: 'e.g., Monthly savings',
                    prefixIcon: const Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                ),

                // Transfer Summary
                if (_fromAccount != null && _toAccount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _buildTransferSummary(),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleTransfer,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.transfer),
        ),
      ],
    );
  }

  Widget _buildAccountDropdownItem(Account account) {
    return Row(
      children: [
        Text(
          account.type.icon,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                account.formattedBalance,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransferSummary() {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.transferSummary,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            l10n.from,
            _fromAccount!.name,
            l10n.newBalance(_fromAccount!.currency, (_fromAccount!.currentBalance - amount).toStringAsFixed(2)),
          ),
          const Divider(height: 20),
          _buildSummaryRow(
            l10n.to,
            _toAccount!.name,
            l10n.newBalance(_toAccount!.currency, (_toAccount!.currentBalance + amount).toStringAsFixed(2)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String account, String newBalance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          account,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          newBalance,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _handleTransfer() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final notifier = ref.read(accountProvider.notifier);
    notifier.transfer(
      budgetId: widget.budgetId,
      fromAccountId: _fromAccount!.id,
      toAccountId: _toAccount!.id,
      amount: double.parse(_amountController.text.trim()),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );
  }
}
