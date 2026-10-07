import 'package:equatable/equatable.dart';

enum TransactionType {
  income,
  expense,
  transfer;

  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  String get icon {
    switch (this) {
      case TransactionType.income:
        return '💰';
      case TransactionType.expense:
        return '💸';
      case TransactionType.transfer:
        return '🔄';
    }
  }
}

enum TransactionVisibility {
  private,
  shared;

  String get displayName {
    switch (this) {
      case TransactionVisibility.private:
        return 'Private';
      case TransactionVisibility.shared:
        return 'Shared';
    }
  }
}

class Transaction extends Equatable {
  final String id;
  final String budgetId;
  final String? userId;
  final DateTime transactionDate;
  final double amount;
  final TransactionType type;
  final String? accountId;
  final String? categoryId;
  final String? cardId;
  final String? description;
  final String? notes;
  final List<String>? tags;
  final TransactionVisibility visibility;
  final bool isRecurring;
  final Map<String, dynamic>? recurrenceRule;
  final bool isInstallment;
  final String? installmentGroupId;
  final int? installmentNumber;
  final String? parentRecurringId;
  final String? merchantId;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.budgetId,
    this.userId,
    required this.transactionDate,
    required this.amount,
    required this.type,
    this.accountId,
    this.categoryId,
    this.cardId,
    this.description,
    this.notes,
    this.tags,
    required this.visibility,
    required this.isRecurring,
    this.recurrenceRule,
    required this.isInstallment,
    this.installmentGroupId,
    this.installmentNumber,
    this.parentRecurringId,
    this.merchantId,
    this.syncedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasNotes => notes != null && notes!.isNotEmpty;
  bool get hasTags => tags != null && tags!.isNotEmpty;
  bool get hasAccount => accountId != null;
  bool get hasCategory => categoryId != null;
  bool get hasMerchant => merchantId != null;
  bool get isGeneratedFromRecurring => parentRecurringId != null;
  bool get isPrivate => visibility == TransactionVisibility.private;
  bool get isShared => visibility == TransactionVisibility.shared;

  // Type checks
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isTransfer => type == TransactionType.transfer;

  // Display helpers
  String get formattedAmount => 'BRL ${amount.toStringAsFixed(2)}';
  String get displayIcon => type.icon;
  String get displayType => type.displayName;

  String get amountWithSign {
    final sign = isIncome ? '+' : (isExpense ? '-' : '');
    return '$sign$formattedAmount';
  }

  @override
  List<Object?> get props => [
        id,
        budgetId,
        userId,
        transactionDate,
        amount,
        type,
        accountId,
        categoryId,
        cardId,
        description,
        notes,
        tags,
        visibility,
        isRecurring,
        recurrenceRule,
        isInstallment,
        installmentGroupId,
        installmentNumber,
        parentRecurringId,
        merchantId,
        syncedAt,
        createdAt,
        updatedAt,
      ];

  Transaction copyWith({
    String? id,
    String? budgetId,
    String? userId,
    DateTime? transactionDate,
    double? amount,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    String? cardId,
    String? description,
    String? notes,
    List<String>? tags,
    TransactionVisibility? visibility,
    bool? isRecurring,
    Map<String, dynamic>? recurrenceRule,
    bool? isInstallment,
    String? installmentGroupId,
    int? installmentNumber,
    String? parentRecurringId,
    String? merchantId,
    DateTime? syncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      userId: userId ?? this.userId,
      transactionDate: transactionDate ?? this.transactionDate,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      cardId: cardId ?? this.cardId,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      isInstallment: isInstallment ?? this.isInstallment,
      installmentGroupId: installmentGroupId ?? this.installmentGroupId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      parentRecurringId: parentRecurringId ?? this.parentRecurringId,
      merchantId: merchantId ?? this.merchantId,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
