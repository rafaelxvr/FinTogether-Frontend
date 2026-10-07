import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_search_params.dart';
import '../models/transaction_model.dart';

class TransactionLocalDataSource {
  final db.AppDatabase _database;

  TransactionLocalDataSource(this._database);

  Future<List<TransactionModel>> getTransactionsByBudget(
    String budgetId, {
    int? limit,
    int? offset,
  }) async {
    final query = _database.select(_database.transactions)
      ..where((t) => t.budgetId.equals(budgetId))
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    final rows = await query.get();
    return rows.map(_mapToModel).toList();
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    final row = await (_database.select(_database.transactions)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    return row != null ? _mapToModel(row) : null;
  }

  Future<void> saveTransactions(List<TransactionModel> transactions,
      {bool isSynced = true}) async {
    await _database.batch((batch) {
      for (final tx in transactions) {
        batch.insert(
          _database.transactions,
          _toCompanion(tx, isSynced: isSynced),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> saveTransaction(TransactionModel transaction,
      {bool isSynced = true}) async {
    await _database.into(_database.transactions).insertOnConflictUpdate(
          _toCompanion(transaction, isSynced: isSynced),
        );
  }

  Future<void> softDelete(String id) async {
    await (_database.update(_database.transactions)
          ..where((t) => t.id.equals(id)))
        .write(db.TransactionsCompanion(
      deletedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));
  }

  Future<void> hardDelete(String id) async {
    await (_database.delete(_database.transactions)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<TransactionModel>> getUnsynced() async {
    final rows = await (_database.select(_database.transactions)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    return rows.map(_mapToModel).toList();
  }

  Future<void> markAsSynced(String id) async {
    await (_database.update(_database.transactions)
          ..where((t) => t.id.equals(id)))
        .write(const db.TransactionsCompanion(isSynced: Value(true)));
  }

  Future<void> clearByBudget(String budgetId) async {
    await (_database.delete(_database.transactions)
          ..where((t) => t.budgetId.equals(budgetId)))
        .go();
  }

  Future<void> clearAll() async {
    await _database.delete(_database.transactions).go();
  }

  Future<List<TransactionModel>> searchTransactions(
    String budgetId,
    TransactionSearchParams params,
  ) async {
    final query = _database.select(_database.transactions)
      ..where((t) => t.budgetId.equals(budgetId))
      ..where((t) => t.deletedAt.isNull());

    if (params.query != null && params.query!.isNotEmpty) {
      final searchTerm = '%${params.query!.toLowerCase()}%';
      query.where((t) =>
          t.description.lower().like(searchTerm) |
          t.notes.lower().like(searchTerm));
    }
    if (params.type != null) {
      query.where((t) => t.type.equals(params.type!.toLowerCase()));
    }
    if (params.categoryId != null) {
      query.where((t) => t.categoryId.equals(params.categoryId!));
    }
    if (params.merchantId != null) {
      query.where((t) => t.merchantId.equals(params.merchantId!));
    }
    if (params.minAmount != null) {
      query.where(
          (t) => t.amount.isBiggerOrEqualValue(params.minAmount!));
    }
    if (params.maxAmount != null) {
      query.where(
          (t) => t.amount.isSmallerOrEqualValue(params.maxAmount!));
    }
    if (params.startDate != null) {
      query.where(
          (t) => t.transactionDate.isBiggerOrEqualValue(params.startDate!));
    }
    if (params.endDate != null) {
      query.where(
          (t) => t.transactionDate.isSmallerOrEqualValue(params.endDate!));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.transactionDate)]);
    query.limit(params.size, offset: params.page * params.size);

    final rows = await query.get();
    return rows.map(_mapToModel).toList();
  }

  // --- Mapping helpers ---

  TransactionModel _mapToModel(db.Transaction row) {
    // tags stored as JSON string e.g. '["food","travel"]'
    List<String>? tags;
    if (row.tags != null) {
      try {
        final decoded = jsonDecode(row.tags!) as List<dynamic>;
        tags = decoded.cast<String>();
      } catch (_) {
        tags = null;
      }
    }

    // recurrenceRule stored as JSON string
    Map<String, dynamic>? recurrenceRule;
    if (row.recurrenceRule != null) {
      try {
        recurrenceRule =
            jsonDecode(row.recurrenceRule!) as Map<String, dynamic>;
      } catch (_) {
        recurrenceRule = null;
      }
    }

    return TransactionModel(
      id: row.id,
      budgetId: row.budgetId,
      userId: row.userId,
      transactionDate: row.transactionDate,
      amount: row.amount,
      type: _parseTransactionType(row.type),
      accountId: row.accountId,
      categoryId: row.categoryId,
      cardId: row.cardId,
      description: row.description,
      notes: row.notes,
      tags: tags,
      visibility: _parseVisibility(row.visibility),
      isRecurring: row.isRecurring,
      recurrenceRule: recurrenceRule,
      isInstallment: row.isInstallment,
      installmentGroupId: row.installmentGroupId,
      installmentNumber: row.installmentNumber,
      merchantId: row.merchantId,
      syncedAt: row.syncedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  db.TransactionsCompanion _toCompanion(TransactionModel model,
      {required bool isSynced}) {
    // Serialize tags to JSON string
    final tagsJson =
        model.tags != null ? jsonEncode(model.tags) : null;

    // Serialize recurrenceRule to JSON string
    final recurrenceRuleJson =
        model.recurrenceRule != null ? jsonEncode(model.recurrenceRule) : null;

    return db.TransactionsCompanion(
      id: Value(model.id),
      budgetId: Value(model.budgetId),
      userId: Value(model.userId),
      transactionDate: Value(model.transactionDate),
      amount: Value(model.amount),
      type: Value(model.type.name),
      accountId: Value(model.accountId),
      categoryId: Value(model.categoryId),
      cardId: Value(model.cardId),
      description: Value(model.description),
      notes: Value(model.notes),
      tags: Value(tagsJson),
      visibility: Value(model.visibility.name),
      isRecurring: Value(model.isRecurring),
      recurrenceRule: Value(recurrenceRuleJson),
      isInstallment: Value(model.isInstallment),
      installmentGroupId: Value(model.installmentGroupId),
      installmentNumber: Value(model.installmentNumber),
      merchantId: Value(model.merchantId),
      syncedAt: Value(model.syncedAt),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      deletedAt: Value(model.deletedAt),
      isSynced: Value(isSynced),
    );
  }

  TransactionType _parseTransactionType(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.expense,
    );
  }

  TransactionVisibility _parseVisibility(String value) {
    return TransactionVisibility.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionVisibility.shared,
    );
  }
}
