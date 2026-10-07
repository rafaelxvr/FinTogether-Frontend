import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/budget.dart';
import '../models/budget_model.dart';

class BudgetLocalDataSource {
  final db.AppDatabase _database;

  BudgetLocalDataSource(this._database);

  Future<List<BudgetModel>> getBudgets() async {
    final rows = await (_database.select(_database.budgets)
          ..where((t) => t.deletedAt.isNull()))
        .get();

    final result = <BudgetModel>[];
    for (final row in rows) {
      result.add(await _enrichBudget(row));
    }
    return result;
  }

  Future<BudgetModel?> getBudgetById(String id) async {
    final row = await (_database.select(_database.budgets)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) return null;
    return _enrichBudget(row);
  }

  Future<void> saveBudgets(List<BudgetModel> budgets,
      {bool isSynced = true}) async {
    await _database.batch((batch) {
      for (final budget in budgets) {
        batch.insert(
          _database.budgets,
          _toCompanion(budget, isSynced: isSynced),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> saveBudget(BudgetModel budget, {bool isSynced = true}) async {
    await _database.into(_database.budgets).insertOnConflictUpdate(
          _toCompanion(budget, isSynced: isSynced),
        );
  }

  Future<void> softDelete(String id) async {
    await (_database.update(_database.budgets)..where((t) => t.id.equals(id)))
        .write(db.BudgetsCompanion(
      deletedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));
  }

  Future<void> hardDelete(String id) async {
    await (_database.delete(_database.budgets)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<BudgetModel>> getUnsynced() async {
    final rows = await (_database.select(_database.budgets)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    final result = <BudgetModel>[];
    for (final row in rows) {
      result.add(await _enrichBudget(row));
    }
    return result;
  }

  Future<void> markAsSynced(String id) async {
    await (_database.update(_database.budgets)..where((t) => t.id.equals(id)))
        .write(const db.BudgetsCompanion(isSynced: Value(true)));
  }

  Future<void> clearAll() async {
    await _database.delete(_database.budgets).go();
  }

  // --- Private helpers ---

  Future<BudgetModel> _enrichBudget(db.Budget row) async {
    // Fetch owner name from Users table
    final ownerRow = await (_database.select(_database.users)
          ..where((t) => t.id.equals(row.ownerId)))
        .getSingleOrNull();
    final ownerName = ownerRow?.name ?? '';

    // Count members from BudgetMembers table
    final memberCountExpr = _database.budgetMembers.id.count();
    final memberCountQuery = _database.selectOnly(_database.budgetMembers)
      ..addColumns([memberCountExpr])
      ..where(_database.budgetMembers.budgetId.equals(row.id))
      ..where(_database.budgetMembers.deletedAt.isNull());
    final memberCountResult = await memberCountQuery.getSingle();
    final memberCount = memberCountResult.read(memberCountExpr) ?? 0;

    return BudgetModel(
      id: row.id,
      name: row.name,
      type: _parseBudgetType(row.type),
      ownerId: row.ownerId,
      ownerName: ownerName,
      memberCount: memberCount,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  db.BudgetsCompanion _toCompanion(BudgetModel model,
      {required bool isSynced}) {
    return db.BudgetsCompanion(
      id: Value(model.id),
      name: Value(model.name),
      ownerId: Value(model.ownerId),
      type: Value(model.type.name),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      deletedAt: Value(model.deletedAt),
      isSynced: Value(isSynced),
    );
  }

  BudgetType _parseBudgetType(String value) {
    return BudgetType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BudgetType.personal,
    );
  }
}
