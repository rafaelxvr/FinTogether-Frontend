import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/base_repository_mixin.dart';
import '../../../../core/database/datasources/pending_sync_local_datasource.dart';
import '../../../../core/sync/connectivity_monitor.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_goal_contribution.dart';
import '../../domain/repositories/savings_goal_repository.dart';
import '../datasources/savings_goal_local_datasource.dart';
import '../datasources/savings_goal_remote_datasource.dart';
import '../models/savings_goal_model.dart';

class SavingsGoalRepositoryImpl
    with BaseRepositoryMixin
    implements SavingsGoalRepository {
  final SavingsGoalRemoteDataSource remoteDataSource;
  final SavingsGoalLocalDataSource localDataSource;
  final PendingSyncLocalDataSource pendingSyncDataSource;
  final ConnectivityMonitor connectivityMonitor;

  SavingsGoalRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.pendingSyncDataSource,
    required this.connectivityMonitor,
  });

  @override
  Future<Either<Failure, List<SavingsGoal>>> getSavingsGoals(
      String budgetId) async {
    try {
      final localModels =
          await localDataSource.getSavingsGoalsByBudget(budgetId);
      final localGoals = localModels.map((m) => m.toEntity()).toList();

      if (connectivityMonitor.isOnline) {
        _backgroundRefreshGoals(budgetId);
      }

      return Right(localGoals);
    } catch (e) {
      return Left(
          CacheFailure('Failed to read local savings goals: ${e.toString()}'));
    }
  }

  void _backgroundRefreshGoals(String budgetId) async {
    try {
      final response = await remoteDataSource.getSavingsGoals(budgetId);
      if (response.success && response.data != null) {
        await localDataSource.saveSavingsGoals(response.data!);
      }
    } catch (_) {}
  }

  @override
  Future<Either<Failure, SavingsGoal>> getSavingsGoalById(String id) async {
    try {
      final localModel = await localDataSource.getSavingsGoalById(id);
      if (localModel != null) {
        return Right(localModel.toEntity());
      }

      if (!connectivityMonitor.isOnline) {
        return const Left(CacheFailure('Savings goal not found locally'));
      }

      final response = await remoteDataSource.getSavingsGoalById(id);
      if (response.success && response.data != null) {
        await localDataSource.saveSavingsGoal(response.data!);
        return Right(response.data!.toEntity());
      } else {
        return Left(
            ServerFailure(response.message ?? 'Savings goal not found'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
          CacheFailure('Failed to get savings goal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SavingsGoal>> createSavingsGoal({
    required String budgetId,
    required String name,
    String? description,
    required double targetAmount,
    String currency = 'BRL',
    DateTime? deadline,
    String? accountId,
    String? icon,
    String? color,
  }) async {
    try {
      final now = DateTime.now();
      final localId = const Uuid().v4();

      final localModel = SavingsGoalModel(
        id: localId,
        budgetId: budgetId,
        accountId: accountId,
        name: name,
        description: description,
        targetAmount: targetAmount,
        currentAmount: 0,
        currency: currency,
        deadline: deadline,
        icon: icon,
        color: color,
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      await localDataSource.saveSavingsGoal(localModel, isSynced: false);

      final payload = jsonEncode({
        'budgetId': budgetId,
        'name': name,
        if (description != null) 'description': description,
        'targetAmount': targetAmount,
        'currency': currency,
        if (deadline != null) 'deadline': deadline.toIso8601String(),
        if (accountId != null) 'accountId': accountId,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
      });

      await pendingSyncDataSource.addEntry(
        entityType: 'savings_goal',
        entityId: localId,
        operation: 'CREATE',
        payload: payload,
      );

      return Right(localModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(
          'Failed to create savings goal locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SavingsGoal>> updateSavingsGoal({
    required String id,
    required String name,
    String? description,
    double? targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
  }) async {
    try {
      final existing = await localDataSource.getSavingsGoalById(id);
      if (existing == null) {
        return const Left(CacheFailure('Savings goal not found locally'));
      }

      final updatedModel = SavingsGoalModel(
        id: existing.id,
        budgetId: existing.budgetId,
        accountId: existing.accountId,
        name: name,
        description: description ?? existing.description,
        targetAmount: targetAmount ?? existing.targetAmount,
        currentAmount: existing.currentAmount,
        currency: existing.currency,
        deadline: deadline ?? existing.deadline,
        icon: icon ?? existing.icon,
        color: color ?? existing.color,
        active: existing.active,
        completedAt: existing.completedAt,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      await localDataSource.saveSavingsGoal(updatedModel, isSynced: false);

      final payload = jsonEncode({
        'name': name,
        if (description != null) 'description': description,
        if (targetAmount != null) 'targetAmount': targetAmount,
        if (deadline != null) 'deadline': deadline.toIso8601String(),
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
      });

      await pendingSyncDataSource.addEntry(
        entityType: 'savings_goal',
        entityId: id,
        operation: 'UPDATE',
        payload: payload,
      );

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(
          'Failed to update savings goal locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSavingsGoal(String id) async {
    try {
      await localDataSource.softDelete(id);

      await pendingSyncDataSource.addEntry(
        entityType: 'savings_goal',
        entityId: id,
        operation: 'DELETE',
        payload: jsonEncode({'id': id}),
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(
          'Failed to delete savings goal locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SavingsGoal>> contribute({
    required String id,
    required double amount,
    String? note,
  }) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Contributing requires an internet connection.'));
    }

    try {
      final body = {
        'amount': amount,
        if (note != null) 'note': note,
      };

      final response = await remoteDataSource.contribute(id, body);
      if (response.success && response.data != null) {
        await localDataSource.saveSavingsGoal(response.data!);
        return Right(response.data!.toEntity());
      } else {
        return Left(
            ServerFailure(response.message ?? 'Failed to contribute'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SavingsGoal>> withdraw({
    required String id,
    required double amount,
    String? note,
  }) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Withdrawing requires an internet connection.'));
    }

    try {
      final body = {
        'amount': amount,
        if (note != null) 'note': note,
      };

      final response = await remoteDataSource.withdraw(id, body);
      if (response.success && response.data != null) {
        await localDataSource.saveSavingsGoal(response.data!);
        return Right(response.data!.toEntity());
      } else {
        return Left(
            ServerFailure(response.message ?? 'Failed to withdraw'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SavingsGoalContribution>>> getContributions(
      String savingsGoalId) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(NetworkFailure(
          'Loading contributions requires an internet connection.'));
    }

    try {
      final response =
          await remoteDataSource.getContributions(savingsGoalId);
      if (response.success && response.data != null) {
        return Right(response.data!.map((m) => m.toEntity()).toList());
      } else {
        return Left(ServerFailure(
            response.message ?? 'Failed to load contributions'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
