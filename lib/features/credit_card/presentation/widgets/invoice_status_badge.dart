import 'package:flutter/material.dart';
import '../../domain/entities/credit_card_invoice.dart';

/// Reusable badge widget that displays the invoice status with color coding.
class InvoiceStatusBadge extends StatelessWidget {
  final InvoiceStatus status;
  final double fontSize;

  const InvoiceStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }

  String get _label {
    switch (status) {
      case InvoiceStatus.open:
        return 'OPEN';
      case InvoiceStatus.closed:
        return 'CLOSED';
      case InvoiceStatus.overdue:
        return 'OVERDUE';
      case InvoiceStatus.paid:
        return 'PAID';
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case InvoiceStatus.open:
        return Colors.green.withOpacity(0.15);
      case InvoiceStatus.closed:
        return Colors.blue.withOpacity(0.15);
      case InvoiceStatus.overdue:
        return Colors.red.withOpacity(0.15);
      case InvoiceStatus.paid:
        return Colors.grey.withOpacity(0.15);
    }
  }

  Color get _textColor {
    switch (status) {
      case InvoiceStatus.open:
        return Colors.green[800]!;
      case InvoiceStatus.closed:
        return Colors.blue[800]!;
      case InvoiceStatus.overdue:
        return Colors.red[800]!;
      case InvoiceStatus.paid:
        return Colors.grey[700]!;
    }
  }
}
