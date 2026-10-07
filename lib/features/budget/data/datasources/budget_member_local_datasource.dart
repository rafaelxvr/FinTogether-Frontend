import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/budget_member.dart';
import '../models/budget_member_model.dart';

class BudgetMemberLocalDataSource {
  final db.AppDatabase _database;

  BudgetMemberLocalDataSource(this._database);

  Future<List<BudgetMemberModel>> getMembers(String budgetId) async {
    final rows = await (_database.select(_database.budgetMembers)
          ..where((t) => t.budgetId.equals(budgetId))
          ..where((t) => t.deletedAt.isNull()))
        .get();

    final result = <BudgetMemberModel>[];
    for (final row in rows) {
      result.add(await _enrichMember(row));
    }
    return result;
  }

  Future<BudgetMemberModel?> getMemberById(String id) async {
    final row = await (_database.select(_database.budgetMembers)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) return null;
    return _enrichMember(row);
  }

  Future<void> saveMembers(List<BudgetMemberModel> members,
      {bool isSynced = true}) async {
    await _database.batch((batch) {
      for (final member in members) {
        batch.insert(
          _database.budgetMembers,
          _toCompanion(member, isSynced: isSynced),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> saveMember(BudgetMemberModel member,
      {bool isSynced = true}) async {
    await _database.into(_database.budgetMembers).insertOnConflictUpdate(
          _toCompanion(member, isSynced: isSynced),
        );
  }

  Future<void> softDelete(String id) async {
    await (_database.update(_database.budgetMembers)
          ..where((t) => t.id.equals(id)))
        .write(db.BudgetMembersCompanion(
      deletedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));
  }

  Future<void> hardDelete(String id) async {
    await (_database.delete(_database.budgetMembers)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<BudgetMemberModel>> getUnsynced() async {
    final rows = await (_database.select(_database.budgetMembers)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    final result = <BudgetMemberModel>[];
    for (final row in rows) {
      result.add(await _enrichMember(row));
    }
    return result;
  }

  Future<void> markAsSynced(String id) async {
    await (_database.update(_database.budgetMembers)
          ..where((t) => t.id.equals(id)))
        .write(const db.BudgetMembersCompanion(isSynced: Value(true)));
  }

  Future<void> clearByBudget(String budgetId) async {
    await (_database.delete(_database.budgetMembers)
          ..where((t) => t.budgetId.equals(budgetId)))
        .go();
  }

  Future<void> clearAll() async {
    await _database.delete(_database.budgetMembers).go();
  }

  // --- Private helpers ---

  Future<BudgetMemberModel> _enrichMember(db.BudgetMember row) async {
    final userRow = await (_database.select(_database.users)
          ..where((t) => t.id.equals(row.userId)))
        .getSingleOrNull();

    return BudgetMemberModel(
      id: row.id,
      budgetId: row.budgetId,
      userId: row.userId,
      userName: userRow?.name ?? '',
      userEmail: userRow?.email ?? '',
      role: _parseMemberRole(row.role),
      joinedAt: row.joinedAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  db.BudgetMembersCompanion _toCompanion(BudgetMemberModel model,
      {required bool isSynced}) {
    return db.BudgetMembersCompanion(
      id: Value(model.id),
      budgetId: Value(model.budgetId),
      userId: Value(model.userId),
      role: Value(model.role.name),
      joinedAt: Value(model.joinedAt),
      updatedAt: Value(model.updatedAt),
      deletedAt: Value(model.deletedAt),
      isSynced: Value(isSynced),
    );
  }

  BudgetMemberRole _parseMemberRole(String value) {
    return BudgetMemberRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BudgetMemberRole.member,
    );
  }
}
