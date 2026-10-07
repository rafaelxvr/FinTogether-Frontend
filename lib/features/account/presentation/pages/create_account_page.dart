import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account.dart';
import '../providers/account_provider.dart';
import '../providers/account_state.dart';

class CreateAccountPage extends ConsumerStatefulWidget {
  final String budgetId;
  final Account? account; // For editing

  const CreateAccountPage({
    super.key,
    required this.budgetId,
    this.account,
  });

  @override
  ConsumerState<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends ConsumerState<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currencyController = TextEditingController(text: 'BRL');
  final _openingBalanceController = TextEditingController(text: '0.00');

  AccountType _selectedType = AccountType.checking;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      // Editing mode
      _nameController.text = widget.account!.name;
      _currencyController.text = widget.account!.currency;
      _selectedType = widget.account!.type;
      // Opening balance can't be edited
      _openingBalanceController.text =
          widget.account!.openingBalance.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AccountState>(accountProvider, (previous, next) {
      if (next is AccountCreated) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.accountCreatedSuccessfully)),
        );
      } else if (next is AccountUpdated) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.accountUpdatedSuccessfully)),
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
      title: Text(widget.account == null ? l10n.createAccount : l10n.editAccount),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.accountName,
                    hintText: l10n.accountNameHint,
                    prefixIcon: const Icon(Icons.account_balance),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.accountNameRequired;
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
                const SizedBox(height: 20),

                // Account Type
                Text(
                  l10n.accountType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTypeSelector(),
                const SizedBox(height: 20),

                // Currency
                TextFormField(
                  controller: _currencyController,
                  decoration: InputDecoration(
                    labelText: l10n.currency,
                    hintText: 'BRL',
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(3),
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.currencyRequired;
                    }
                    if (value.trim().length != 3) {
                      return l10n.currencyMustBe3Letters;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Opening Balance (only for new accounts)
                if (widget.account == null)
                  TextFormField(
                    controller: _openingBalanceController,
                    decoration: InputDecoration(
                      labelText: l10n.openingBalance,
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.openingBalanceRequired;
                      }
                      final balance = double.tryParse(value.trim());
                      if (balance == null) {
                        return l10n.invalidNumber;
                      }
                      return null;
                    },
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
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.account == null ? l10n.create : l10n.update),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AccountType.values.map((type) {
        return _buildTypeChip(type);
      }).toList(),
    );
  }

  Widget _buildTypeChip(AccountType type) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            type.icon,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(type.displayName),
        ],
      ),
      selected: isSelected,
      onSelected: widget.account == null
          ? (selected) {
              if (selected) {
                setState(() => _selectedType = type);
              }
            }
          : null, // Disable type change when editing
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final notifier = ref.read(accountProvider.notifier);

    if (widget.account == null) {
      // Create new account
      notifier.createAccount(
        budgetId: widget.budgetId,
        name: _nameController.text.trim(),
        type: _selectedType,
        currency: _currencyController.text.trim().toUpperCase(),
        openingBalance: double.parse(_openingBalanceController.text.trim()),
      );
    } else {
      // Update existing account
      notifier.updateAccount(
        budgetId: widget.budgetId,
        id: widget.account!.id,
        name: _nameController.text.trim(),
        currency: _currencyController.text.trim().toUpperCase(),
      );
    }
  }
}
