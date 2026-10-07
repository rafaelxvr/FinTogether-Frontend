import 'package:equatable/equatable.dart';

enum InvoiceStatus { open, closed, overdue, paid }

/// Credit Card Invoice Entity
/// Domain model for credit card invoices
class CreditCardInvoice extends Equatable {
  final String cardId;
  final String cardName;
  final String referenceMonth;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime dueDate;
  final double totalAmount;
  final int transactionCount;
  final List<InvoiceTransaction> transactions;
  final InvoiceStatus status;
  final double? creditLimit;
  final double? availableCredit;

  const CreditCardInvoice({
    required this.cardId,
    required this.cardName,
    required this.referenceMonth,
    required this.periodStart,
    required this.periodEnd,
    required this.dueDate,
    required this.totalAmount,
    required this.transactionCount,
    required this.transactions,
    required this.status,
    this.creditLimit,
    this.availableCredit,
  });

  @override
  List<Object?> get props => [cardId, referenceMonth, totalAmount, status];
}

/// Invoice Transaction Entity
/// Represents a single transaction within an invoice
class InvoiceTransaction extends Equatable {
  final String id;
  final DateTime transactionDate;
  final String? description;
  final String? categoryName;
  final String? categoryId;
  final double amount;
  final String? installmentInfo;

  const InvoiceTransaction({
    required this.id,
    required this.transactionDate,
    this.description,
    this.categoryName,
    this.categoryId,
    required this.amount,
    this.installmentInfo,
  });

  @override
  List<Object?> get props => [id, transactionDate, amount];
}

/// Invoice Summary Entity
/// Lightweight summary of an invoice without transaction details
class InvoiceSummary extends Equatable {
  final String referenceMonth;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime dueDate;
  final double totalAmount;
  final int transactionCount;
  final InvoiceStatus status;

  const InvoiceSummary({
    required this.referenceMonth,
    required this.periodStart,
    required this.periodEnd,
    required this.dueDate,
    required this.totalAmount,
    required this.transactionCount,
    required this.status,
  });

  @override
  List<Object?> get props => [referenceMonth, totalAmount, status];
}
