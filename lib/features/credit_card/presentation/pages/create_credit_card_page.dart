import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/credit_card.dart';
import '../../../account/domain/entities/account.dart';
import '../../../account/presentation/providers/account_provider.dart';
import '../../../account/presentation/providers/account_state.dart';
import '../providers/credit_card_provider.dart';
import '../providers/credit_card_state.dart';

class CreateCreditCardPage extends ConsumerStatefulWidget {
  final String budgetId;
  final CreditCard? creditCard; // For editing

  const CreateCreditCardPage({
    super.key,
    required this.budgetId,
    this.creditCard,
  });

  @override
  ConsumerState<CreateCreditCardPage> createState() =>
      _CreateCreditCardPageState();
}

class _CreateCreditCardPageState extends ConsumerState<CreateCreditCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issuerController = TextEditingController();
  final _lastFourController = TextEditingController();
  final _currencyController = TextEditingController(text: 'BRL');
  final _statementCloseDayController = TextEditingController();
  final _dueDayController = TextEditingController();

  String? _selectedAccountId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Load accounts for linked account dropdown
    Future.microtask(() {
      ref.read(accountProvider.notifier).loadAccounts(widget.budgetId);
    });

    if (widget.creditCard != null) {
      // Editing mode
      _nameController.text = widget.creditCard!.name;
      _issuerController.text = widget.creditCard!.issuer ?? '';
      _lastFourController.text = widget.creditCard!.lastFour ?? '';
      _currencyController.text = widget.creditCard!.currency;
      _statementCloseDayController.text =
          widget.creditCard!.statementCloseDay.toString();
      _dueDayController.text = widget.creditCard!.dueDay.toString();
      _selectedAccountId = widget.creditCard!.linkedAccountId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _lastFourController.dispose();
    _currencyController.dispose();
    _statementCloseDayController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accountState = ref.watch(accountProvider);

    ref.listen<CreditCardState>(creditCardProvider, (previous, next) {
      if (next is CreditCardOperationSuccess) {
        Navigator.pop(context);
      } else if (next is CreditCardError) {
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
      title: Text(
          widget.creditCard == null ? l10n.createCreditCard : l10n.editCreditCard),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.cardName,
                    hintText: l10n.cardNameHint,
                    prefixIcon: const Icon(Icons.credit_card),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.cardNameRequired;
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

                // Issuer (Optional)
                TextFormField(
                  controller: _issuerController,
                  decoration: InputDecoration(
                    labelText: l10n.issuerOptional,
                    hintText: l10n.issuerHint,
                    prefixIcon: const Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16),

                // Last Four Digits (Optional)
                TextFormField(
                  controller: _lastFourController,
                  decoration: InputDecoration(
                    labelText: l10n.lastFourDigitsOptional,
                    hintText: '1234',
                    prefixIcon: const Icon(Icons.pin),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        value.length != 4) {
                      return l10n.mustBeExactly4Digits;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

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
                const SizedBox(height: 16),

                // Statement Close Day
                TextFormField(
                  controller: _statementCloseDayController,
                  decoration: InputDecoration(
                    labelText: l10n.closesDay,
                    hintText: '1-31',
                    prefixIcon: const Icon(Icons.event),
                    helperText: l10n.dayOfMonthStatementCloses,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.statementCloseDayRequired;
                    }
                    final day = int.tryParse(value.trim());
                    if (day == null || day < 1 || day > 31) {
                      return l10n.mustBeBetween1And31;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Due Day
                TextFormField(
                  controller: _dueDayController,
                  decoration: InputDecoration(
                    labelText: l10n.dueDay,
                    hintText: '1-31',
                    prefixIcon: const Icon(Icons.calendar_today),
                    helperText: l10n.dayOfMonthPaymentDue,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.dueDayRequired;
                    }
                    final day = int.tryParse(value.trim());
                    if (day == null || day < 1 || day > 31) {
                      return l10n.mustBeBetween1And31;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Linked Account (Optional)
                _buildLinkedAccountDropdown(accountState),
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
              : Text(widget.creditCard == null ? l10n.create : l10n.update),
        ),
      ],
    );
  }

  Widget _buildLinkedAccountDropdown(AccountState accountState) {
    final l10n = AppLocalizations.of(context)!;
    List<Account> accounts = [];

    if (accountState is AccountsLoaded) {
      accounts = accountState.accounts.where((a) => a.active).toList();
    }

    return DropdownButtonFormField<String?>(
      value: _selectedAccountId,
      decoration: InputDecoration(
        labelText: l10n.linkedPaymentAccountOptional,
        hintText: l10n.selectAnAccount,
        prefixIcon: const Icon(Icons.account_balance),
        helperText: l10n.accountToPayBill,
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(l10n.none),
        ),
        ...accounts.map((account) {
          return DropdownMenuItem<String?>(
            value: account.id,
            child: Text(account.name),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedAccountId = value;
        });
      },
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final notifier = ref.read(creditCardProvider.notifier);

    if (widget.creditCard == null) {
      // Create new credit card
      notifier.createCreditCard(
        budgetId: widget.budgetId,
        name: _nameController.text.trim(),
        issuer: _issuerController.text.trim().isEmpty
            ? null
            : _issuerController.text.trim(),
        lastFour: _lastFourController.text.trim().isEmpty
            ? null
            : _lastFourController.text.trim(),
        currency: _currencyController.text.trim().toUpperCase(),
        statementCloseDay: int.parse(_statementCloseDayController.text.trim()),
        dueDay: int.parse(_dueDayController.text.trim()),
        linkedAccountId: _selectedAccountId,
      );
    } else {
      // Update existing credit card
      notifier.updateCreditCard(
        widget.creditCard!.id,
        widget.budgetId,
        name: _nameController.text.trim(),
        issuer: _issuerController.text.trim().isEmpty
            ? null
            : _issuerController.text.trim(),
        lastFour: _lastFourController.text.trim().isEmpty
            ? null
            : _lastFourController.text.trim(),
        currency: _currencyController.text.trim().toUpperCase(),
        statementCloseDay: int.parse(_statementCloseDayController.text.trim()),
        dueDay: int.parse(_dueDayController.text.trim()),
        linkedAccountId: _selectedAccountId,
      );
    }
  }
}
