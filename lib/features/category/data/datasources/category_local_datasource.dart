import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/category.dart';
import '../models/category_model.dart';

class CategoryLocalDataSource {
  final db.AppDatabase _database;

  CategoryLocalDataSource(this._database);

  Future<List<CategoryModel>> getCategoriesByBudget(String budgetId) async {
    final rows = await (_database.select(_database.categories)
          ..where((t) => t.budgetId.equals(budgetId))
          ..where((t) => t.deletedAt.isNull()))
        .get();

    // Collect all parent ids for hasChildren computation
    final parentIds = rows
        .where((r) => r.parentId != null)
        .map((r) => r.parentId!)
        .toSet();

    return rows
        .map((row) => _mapToModel(row, hasChildren: parentIds.contains(row.id)))
        .toList();
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final row = await (_database.select(_database.categories)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) return null;

    final hasChildren = await _computeHasChildren(id);
    return _mapToModel(row, hasChildren: hasChildren);
  }

  Future<void> saveCategories(List<CategoryModel> categories,
      {bool isSynced = true}) async {
    await _database.batch((batch) {
      for (final category in categories) {
        batch.insert(
          _database.categories,
          _toCompanion(category, isSynced: isSynced),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> saveCategory(CategoryModel category,
      {bool isSynced = true}) async {
    await _database.into(_database.categories).insertOnConflictUpdate(
          _toCompanion(category, isSynced: isSynced),
        );
  }

  Future<void> softDelete(String id) async {
    await (_database.update(_database.categories)
          ..where((t) => t.id.equals(id)))
        .write(db.CategoriesCompanion(
      deletedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));
  }

  Future<void> hardDelete(String id) async {
    await (_database.delete(_database.categories)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<CategoryModel>> getUnsynced() async {
    final rows = await (_database.select(_database.categories)
          ..where((t) => t.isSynced.equals(false)))
        .get();

    final result = <CategoryModel>[];
    for (final row in rows) {
      final hasChildren = await _computeHasChildren(row.id);
      result.add(_mapToModel(row, hasChildren: hasChildren));
    }
    return result;
  }

  Future<void> markAsSynced(String id) async {
    await (_database.update(_database.categories)
          ..where((t) => t.id.equals(id)))
        .write(const db.CategoriesCompanion(isSynced: Value(true)));
  }

  Future<void> clearByBudget(String budgetId) async {
    await (_database.delete(_database.categories)
          ..where((t) => t.budgetId.equals(budgetId)))
        .go();
  }

  Future<void> clearAll() async {
    await _database.delete(_database.categories).go();
  }

  // --- Private helpers ---

  Future<bool> _computeHasChildren(String categoryId) async {
    final countExpr = _database.categories.id.count();
    final query = _database.selectOnly(_database.categories)
      ..addColumns([countExpr])
      ..where(_database.categories.parentId.equals(categoryId))
      ..where(_database.categories.deletedAt.isNull());
    final result = await query.getSingle();
    final count = result.read(countExpr) ?? 0;
    return count > 0;
  }

  CategoryModel _mapToModel(db.Category row, {required bool hasChildren}) {
    return CategoryModel(
      id: row.id,
      budgetId: row.budgetId,
      name: row.name,
      type: _parseCategoryType(row.type),
      parentId: row.parentId,
      icon: row.icon,
      color: row.color,
      limitAmount: row.limitAmount,
      archived: row.archived,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      hasChildren: hasChildren,
      deletedAt: row.deletedAt,
    );
  }

  db.CategoriesCompanion _toCompanion(CategoryModel model,
      {required bool isSynced}) {
    return db.CategoriesCompanion(
      id: Value(model.id),
      budgetId: Value(model.budgetId),
      name: Value(model.name),
      type: Value(model.type.name),
      parentId: Value(model.parentId),
      icon: Value(model.icon),
      color: Value(model.color),
      limitAmount: Value(model.limitAmount),
      archived: Value(model.archived),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      deletedAt: Value(model.deletedAt),
      isSynced: Value(isSynced),
    );
  }

  CategoryType _parseCategoryType(String value) {
    return CategoryType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CategoryType.expense,
    );
  }
}
