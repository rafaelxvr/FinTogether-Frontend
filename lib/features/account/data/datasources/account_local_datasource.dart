import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/account.dart';
import '../models/account_model.dart';

class AccountLocalDataSource {
  final db.AppDatabase _database;

  AccountLocalDataSource(this._database);

  Future<List<AccountModel>> getAccountsByBudget(String budgetId) async {
    final rows = await (_database.select(_database.accounts)
          ..where((t) => t.budgetId.equals(budgetId))
          ..where((t) => t.deletedAt.isNull()))
        .get();
    return rows.map(_mapToModel).toList();
  }

  Future<AccountModel?> getAccountById(String id) async {
    final row = await (_database.select(_database.accounts)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    return row != null ? _mapToModel(row) : null;
  }

  Future<void> saveAccounts(List<AccountModel> accounts,
      {bool isSynced = true}) async {
    await _database.batch((batch) {
      for (final account in accounts) {
        batch.insert(
          _database.accounts,
          _toCompanion(account, isSynced: isSynced),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> saveAccount(AccountModel account, {bool isSynced = true}) async {
    await _database.into(_database.accounts).insertOnConflictUpdate(
          _toCompanion(account, isSynced: isSynced),
        );
  }

  Future<void> softDelete(String id) async {
    await (_database.update(_database.accounts)..where((t) => t.id.equals(id)))
        .write(db.AccountsCompanion(
      deletedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));
  }

  Future<void> hardDelete(String id) async {
    await (_database.delete(_database.accounts)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<AccountModel>> getUnsynced() async {
    final rows = await (_database.select(_database.accounts)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    return rows.map(_mapToModel).toList();
  }

  Future<void> markAsSynced(String id) async {
    await (_database.update(_database.accounts)..where((t) => t.id.equals(id)))
        .write(const db.AccountsCompanion(isSynced: Value(true)));
  }

  Future<void> clearByBudget(String budgetId) async {
    await (_database.delete(_database.accounts)
          ..where((t) => t.budgetId.equals(budgetId)))
        .go();
  }

  Future<void> clearAll() async {
    await _database.delete(_database.accounts).go();
  }

  // --- Mapping helpers ---

  AccountModel _mapToModel(db.Account row) {
    return AccountModel(
      id: row.id,
      budgetId: row.budgetId,
      name: row.name,
      type: _parseAccountType(row.type),
      currency: row.currency,
      openingBalance: row.openingBalance,
      currentBalance: row.currentBalance,
      active: row.active,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  db.AccountsCompanion _toCompanion(AccountModel model,
      {required bool isSynced}) {
    return db.AccountsCompanion(
      id: Value(model.id),
      budgetId: Value(model.budgetId),
      name: Value(model.name),
      type: Value(model.type.name),
      currency: Value(model.currency),
      openingBalance: Value(model.openingBalance),
      currentBalance: Value(model.currentBalance),
      active: Value(model.active),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      deletedAt: Value(model.deletedAt),
      isSynced: Value(isSynced),
    );
  }

  AccountType _parseAccountType(String value) {
    return AccountType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AccountType.checking,
    );
  }
}
