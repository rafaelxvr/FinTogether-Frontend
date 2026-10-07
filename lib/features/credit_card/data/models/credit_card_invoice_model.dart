import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/credit_card_invoice.dart';

part 'credit_card_invoice_model.g.dart';

/// Credit Card Invoice Model
/// JSON serializable model for API communication
@JsonSerializable()
class CreditCardInvoiceModel {
  final String cardId;
  final String cardName;
  final String referenceMonth;
  final String periodStart;
  final String periodEnd;
  final String dueDate;
  final double totalAmount;
  final int transactionCount;
  final List<InvoiceTransactionModel> transactions;
  final String status;
  @JsonKey(name: 'credit_limit')
  final double? creditLimit;
  @JsonKey(name: 'available_credit')
  final double? availableCredit;

  CreditCardInvoiceModel({
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

  factory CreditCardInvoiceModel.fromJson(Map<String, dynamic> json) =>
      _$CreditCardInvoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreditCardInvoiceModelToJson(this);

  /// Convert to domain entity
  CreditCardInvoice toEntity() {
    return CreditCardInvoice(
      cardId: cardId,
      cardName: cardName,
      referenceMonth: referenceMonth,
      periodStart: DateTime.parse(periodStart),
      periodEnd: DateTime.parse(periodEnd),
      dueDate: DateTime.parse(dueDate),
      totalAmount: totalAmount,
      transactionCount: transactionCount,
      transactions: transactions.map((t) => t.toEntity()).toList(),
      status: _parseInvoiceStatus(status),
      creditLimit: creditLimit,
      availableCredit: availableCredit,
    );
  }

  static InvoiceStatus _parseInvoiceStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return InvoiceStatus.open;
      case 'closed':
        return InvoiceStatus.closed;
      case 'overdue':
        return InvoiceStatus.overdue;
      case 'paid':
        return InvoiceStatus.paid;
      default:
        return InvoiceStatus.open;
    }
  }
}

/// Invoice Transaction Model
/// JSON serializable model for invoice transactions
@JsonSerializable()
class InvoiceTransactionModel {
  final String id;
  final String transactionDate;
  final String? description;
  final String? categoryName;
  final String? categoryId;
  final double amount;
  final String? installmentInfo;

  InvoiceTransactionModel({
    required this.id,
    required this.transactionDate,
    this.description,
    this.categoryName,
    this.categoryId,
    required this.amount,
    this.installmentInfo,
  });

  factory InvoiceTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceTransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceTransactionModelToJson(this);

  /// Convert to domain entity
  InvoiceTransaction toEntity() {
    return InvoiceTransaction(
      id: id,
      transactionDate: DateTime.parse(transactionDate),
      description: description,
      categoryName: categoryName,
      categoryId: categoryId,
      amount: amount,
      installmentInfo: installmentInfo,
    );
  }
}

/// Invoice Summary Model
/// JSON serializable model for invoice summaries
@JsonSerializable()
class InvoiceSummaryModel {
  final String referenceMonth;
  final String periodStart;
  final String periodEnd;
  final String dueDate;
  final double totalAmount;
  final int transactionCount;
  final String status;

  InvoiceSummaryModel({
    required this.referenceMonth,
    required this.periodStart,
    required this.periodEnd,
    required this.dueDate,
    required this.totalAmount,
    required this.transactionCount,
    required this.status,
  });

  factory InvoiceSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceSummaryModelToJson(this);

  /// Convert to domain entity
  InvoiceSummary toEntity() {
    return InvoiceSummary(
      referenceMonth: referenceMonth,
      periodStart: DateTime.parse(periodStart),
      periodEnd: DateTime.parse(periodEnd),
      dueDate: DateTime.parse(dueDate),
      totalAmount: totalAmount,
      transactionCount: transactionCount,
      status: CreditCardInvoiceModel._parseInvoiceStatus(status),
    );
  }
}
