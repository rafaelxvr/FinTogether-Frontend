import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../models/credit_card_model.dart';

class CreditCardLocalDataSource {
  final db.AppDatabase _database;

  CreditCardLocalDataSource(this._database);

  Future<List<CreditCardModel>> getCreditCardsByBudget(String budgetId) async {
    final rows = await (_database.select(_database.creditCards)
          ..where((t) => t.budgetId.equals(budgetId))
          ..where((t) => t.deletedAt.isNull()))
        .get();

    final result = <CreditCardModel>[];
    for (final row in rows) {
      result.add(await _enrichCard(row));
    }
    return result;
  }

  Future<List<CreditCardModel>> getAllActiveCreditCards() async {
    final rows = await (_database.select(_database.creditCards)
          ..where((t) => t.active.equals(true))
          ..where((t) => t.deletedAt.isNull()))
        .get();

    final result = <CreditCardModel>[];
    for (final row in rows) {
      result.add(await _enrichCard(row));
    }
    return result;
  }

  Future<CreditCardModel?> getCreditCardById(String id) async {
    final row = await (_database.select(_database.creditCards)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) return null;
    return _enrichCard(row);
  }

  Future<void> saveCreditCards(List<CreditCardModel> cards,
      {bool isSynced = true}) async {
    await _database.batch((batch) {
      for (final card in cards) {
        batch.insert(
          _database.creditCards,
          _toCompanion(card, isSynced: isSynced),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> saveCreditCard(CreditCardModel card,
      {bool isSynced = true}) async {
    await _database.into(_database.creditCards).insertOnConflictUpdate(
          _toCompanion(card, isSynced: isSynced),
        );
  }

  Future<void> softDelete(String id) async {
    await (_database.update(_database.creditCards)
          ..where((t) => t.id.equals(id)))
        .write(db.CreditCardsCompanion(
      deletedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));
  }

  Future<void> hardDelete(String id) async {
    await (_database.delete(_database.creditCards)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<CreditCardModel>> getUnsynced() async {
    final rows = await (_database.select(_database.creditCards)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    final result = <CreditCardModel>[];
    for (final row in rows) {
      result.add(await _enrichCard(row));
    }
    return result;
  }

  Future<void> markAsSynced(String id) async {
    await (_database.update(_database.creditCards)
          ..where((t) => t.id.equals(id)))
        .write(const db.CreditCardsCompanion(isSynced: Value(true)));
  }

  Future<void> clearByBudget(String budgetId) async {
    await (_database.delete(_database.creditCards)
          ..where((t) => t.budgetId.equals(budgetId)))
        .go();
  }

  Future<void> clearAll() async {
    await _database.delete(_database.creditCards).go();
  }

  // --- Private helpers ---

  Future<CreditCardModel> _enrichCard(db.CreditCard row) async {
    String? linkedAccountName;
    if (row.linkedAccountId != null) {
      final accountRow = await (_database.select(_database.accounts)
            ..where((t) => t.id.equals(row.linkedAccountId!)))
          .getSingleOrNull();
      linkedAccountName = accountRow?.name;
    }

    return CreditCardModel(
      id: row.id,
      budgetId: row.budgetId,
      name: row.name,
      issuer: row.issuer,
      lastFour: row.lastFour,
      currency: row.currency,
      statementCloseDay: row.statementCloseDay,
      dueDay: row.dueDay,
      linkedAccountId: row.linkedAccountId,
      linkedAccountName: linkedAccountName,
      active: row.active,
      createdAt: row.createdAt.toIso8601String(),
      updatedAt: row.updatedAt?.toIso8601String(),
      deletedAt: row.deletedAt?.toIso8601String(),
    );
  }

  db.CreditCardsCompanion _toCompanion(CreditCardModel model,
      {required bool isSynced}) {
    final createdAt = DateTime.tryParse(model.createdAt) ?? DateTime.now();
    final updatedAt =
        model.updatedAt != null ? DateTime.tryParse(model.updatedAt!) : null;
    final deletedAt =
        model.deletedAt != null ? DateTime.tryParse(model.deletedAt!) : null;

    return db.CreditCardsCompanion(
      id: Value(model.id),
      budgetId: Value(model.budgetId),
      name: Value(model.name),
      issuer: Value(model.issuer),
      lastFour: Value(model.lastFour),
      currency: Value(model.currency),
      statementCloseDay: Value(model.statementCloseDay),
      dueDay: Value(model.dueDay),
      linkedAccountId: Value(model.linkedAccountId),
      active: Value(model.active),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      isSynced: Value(isSynced),
    );
  }
}
