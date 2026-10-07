import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../models/user_model.dart';

class UserLocalDataSource {
  final db.AppDatabase _database;

  UserLocalDataSource(this._database);

  Future<UserModel?> getUser() async {
    final row = await (_database.select(_database.users)
          ..where((t) => t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row != null ? _mapToModel(row) : null;
  }

  Future<UserModel?> getUserById(String id) async {
    final row = await (_database.select(_database.users)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    return row != null ? _mapToModel(row) : null;
  }

  Future<void> saveUser(UserModel user, {bool isSynced = true}) async {
    await _database.into(_database.users).insertOnConflictUpdate(
          _toCompanion(user, isSynced: isSynced),
        );
  }

  Future<void> saveUsers(List<UserModel> users, {bool isSynced = true}) async {
    await _database.batch((batch) {
      for (final user in users) {
        batch.insert(
          _database.users,
          _toCompanion(user, isSynced: isSynced),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> softDelete(String id) async {
    await (_database.update(_database.users)..where((t) => t.id.equals(id)))
        .write(db.UsersCompanion(
      deletedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));
  }

  Future<void> hardDelete(String id) async {
    await (_database.delete(_database.users)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<UserModel>> getUnsynced() async {
    final rows = await (_database.select(_database.users)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    return rows.map(_mapToModel).toList();
  }

  Future<void> markAsSynced(String id) async {
    await (_database.update(_database.users)..where((t) => t.id.equals(id)))
        .write(const db.UsersCompanion(isSynced: Value(true)));
  }

  Future<void> clearAll() async {
    await _database.delete(_database.users).go();
  }

  // --- Mapping helpers ---

  UserModel _mapToModel(db.User row) {
    return UserModel(
      id: row.id,
      email: row.email,
      name: row.name,
      locale: row.locale,
      deletedAt: row.deletedAt,
    );
  }

  db.UsersCompanion _toCompanion(UserModel model, {required bool isSynced}) {
    return db.UsersCompanion(
      id: Value(model.id),
      email: Value(model.email),
      name: Value(model.name),
      locale: Value(model.locale),
      deletedAt: Value(model.deletedAt),
      isSynced: Value(isSynced),
    );
  }
}
