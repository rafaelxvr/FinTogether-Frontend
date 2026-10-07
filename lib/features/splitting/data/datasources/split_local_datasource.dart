import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../models/transaction_split_model.dart';

class SplitLocalDataSource {
  final db.AppDatabase _database;

  SplitLocalDataSource(this._database);

  Future<List<TransactionSplitModel>> getSplitsByTransaction(
      String transactionId) async {
    final rows = await (_database.select(_database.transactionSplits)
          ..where((t) => t.transactionId.equals(transactionId))
          ..where((t) => t.deletedAt.isNull()))
        .get();
    return rows.map(_mapToModel).toList();
  }

  Future<TransactionSplitModel?> getSplitById(String id) async {
    final row = await (_database.select(_database.transactionSplits)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    return row != null ? _mapToModel(row) : null;
  }

  Future<List<TransactionSplitModel>> getUnsettledByBudget(
      String budgetId) async {
    // Join with transactions to filter by budget
    final query = _database.select(_database.transactionSplits).join([
      innerJoin(
        _database.transactions,
        _database.transactions.id
            .equalsExp(_database.transactionSplits.transactionId),
      ),
    ]);
    query.where(_database.transactions.budgetId.equals(budgetId) &
        _database.transactionSplits.isPaid.equals(false) &
        _database.transactionSplits.deletedAt.isNull());

    final rows = await query.get();
    return rows.map((row) {
      final splitRow = row.readTable(_database.transactionSplits);
      return _mapToModel(splitRow);
    }).toList();
  }

  Future<void> saveSplits(List<TransactionSplitModel> splits,
      {bool isSynced = true}) async {
    await _database.batch((batch) {
      for (final split in splits) {
        batch.insert(
          _database.transactionSplits,
          _toCompanion(split, isSynced: isSynced),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> saveSplit(TransactionSplitModel split,
      {bool isSynced = true}) async {
    await _database.into(_database.transactionSplits).insertOnConflictUpdate(
          _toCompanion(split, isSynced: isSynced),
        );
  }

  Future<void> markAsSettled(String id) async {
    await (_database.update(_database.transactionSplits)
          ..where((t) => t.id.equals(id)))
        .write(db.TransactionSplitsCompanion(
      isPaid: const Value(true),
      paidAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));
  }

  Future<List<TransactionSplitModel>> getUnsynced() async {
    final rows = await (_database.select(_database.transactionSplits)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    return rows.map(_mapToModel).toList();
  }

  Future<void> markAsSynced(String id) async {
    await (_database.update(_database.transactionSplits)
          ..where((t) => t.id.equals(id)))
        .write(
            const db.TransactionSplitsCompanion(isSynced: Value(true)));
  }

  Future<void> clearAll() async {
    await _database.delete(_database.transactionSplits).go();
  }

  // --- Mapping helpers ---

  TransactionSplitModel _mapToModel(db.TransactionSplit row) {
    return TransactionSplitModel(
      id: row.id,
      transactionId: row.transactionId,
      userId: row.userId,
      userName: row.userName,
      amount: row.amount,
      isPaid: row.isPaid,
      paidAt: row.paidAt,
      createdAt: row.createdAt,
    );
  }

  db.TransactionSplitsCompanion _toCompanion(TransactionSplitModel model,
      {required bool isSynced}) {
    return db.TransactionSplitsCompanion(
      id: Value(model.id),
      transactionId: Value(model.transactionId),
      userId: Value(model.userId),
      userName: Value(model.userName),
      amount: Value(model.amount),
      isPaid: Value(model.isPaid),
      paidAt: Value(model.paidAt),
      createdAt: Value(model.createdAt),
      isSynced: Value(isSynced),
    );
  }
}
