import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../models/savings_goal_model.dart';

class SavingsGoalLocalDataSource {
  final db.AppDatabase _database;

  SavingsGoalLocalDataSource(this._database);

  Future<List<SavingsGoalModel>> getSavingsGoalsByBudget(
      String budgetId) async {
    final rows = await (_database.select(_database.savingsGoals)
          ..where((t) => t.budgetId.equals(budgetId))
          ..where((t) => t.deletedAt.isNull()))
        .get();
    return rows.map(_mapToModel).toList();
  }

  Future<List<SavingsGoalModel>> getAllActiveSavingsGoals() async {
    final rows = await (_database.select(_database.savingsGoals)
          ..where((t) => t.active.equals(true))
          ..where((t) => t.deletedAt.isNull()))
        .get();
    return rows.map(_mapToModel).toList();
  }

  Future<SavingsGoalModel?> getSavingsGoalById(String id) async {
    final row = await (_database.select(_database.savingsGoals)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    return row != null ? _mapToModel(row) : null;
  }

  Future<void> saveSavingsGoals(List<SavingsGoalModel> goals,
      {bool isSynced = true}) async {
    await _database.batch((batch) {
      for (final goal in goals) {
        batch.insert(
          _database.savingsGoals,
          _toCompanion(goal, isSynced: isSynced),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> saveSavingsGoal(SavingsGoalModel goal,
      {bool isSynced = true}) async {
    await _database.into(_database.savingsGoals).insertOnConflictUpdate(
          _toCompanion(goal, isSynced: isSynced),
        );
  }

  Future<void> softDelete(String id) async {
    await (_database.update(_database.savingsGoals)
          ..where((t) => t.id.equals(id)))
        .write(db.SavingsGoalsCompanion(
      deletedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));
  }

  Future<void> hardDelete(String id) async {
    await (_database.delete(_database.savingsGoals)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<SavingsGoalModel>> getUnsynced() async {
    final rows = await (_database.select(_database.savingsGoals)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    return rows.map(_mapToModel).toList();
  }

  Future<void> markAsSynced(String id) async {
    await (_database.update(_database.savingsGoals)
          ..where((t) => t.id.equals(id)))
        .write(const db.SavingsGoalsCompanion(isSynced: Value(true)));
  }

  Future<void> clearByBudget(String budgetId) async {
    await (_database.delete(_database.savingsGoals)
          ..where((t) => t.budgetId.equals(budgetId)))
        .go();
  }

  Future<void> clearAll() async {
    await _database.delete(_database.savingsGoals).go();
  }

  // --- Mapping helpers ---

  SavingsGoalModel _mapToModel(db.SavingsGoal row) {
    return SavingsGoalModel(
      id: row.id,
      budgetId: row.budgetId,
      accountId: row.accountId,
      name: row.name,
      description: row.description,
      targetAmount: row.targetAmount,
      currentAmount: row.currentAmount,
      currency: row.currency,
      deadline: row.deadline,
      icon: row.icon,
      color: row.color,
      active: row.active,
      completedAt: row.completedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  db.SavingsGoalsCompanion _toCompanion(SavingsGoalModel model,
      {required bool isSynced}) {
    return db.SavingsGoalsCompanion(
      id: Value(model.id),
      budgetId: Value(model.budgetId),
      accountId: Value(model.accountId),
      name: Value(model.name),
      description: Value(model.description),
      targetAmount: Value(model.targetAmount),
      currentAmount: Value(model.currentAmount),
      currency: Value(model.currency),
      deadline: Value(model.deadline),
      icon: Value(model.icon),
      color: Value(model.color),
      active: Value(model.active),
      completedAt: Value(model.completedAt),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      deletedAt: Value(model.deletedAt),
      isSynced: Value(isSynced),
    );
  }
}
