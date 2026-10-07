import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../models/merchant_model.dart';

class MerchantLocalDataSource {
  final db.AppDatabase _database;

  MerchantLocalDataSource(this._database);

  Future<List<MerchantModel>> getMerchantsByBudget(String budgetId) async {
    final rows = await (_database.select(_database.merchants)
          ..where((t) => t.budgetId.equals(budgetId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();

    return rows.map(_mapToModel).toList();
  }

  Future<MerchantModel?> getMerchantById(String id) async {
    final row = await (_database.select(_database.merchants)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    return row != null ? _mapToModel(row) : null;
  }

  Future<List<MerchantModel>> searchMerchantsByName(
      String budgetId, String query) async {
    final rows = await (_database.select(_database.merchants)
          ..where((t) => t.budgetId.equals(budgetId))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.name.like('%$query%'))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();

    return rows.map(_mapToModel).toList();
  }

  Future<void> saveMerchants(List<MerchantModel> merchants,
      {bool isSynced = true}) async {
    await _database.batch((batch) {
      for (final merchant in merchants) {
        batch.insert(
          _database.merchants,
          _toCompanion(merchant, isSynced: isSynced),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> saveMerchant(MerchantModel merchant,
      {bool isSynced = true}) async {
    await _database.into(_database.merchants).insertOnConflictUpdate(
          _toCompanion(merchant, isSynced: isSynced),
        );
  }

  Future<void> softDelete(String id) async {
    await (_database.update(_database.merchants)
          ..where((t) => t.id.equals(id)))
        .write(db.MerchantsCompanion(
      deletedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));
  }

  Future<void> hardDelete(String id) async {
    await (_database.delete(_database.merchants)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<MerchantModel>> getUnsynced() async {
    final rows = await (_database.select(_database.merchants)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    return rows.map(_mapToModel).toList();
  }

  Future<void> markAsSynced(String id) async {
    await (_database.update(_database.merchants)
          ..where((t) => t.id.equals(id)))
        .write(const db.MerchantsCompanion(isSynced: Value(true)));
  }

  Future<void> clearByBudget(String budgetId) async {
    await (_database.delete(_database.merchants)
          ..where((t) => t.budgetId.equals(budgetId)))
        .go();
  }

  Future<void> clearAll() async {
    await _database.delete(_database.merchants).go();
  }

  // --- Private helpers ---

  MerchantModel _mapToModel(db.Merchant row) {
    return MerchantModel(
      id: row.id,
      budgetId: row.budgetId,
      name: row.name,
      displayName: row.displayName,
      logoUrl: row.logoUrl,
      color: row.color,
      defaultCategoryId: row.defaultCategoryId,
      archived: row.archived,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  db.MerchantsCompanion _toCompanion(MerchantModel model,
      {required bool isSynced}) {
    return db.MerchantsCompanion(
      id: Value(model.id),
      budgetId: Value(model.budgetId),
      name: Value(model.name),
      displayName: Value(model.displayName),
      logoUrl: Value(model.logoUrl),
      color: Value(model.color),
      defaultCategoryId: Value(model.defaultCategoryId),
      archived: Value(model.archived),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      deletedAt: Value(model.deletedAt),
      isSynced: Value(isSynced),
    );
  }
}
