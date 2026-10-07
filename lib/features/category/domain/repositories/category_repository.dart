import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  /// Get all categories for a budget
  Future<Either<Failure, List<Category>>> getCategories({
    required String budgetId,
    CategoryType? type,
  });

  /// Get root categories (without parent)
  Future<Either<Failure, List<Category>>> getRootCategories(String budgetId);

  /// Get category by ID
  Future<Either<Failure, Category>> getCategoryById(String id);

  /// Create new category
  Future<Either<Failure, Category>> createCategory({
    required String budgetId,
    required String name,
    required CategoryType type,
    String? parentId,
    String? icon,
    String? color,
    double? limitAmount,
  });

  /// Update existing category
  Future<Either<Failure, Category>> updateCategory({
    required String id,
    required String name,
    String? icon,
    String? color,
    double? limitAmount,
    String? parentId,
  });

  /// Delete category
  Future<Either<Failure, void>> deleteCategory(String id);

  /// Archive category
  Future<Either<Failure, Category>> archiveCategory(String id);

  /// Unarchive category
  Future<Either<Failure, Category>> unarchiveCategory(String id);
}
