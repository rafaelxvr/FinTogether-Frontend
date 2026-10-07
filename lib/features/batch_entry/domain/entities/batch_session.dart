import 'package:equatable/equatable.dart';
import '../../../transaction/domain/entities/transaction.dart';
import 'batch_entry_item.dart';

class BatchSession extends Equatable {
  final List<BatchEntryItem> items;
  final String budgetId;
  final DateTime startedAt;

  const BatchSession({
    required this.items,
    required this.budgetId,
    required this.startedAt,
  });

  factory BatchSession.empty(String budgetId) {
    return BatchSession(
      items: const [],
      budgetId: budgetId,
      startedAt: DateTime.now(),
    );
  }

  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpenses => items
      .where((item) => item.transactionType == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalIncome => items
      .where((item) => item.transactionType == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);

  int get entryCount => items.length;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  String get formattedTotal => 'R\$ ${totalAmount.toStringAsFixed(2)}';

  BatchSession addItem(BatchEntryItem item) {
    return BatchSession(
      items: [...items, item],
      budgetId: budgetId,
      startedAt: startedAt,
    );
  }

  BatchSession removeItem(String localId) {
    return BatchSession(
      items: items.where((item) => item.localId != localId).toList(),
      budgetId: budgetId,
      startedAt: startedAt,
    );
  }

  BatchSession updateItem(String localId, BatchEntryItem updated) {
    return BatchSession(
      items: items
          .map((item) => item.localId == localId ? updated : item)
          .toList(),
      budgetId: budgetId,
      startedAt: startedAt,
    );
  }

  BatchSession clear() {
    return BatchSession.empty(budgetId);
  }

  @override
  List<Object?> get props => [items, budgetId, startedAt];
}
