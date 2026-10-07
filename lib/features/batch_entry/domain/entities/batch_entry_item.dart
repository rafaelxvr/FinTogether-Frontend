import 'package:equatable/equatable.dart';
import '../../../transaction/domain/entities/transaction.dart';

class BatchEntryItem extends Equatable {
  final String localId;
  final double amount;
  final String? description;
  final String? categoryId;
  final String? categoryName;
  final String? cardId;
  final String? accountId;
  final DateTime date;
  final TransactionType transactionType;
  final TransactionVisibility visibility;

  const BatchEntryItem({
    required this.localId,
    required this.amount,
    this.description,
    this.categoryId,
    this.categoryName,
    this.cardId,
    this.accountId,
    required this.date,
    this.transactionType = TransactionType.expense,
    this.visibility = TransactionVisibility.shared,
  });

  Map<String, dynamic> toCreateTransactionMap() {
    return {
      'transactionDate': date.toIso8601String().split('T')[0],
      'amount': amount,
      'type': _transactionTypeToString(transactionType),
      if (accountId != null) 'accountId': accountId,
      if (categoryId != null) 'categoryId': categoryId,
      if (cardId != null) 'cardId': cardId,
      if (description != null && description!.isNotEmpty)
        'description': description,
      'visibility': _visibilityToString(visibility),
    };
  }

  BatchEntryItem copyWith({
    String? localId,
    double? amount,
    String? description,
    String? categoryId,
    String? categoryName,
    String? cardId,
    String? accountId,
    DateTime? date,
    TransactionType? transactionType,
    TransactionVisibility? visibility,
  }) {
    return BatchEntryItem(
      localId: localId ?? this.localId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      cardId: cardId ?? this.cardId,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      transactionType: transactionType ?? this.transactionType,
      visibility: visibility ?? this.visibility,
    );
  }

  String get formattedAmount => 'R\$ ${amount.toStringAsFixed(2)}';

  bool get isExpense => transactionType == TransactionType.expense;
  bool get isIncome => transactionType == TransactionType.income;

  static String _transactionTypeToString(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'INCOME';
      case TransactionType.expense:
        return 'EXPENSE';
      case TransactionType.transfer:
        return 'TRANSFER';
    }
  }

  static String _visibilityToString(TransactionVisibility visibility) {
    switch (visibility) {
      case TransactionVisibility.private:
        return 'PRIVATE';
      case TransactionVisibility.shared:
        return 'SHARED';
    }
  }

  @override
  List<Object?> get props => [
        localId,
        amount,
        description,
        categoryId,
        categoryName,
        cardId,
        accountId,
        date,
        transactionType,
        visibility,
      ];
}
