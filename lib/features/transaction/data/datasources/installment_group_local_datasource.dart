import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../models/installment_group_model.dart';

class InstallmentGroupLocalDataSource {
  final db.AppDatabase _database;

  InstallmentGroupLocalDataSource(this._database);

  Future<List<InstallmentGroupModel>> getGroupsByBudget(
      String budgetId) async {
    final rows = await (_database.select(_database.installmentGroups)
          ..where((t) => t.budgetId.equals(budgetId))
          ..where((t) => t.deletedAt.isNull()))
        .get();
    return rows.map(_mapToModel).toList();
  }

  Future<InstallmentGroupModel?> getGroupById(String id) async {
    final row = await (_database.select(_database.installmentGroups)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    return row != null ? _mapToModel(row) : null;
  }

  Future<void> saveGroups(List<InstallmentGroupModel> groups,
      {bool isSynced = true}) async {
    await _database.batch((batch) {
      for (final group in groups) {
        batch.insert(
          _database.installmentGroups,
          _toCompanion(group, isSynced: isSynced),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> saveGroup(InstallmentGroupModel group,
      {bool isSynced = true}) async {
    await _database.into(_database.installmentGroups).insertOnConflictUpdate(
          _toCompanion(group, isSynced: isSynced),
        );
  }

  Future<void> softDelete(String id) async {
    await (_database.update(_database.installmentGroups)
          ..where((t) => t.id.equals(id)))
        .write(db.InstallmentGroupsCompanion(
      deletedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));
  }

  Future<void> hardDelete(String id) async {
    await (_database.delete(_database.installmentGroups)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<InstallmentGroupModel>> getUnsynced() async {
    final rows = await (_database.select(_database.installmentGroups)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    return rows.map(_mapToModel).toList();
  }

  Future<void> markAsSynced(String id) async {
    await (_database.update(_database.installmentGroups)
          ..where((t) => t.id.equals(id)))
        .write(const db.InstallmentGroupsCompanion(isSynced: Value(true)));
  }

  Future<void> clearByBudget(String budgetId) async {
    await (_database.delete(_database.installmentGroups)
          ..where((t) => t.budgetId.equals(budgetId)))
        .go();
  }

  Future<void> clearAll() async {
    await _database.delete(_database.installmentGroups).go();
  }

  // --- Mapping helpers ---

  InstallmentGroupModel _mapToModel(db.InstallmentGroup row) {
    return InstallmentGroupModel(
      id: row.id,
      budgetId: row.budgetId,
      cardId: row.cardId,
      totalAmount: row.totalAmount,
      installmentCount: row.installmentCount,
      interestRate: row.interestRate,
      startDate: row.startDate,
      description: row.description,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  db.InstallmentGroupsCompanion _toCompanion(InstallmentGroupModel model,
      {required bool isSynced}) {
    return db.InstallmentGroupsCompanion(
      id: Value(model.id),
      budgetId: Value(model.budgetId),
      cardId: Value(model.cardId),
      totalAmount: Value(model.totalAmount),
      installmentCount: Value(model.installmentCount),
      interestRate: Value(model.interestRate),
      startDate: Value(model.startDate),
      description: Value(model.description),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      deletedAt: Value(model.deletedAt),
      isSynced: Value(isSynced),
    );
  }
}
