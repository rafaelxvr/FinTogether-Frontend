import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/base_repository_mixin.dart';
import '../../../../core/database/datasources/pending_sync_local_datasource.dart';
import '../../../../core/sync/connectivity_monitor.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_member.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../datasources/budget_member_local_datasource.dart';
import '../datasources/budget_remote_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl
    with BaseRepositoryMixin
    implements BudgetRepository {
  final BudgetRemoteDataSource remoteDataSource;
  final BudgetLocalDataSource localDataSource;
  final BudgetMemberLocalDataSource budgetMemberLocalDataSource;
  final PendingSyncLocalDataSource pendingSyncDataSource;
  final ConnectivityMonitor connectivityMonitor;

  BudgetRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.budgetMemberLocalDataSource,
    required this.pendingSyncDataSource,
    required this.connectivityMonitor,
  });

  @override
  Future<Either<Failure, List<Budget>>> getBudgets() async {
    // When online, fetch from backend first to ensure fresh data
    if (connectivityMonitor.isOnline) {
      try {
        final response = await remoteDataSource.getBudgets(null);
        if (response.success && response.data != null) {
          await localDataSource.saveBudgets(response.data!);
          final budgets = response.data!.map((m) => m.toEntity()).toList();
          return Right(budgets);
        }
      } on DioException catch (e) {
        // Fall through to local cache on network error
        return _getLocalBudgets(networkError: handleDioError(e));
      } catch (_) {
        // Fall through to local cache
      }
    }

    return _getLocalBudgets();
  }

  Future<Either<Failure, List<Budget>>> _getLocalBudgets({Failure? networkError}) async {
    try {
      final localModels = await localDataSource.getBudgets();
      final localBudgets = localModels.map((m) => m.toEntity()).toList();
      if (localBudgets.isEmpty && networkError != null) {
        return Left(networkError);
      }
      return Right(localBudgets);
    } catch (e) {
      if (networkError != null) return Left(networkError);
      return Left(
          CacheFailure('Failed to read local budgets: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Budget>> getBudgetById(String id) async {
    try {
      final localModel = await localDataSource.getBudgetById(id);
      if (localModel != null) {
        return Right(localModel.toEntity());
      }

      if (!connectivityMonitor.isOnline) {
        return const Left(CacheFailure('Budget not found locally'));
      }

      final response = await remoteDataSource.getBudgetById(id);
      if (response.success && response.data != null) {
        await localDataSource.saveBudget(response.data!);
        return Right(response.data!.toEntity());
      } else {
        return Left(
            ServerFailure(response.message ?? 'Budget not found'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(CacheFailure('Failed to get budget: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Budget>> createBudget({
    required String name,
    required BudgetType type,
  }) async {
    final body = {
      'name': name,
      'type': type.name.toUpperCase(),
    };

    // When online, create on backend directly
    if (connectivityMonitor.isOnline) {
      try {
        final response = await remoteDataSource.createBudget(body);
        if (response.success && response.data != null) {
          await localDataSource.saveBudget(response.data!);
          return Right(response.data!.toEntity());
        }
        return Left(
            ServerFailure(response.message ?? 'Failed to create budget'));
      } on DioException catch (e) {
        return Left(handleDioError(e));
      }
    }

    // Offline: create locally and queue for sync
    try {
      final now = DateTime.now();
      final localId = const Uuid().v4();

      final localModel = BudgetModel(
        id: localId,
        name: name,
        type: type,
        ownerId: '',
        ownerName: '',
        memberCount: 1,
        createdAt: now,
        updatedAt: now,
      );

      await localDataSource.saveBudget(localModel, isSynced: false);

      await pendingSyncDataSource.addEntry(
        entityType: 'budget',
        entityId: localId,
        operation: 'CREATE',
        payload: jsonEncode(body),
      );

      return Right(localModel.toEntity());
    } catch (e) {
      return Left(
          CacheFailure('Failed to create budget locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Budget>> updateBudget({
    required String id,
    required String name,
    required BudgetType type,
  }) async {
    final body = {
      'name': name,
      'type': type.name.toUpperCase(),
    };

    // When online, update on backend directly
    if (connectivityMonitor.isOnline) {
      try {
        final response = await remoteDataSource.updateBudget(id, body);
        if (response.success && response.data != null) {
          await localDataSource.saveBudget(response.data!);
          return Right(response.data!.toEntity());
        }
        return Left(
            ServerFailure(response.message ?? 'Failed to update budget'));
      } on DioException catch (e) {
        return Left(handleDioError(e));
      }
    }

    // Offline: update locally and queue for sync
    try {
      final existing = await localDataSource.getBudgetById(id);
      if (existing == null) {
        return const Left(CacheFailure('Budget not found locally'));
      }

      final updatedModel = BudgetModel(
        id: existing.id,
        name: name,
        type: type,
        ownerId: existing.ownerId,
        ownerName: existing.ownerName,
        memberCount: existing.memberCount,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      await localDataSource.saveBudget(updatedModel, isSynced: false);

      await pendingSyncDataSource.addEntry(
        entityType: 'budget',
        entityId: id,
        operation: 'UPDATE',
        payload: jsonEncode(body),
      );

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(
          CacheFailure('Failed to update budget locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    // When online, delete on backend directly
    if (connectivityMonitor.isOnline) {
      try {
        await remoteDataSource.deleteBudget(id);
        await localDataSource.softDelete(id);
        return const Right(null);
      } on DioException catch (e) {
        return Left(handleDioError(e));
      }
    }

    // Offline: soft-delete locally and queue for sync
    try {
      await localDataSource.softDelete(id);

      await pendingSyncDataSource.addEntry(
        entityType: 'budget',
        entityId: id,
        operation: 'DELETE',
        payload: jsonEncode({'id': id}),
      );

      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure('Failed to delete budget locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BudgetMember>>> getBudgetMembers(
      String budgetId) async {
    try {
      final localModels =
          await budgetMemberLocalDataSource.getMembers(budgetId);
      final localMembers = localModels.map((m) => m.toEntity()).toList();

      if (connectivityMonitor.isOnline) {
        _backgroundRefreshBudgetMembers(budgetId);
      }

      return Right(localMembers);
    } catch (e) {
      return Left(
          CacheFailure('Failed to read local budget members: ${e.toString()}'));
    }
  }

  void _backgroundRefreshBudgetMembers(String budgetId) async {
    try {
      final response = await remoteDataSource.getBudgetMembers(budgetId);
      if (response.success && response.data != null) {
        await budgetMemberLocalDataSource.saveMembers(response.data!);
      }
    } catch (_) {}
  }

  @override
  Future<Either<Failure, BudgetMember>> addBudgetMember({
    required String budgetId,
    required String email,
    required BudgetMemberRole role,
  }) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Adding members requires an internet connection'));
    }

    try {
      final body = {
        'email': email,
        'role': role.name.toUpperCase(),
      };

      final response = await remoteDataSource.addBudgetMember(budgetId, body);
      if (response.success && response.data != null) {
        await budgetMemberLocalDataSource.saveMember(response.data!);
        return Right(response.data!.toEntity());
      } else {
        return Left(
            ServerFailure(response.message ?? 'Failed to add budget member'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeBudgetMember({
    required String budgetId,
    required String memberId,
  }) async {
    try {
      await budgetMemberLocalDataSource.softDelete(memberId);

      await pendingSyncDataSource.addEntry(
        entityType: 'budget_member',
        entityId: memberId,
        operation: 'DELETE',
        payload: jsonEncode({
          'budgetId': budgetId,
          'memberId': memberId,
        }),
      );

      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure('Failed to remove budget member locally: ${e.toString()}'));
    }
  }
}
