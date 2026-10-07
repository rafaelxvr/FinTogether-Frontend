import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom currency input field with formatting
class CurrencyInputField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<double>? onChanged;
  final FormFieldValidator<String>? validator;
  final String currency;
  final bool autofocus;

  const CurrencyInputField({
    super.key,
    required this.controller,
    this.onChanged,
    this.validator,
    this.currency = 'BRL',
    this.autofocus = false,
  });

  /// Parse a currency text string into a double value
  static double parseAmount(String text) {
    final cleaned = text
        .replaceAll(RegExp(r'[^\d.,]'), '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  State<CurrencyInputField> createState() => _CurrencyInputFieldState();
}

class _CurrencyInputFieldState extends State<CurrencyInputField> {
  @override
  Widget build(BuildContext context) {
    final symbol = widget.currency == 'BRL' ? 'R\$' : '\$';

    return TextFormField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        prefixText: '$symbol ',
        prefixStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
        border: const OutlineInputBorder(),
        hintText: '0.00',
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
      ],
      validator: widget.validator ??
          (val) {
            if (val == null || val.isEmpty) return 'Required';
            final parsed = _parseValue(val);
            if (parsed == null) return 'Invalid number';
            if (parsed <= 0) return 'Must be > 0';
            return null;
          },
      onChanged: (val) {
        final parsed = _parseValue(val);
        if (parsed != null && widget.onChanged != null) {
          widget.onChanged!(parsed);
        }
      },
    );
  }

  static double? _parseValue(String text) {
    // Handle both Brazilian (1.500,00) and US (1,500.00) formats
    final cleaned = text
        .replaceAll(RegExp(r'[^\d.,]'), '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  /// Parse the controller's text into a double value
  static double parseAmount(String text) {
    return _parseValue(text) ?? 0.0;
  }
}
