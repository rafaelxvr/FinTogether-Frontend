import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/base_repository_mixin.dart';
import '../../../../core/database/datasources/pending_sync_local_datasource.dart';
import '../../../../core/sync/connectivity_monitor.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl
    with BaseRepositoryMixin
    implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;
  final CategoryLocalDataSource localDataSource;
  final PendingSyncLocalDataSource pendingSyncDataSource;
  final ConnectivityMonitor connectivityMonitor;

  CategoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.pendingSyncDataSource,
    required this.connectivityMonitor,
  });

  @override
  Future<Either<Failure, List<Category>>> getCategories({
    required String budgetId,
    CategoryType? type,
  }) async {
    try {
      final localModels =
          await localDataSource.getCategoriesByBudget(budgetId);
      final filtered = type != null
          ? localModels.where((m) => m.type == type).toList()
          : localModels;
      final localCategories = filtered.map((m) => m.toEntity()).toList();

      if (connectivityMonitor.isOnline) {
        _backgroundRefreshCategories(budgetId, type);
      }

      return Right(localCategories);
    } catch (e) {
      return Left(
          CacheFailure('Failed to read local categories: ${e.toString()}'));
    }
  }

  void _backgroundRefreshCategories(
      String budgetId, CategoryType? type) async {
    try {
      final typeString = type != null ? _categoryTypeToString(type) : null;
      final response =
          await remoteDataSource.getCategories(budgetId, typeString, null);
      if (response.success && response.data != null) {
        await localDataSource.saveCategories(response.data!);
      }
    } catch (_) {}
  }

  @override
  Future<Either<Failure, List<Category>>> getRootCategories(
      String budgetId) async {
    try {
      final localModels =
          await localDataSource.getCategoriesByBudget(budgetId);
      final rootModels =
          localModels.where((m) => m.parentId == null).toList();
      final rootCategories = rootModels.map((m) => m.toEntity()).toList();

      if (connectivityMonitor.isOnline) {
        _backgroundRefreshRootCategories(budgetId);
      }

      return Right(rootCategories);
    } catch (e) {
      return Left(
          CacheFailure('Failed to read local root categories: ${e.toString()}'));
    }
  }

  void _backgroundRefreshRootCategories(String budgetId) async {
    try {
      final response = await remoteDataSource.getRootCategories(budgetId);
      if (response.success && response.data != null) {
        await localDataSource.saveCategories(response.data!);
      }
    } catch (_) {}
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(String id) async {
    try {
      final localModel = await localDataSource.getCategoryById(id);
      if (localModel != null) {
        return Right(localModel.toEntity());
      }

      if (!connectivityMonitor.isOnline) {
        return const Left(CacheFailure('Category not found locally'));
      }

      final response = await remoteDataSource.getCategoryById(id);
      if (response.success && response.data != null) {
        await localDataSource.saveCategory(response.data!);
        return Right(response.data!.toEntity());
      } else {
        return Left(
            ServerFailure(response.message ?? 'Category not found'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
          CacheFailure('Failed to get category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory({
    required String budgetId,
    required String name,
    required CategoryType type,
    String? parentId,
    String? icon,
    String? color,
    double? limitAmount,
  }) async {
    try {
      final now = DateTime.now();
      final localId = const Uuid().v4();

      final localModel = CategoryModel(
        id: localId,
        budgetId: budgetId,
        name: name,
        type: type,
        parentId: parentId,
        icon: icon,
        color: color,
        limitAmount: limitAmount,
        archived: false,
        createdAt: now,
        updatedAt: now,
        hasChildren: false,
      );

      await localDataSource.saveCategory(localModel, isSynced: false);

      final payload = jsonEncode({
        'name': name,
        'type': _categoryTypeToString(type),
        if (parentId != null) 'parentId': parentId,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        if (limitAmount != null) 'limitAmount': limitAmount,
      });

      await pendingSyncDataSource.addEntry(
        entityType: 'category',
        entityId: localId,
        operation: 'CREATE',
        payload: payload,
      );

      return Right(localModel.toEntity());
    } catch (e) {
      return Left(
          CacheFailure('Failed to create category locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory({
    required String id,
    required String name,
    String? icon,
    String? color,
    double? limitAmount,
    String? parentId,
  }) async {
    try {
      final existing = await localDataSource.getCategoryById(id);
      if (existing == null) {
        return const Left(CacheFailure('Category not found locally'));
      }

      final updatedModel = CategoryModel(
        id: existing.id,
        budgetId: existing.budgetId,
        name: name,
        type: existing.type,
        parentId: parentId ?? existing.parentId,
        icon: icon ?? existing.icon,
        color: color ?? existing.color,
        limitAmount: limitAmount ?? existing.limitAmount,
        archived: existing.archived,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        hasChildren: existing.hasChildren,
      );

      await localDataSource.saveCategory(updatedModel, isSynced: false);

      final payload = jsonEncode({
        'name': name,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        if (limitAmount != null) 'limitAmount': limitAmount,
        if (parentId != null) 'parentId': parentId,
      });

      await pendingSyncDataSource.addEntry(
        entityType: 'category',
        entityId: id,
        operation: 'UPDATE',
        payload: payload,
      );

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(
          CacheFailure('Failed to update category locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await localDataSource.softDelete(id);

      await pendingSyncDataSource.addEntry(
        entityType: 'category',
        entityId: id,
        operation: 'DELETE',
        payload: jsonEncode({'id': id}),
      );

      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure('Failed to delete category locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Category>> archiveCategory(String id) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Archiving a category requires an internet connection.'));
    }

    try {
      final response = await remoteDataSource.archiveCategory(id);
      if (response.success && response.data != null) {
        await localDataSource.saveCategory(response.data!);
        return Right(response.data!.toEntity());
      } else {
        return Left(
            ServerFailure(response.message ?? 'Failed to archive category'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> unarchiveCategory(String id) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Unarchiving a category requires an internet connection.'));
    }

    try {
      final response = await remoteDataSource.unarchiveCategory(id);
      if (response.success && response.data != null) {
        await localDataSource.saveCategory(response.data!);
        return Right(response.data!.toEntity());
      } else {
        return Left(
            ServerFailure(response.message ?? 'Failed to unarchive category'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _categoryTypeToString(CategoryType type) {
    switch (type) {
      case CategoryType.income:
        return 'INCOME';
      case CategoryType.expense:
        return 'EXPENSE';
      case CategoryType.transfer:
        return 'TRANSFER';
    }
  }
}
