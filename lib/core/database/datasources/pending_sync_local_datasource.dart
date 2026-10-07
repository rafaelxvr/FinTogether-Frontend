import 'package:drift/drift.dart';
import '../app_database.dart';

class PendingSyncLocalDataSource {
  final AppDatabase _db;

  PendingSyncLocalDataSource(this._db);

  Future<void> addEntry({
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
  }) async {
    await _db.into(_db.pendingSyncs).insert(
          PendingSyncsCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
          ),
        );
  }

  Future<List<PendingSync>> getAllPending() async {
    return (_db.select(_db.pendingSyncs)
          ..where((t) => t.failed.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<List<PendingSync>> getEntriesByEntityType(String entityType) async {
    return (_db.select(_db.pendingSyncs)
          ..where((t) =>
              t.entityType.equals(entityType) & t.failed.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<List<PendingSync>> getFailedEntries() async {
    return (_db.select(_db.pendingSyncs)
          ..where((t) => t.failed.equals(true)))
        .get();
  }

  Future<void> incrementRetryCount(int id) async {
    final entry = await (_db.select(_db.pendingSyncs)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (entry != null) {
      final newCount = entry.retryCount + 1;
      await (_db.update(_db.pendingSyncs)..where((t) => t.id.equals(id)))
          .write(PendingSyncsCompanion(
        retryCount: Value(newCount),
        failed: Value(newCount >= 5),
      ));
    }
  }

  Future<void> markFailed(int id) async {
    await (_db.update(_db.pendingSyncs)..where((t) => t.id.equals(id)))
        .write(const PendingSyncsCompanion(failed: Value(true)));
  }

  Future<void> deleteEntry(int id) async {
    await (_db.delete(_db.pendingSyncs)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteByEntityId(String entityId) async {
    await (_db.delete(_db.pendingSyncs)
          ..where((t) => t.entityId.equals(entityId)))
        .go();
  }

  Future<void> clearAll() async {
    await _db.delete(_db.pendingSyncs).go();
  }

  Future<bool> hasPendingChanges() async {
    final count = await (_db.select(_db.pendingSyncs)
          ..where((t) => t.failed.equals(false)))
        .get();
    return count.isNotEmpty;
  }
}
