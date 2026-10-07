import 'package:drift/drift.dart';
import '../app_database.dart';

/// Manages the SyncLogs table -- stores last successful sync timestamp
/// per entity type for incremental pull.
class SyncLogLocalDataSource {
  final AppDatabase _db;

  SyncLogLocalDataSource(this._db);

  /// Get the last sync timestamp for a given entity type.
  /// Returns null if no sync has ever completed for this type.
  Future<DateTime?> getLastSyncedAt(String entityType) async {
    final row = await (_db.select(_db.syncLogs)
          ..where((t) => t.entityType.equals(entityType)))
        .getSingleOrNull();
    return row?.lastSyncedAt;
  }

  /// Update or insert the last sync timestamp for a given entity type.
  Future<void> upsertLastSyncedAt(
      String entityType, DateTime timestamp) async {
    await _db.into(_db.syncLogs).insertOnConflictUpdate(
          SyncLogsCompanion(
            entityType: Value(entityType),
            lastSyncedAt: Value(timestamp),
          ),
        );
  }

  /// Get all sync log entries (for debugging / UI display).
  Future<List<SyncLog>> getAll() async {
    return _db.select(_db.syncLogs).get();
  }

  /// Clear all sync log entries (used during full reset / logout).
  Future<void> clearAll() async {
    await _db.delete(_db.syncLogs).go();
  }
}
