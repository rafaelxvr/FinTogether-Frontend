import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/archive_category_usecase.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_category_by_id_usecase.dart';
import '../../domain/usecases/get_root_categories_usecase.dart';
import '../../domain/usecases/unarchive_category_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';
import 'category_state.dart';

class CategoryNotifier extends StateNotifier<CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetRootCategoriesUseCase getRootCategoriesUseCase;
  final GetCategoryByIdUseCase getCategoryByIdUseCase;
  final CreateCategoryUseCase createCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final ArchiveCategoryUseCase archiveCategoryUseCase;
  final UnarchiveCategoryUseCase unarchiveCategoryUseCase;

  List<Category> _categories = [];

  CategoryNotifier({
    required this.getCategoriesUseCase,
    required this.getRootCategoriesUseCase,
    required this.getCategoryByIdUseCase,
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.archiveCategoryUseCase,
    required this.unarchiveCategoryUseCase,
  }) : super(CategoryInitial());

  Future<void> loadCategories({
    required String budgetId,
    CategoryType? type,
  }) async {
    state = CategoryLoading();
    final result = await getCategoriesUseCase(budgetId: budgetId, type: type);
    result.fold(
      (failure) => state = CategoryError(failure.message),
      (categories) {
        _categories = categories;
        state = CategoriesLoaded(categories);
      },
    );
  }

  Future<void> loadRootCategories(String budgetId) async {
    state = CategoryLoading();
    final result = await getRootCategoriesUseCase(budgetId);
    result.fold(
      (failure) => state = CategoryError(failure.message),
      (categories) {
        _categories = categories;
        state = CategoriesLoaded(categories);
      },
    );
  }

  Future<void> getCategoryById(String id) async {
    state = CategoryLoading();
    final result = await getCategoryByIdUseCase(id);
    result.fold(
      (failure) => state = CategoryError(failure.message),
      (category) => state = CategoryLoaded(category),
    );
  }

  Future<void> createCategory({
    required String budgetId,
    required String name,
    required CategoryType type,
    String? parentId,
    String? icon,
    String? color,
    double? limitAmount,
  }) async {
    state = CategoryLoading();
    final result = await createCategoryUseCase(
      budgetId: budgetId,
      name: name,
      type: type,
      parentId: parentId,
      icon: icon,
      color: color,
      limitAmount: limitAmount,
    );
    result.fold(
      (failure) => state = CategoryError(failure.message),
      (category) {
        _categories = [..._categories, category];
        state = CategoryCreated(category);
        // Auto-reload to get fresh data
        loadCategories(budgetId: budgetId);
      },
    );
  }

  Future<void> updateCategory({
    required String budgetId,
    required String id,
    required String name,
    String? icon,
    String? color,
    double? limitAmount,
    String? parentId,
  }) async {
    state = CategoryLoading();
    final result = await updateCategoryUseCase(
      id: id,
      name: name,
      icon: icon,
      color: color,
      limitAmount: limitAmount,
      parentId: parentId,
    );
    result.fold(
      (failure) => state = CategoryError(failure.message),
      (category) {
        _categories = _categories
            .map((c) => c.id == category.id ? category : c)
            .toList();
        state = CategoryUpdated(category);
        // Auto-reload to get fresh data
        loadCategories(budgetId: budgetId);
      },
    );
  }

  Future<void> deleteCategory({
    required String budgetId,
    required String id,
  }) async {
    state = CategoryLoading();
    final result = await deleteCategoryUseCase(id);
    result.fold(
      (failure) => state = CategoryError(failure.message),
      (_) {
        _categories = _categories.where((c) => c.id != id).toList();
        state = CategoryDeleted();
        // Auto-reload to get fresh data
        loadCategories(budgetId: budgetId);
      },
    );
  }

  Future<void> archiveCategory({
    required String budgetId,
    required String id,
  }) async {
    state = CategoryLoading();
    final result = await archiveCategoryUseCase(id);
    result.fold(
      (failure) => state = CategoryError(failure.message),
      (category) {
        _categories = _categories
            .map((c) => c.id == category.id ? category : c)
            .toList();
        state = CategoryArchived(category);
        // Auto-reload to get fresh data
        loadCategories(budgetId: budgetId);
      },
    );
  }

  Future<void> unarchiveCategory({
    required String budgetId,
    required String id,
  }) async {
    state = CategoryLoading();
    final result = await unarchiveCategoryUseCase(id);
    result.fold(
      (failure) => state = CategoryError(failure.message),
      (category) {
        _categories = _categories
            .map((c) => c.id == category.id ? category : c)
            .toList();
        state = CategoryUnarchived(category);
        // Auto-reload to get fresh data
        loadCategories(budgetId: budgetId);
      },
    );
  }

  List<Category> get categories => _categories;
  List<Category> get activeCategories =>
      _categories.where((c) => !c.archived).toList();
  List<Category> get archivedCategories =>
      _categories.where((c) => c.archived).toList();
  List<Category> get rootCategories =>
      _categories.where((c) => c.parentId == null).toList();

  List<Category> getSubcategories(String parentId) =>
      _categories.where((c) => c.parentId == parentId).toList();

  List<Category> getCategoriesByType(CategoryType type) =>
      _categories.where((c) => c.type == type).toList();
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>(
  (ref) => CategoryNotifier(
    getCategoriesUseCase: getIt<GetCategoriesUseCase>(),
    getRootCategoriesUseCase: getIt<GetRootCategoriesUseCase>(),
    getCategoryByIdUseCase: getIt<GetCategoryByIdUseCase>(),
    createCategoryUseCase: getIt<CreateCategoryUseCase>(),
    updateCategoryUseCase: getIt<UpdateCategoryUseCase>(),
    deleteCategoryUseCase: getIt<DeleteCategoryUseCase>(),
    archiveCategoryUseCase: getIt<ArchiveCategoryUseCase>(),
    unarchiveCategoryUseCase: getIt<UnarchiveCategoryUseCase>(),
  ),
);
