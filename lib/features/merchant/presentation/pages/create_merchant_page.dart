import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/merchant.dart';
import '../providers/merchant_provider.dart';
import '../providers/merchant_state.dart';

class CreateMerchantPage extends ConsumerStatefulWidget {
  final String budgetId;
  final Merchant? merchant; // For editing

  const CreateMerchantPage({
    super.key,
    required this.budgetId,
    this.merchant,
  });

  @override
  ConsumerState<CreateMerchantPage> createState() => _CreateMerchantPageState();
}

class _CreateMerchantPageState extends ConsumerState<CreateMerchantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _colorController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.merchant != null) {
      _nameController.text = widget.merchant!.name;
      _displayNameController.text = widget.merchant!.displayName ?? '';
      _colorController.text = widget.merchant!.color ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<MerchantState>(merchantProvider, (previous, next) {
      if (next is MerchantCreated) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.merchantCreatedSuccessfully)),
        );
      } else if (next is MerchantUpdated) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.merchantUpdatedSuccessfully)),
        );
      } else if (next is MerchantError) {
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
      title:
          Text(widget.merchant == null ? l10n.createMerchant : l10n.editMerchant),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Merchant Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.merchantName,
                    hintText: l10n.merchantNameHint,
                    prefixIcon: const Icon(Icons.store),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.merchantNameRequired;
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

                // Display Name (Optional)
                TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: l10n.displayNameOptional,
                    hintText: l10n.displayNameHint,
                    prefixIcon: const Icon(Icons.label),
                  ),
                ),
                const SizedBox(height: 20),

                // Color (Optional)
                TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(
                    labelText: l10n.colorOptional,
                    hintText: l10n.colorHint,
                    prefixIcon: const Icon(Icons.palette),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[#0-9A-Fa-f]')),
                  ],
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final hexPattern = RegExp(r'^#?[0-9A-Fa-f]{6}$');
                      if (!hexPattern.hasMatch(value.trim())) {
                        return l10n.colorHexFormatError;
                      }
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
              : Text(widget.merchant == null ? l10n.create : l10n.update),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final notifier = ref.read(merchantProvider.notifier);

    if (widget.merchant == null) {
      notifier.createMerchant(
        budgetId: widget.budgetId,
        name: _nameController.text.trim(),
        displayName: _displayNameController.text.trim().isEmpty
            ? null
            : _displayNameController.text.trim(),
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
      );
    } else {
      notifier.updateMerchant(
        budgetId: widget.budgetId,
        id: widget.merchant!.id,
        name: _nameController.text.trim(),
        displayName: _displayNameController.text.trim().isEmpty
            ? null
            : _displayNameController.text.trim(),
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
      );
    }
  }
}
