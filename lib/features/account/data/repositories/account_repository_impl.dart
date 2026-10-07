import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/base_repository_mixin.dart';
import '../../../../core/database/datasources/pending_sync_local_datasource.dart';
import '../../../../core/sync/connectivity_monitor.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_datasource.dart';
import '../datasources/account_remote_datasource.dart';
import '../models/account_model.dart';

class AccountRepositoryImpl
    with BaseRepositoryMixin
    implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;
  final AccountLocalDataSource localDataSource;
  final PendingSyncLocalDataSource pendingSyncDataSource;
  final ConnectivityMonitor connectivityMonitor;

  AccountRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.pendingSyncDataSource,
    required this.connectivityMonitor,
  });

  @override
  Future<Either<Failure, List<Account>>> getAccounts(String budgetId) async {
    try {
      final localModels = await localDataSource.getAccountsByBudget(budgetId);
      final localAccounts = localModels.map((m) => m.toEntity()).toList();

      if (connectivityMonitor.isOnline) {
        _backgroundRefreshAccounts(budgetId);
      }

      return Right(localAccounts);
    } catch (e) {
      return Left(
          CacheFailure('Failed to read local accounts: ${e.toString()}'));
    }
  }

  void _backgroundRefreshAccounts(String budgetId) async {
    try {
      final response = await remoteDataSource.getAccounts(budgetId, null);
      if (response.success && response.data != null) {
        await localDataSource.saveAccounts(response.data!);
      }
    } catch (_) {}
  }

  @override
  Future<Either<Failure, Account>> getAccountById(String id) async {
    try {
      final localModel = await localDataSource.getAccountById(id);
      if (localModel != null) {
        return Right(localModel.toEntity());
      }

      if (!connectivityMonitor.isOnline) {
        return const Left(CacheFailure('Account not found locally'));
      }

      final response = await remoteDataSource.getAccountById(id);
      if (response.success && response.data != null) {
        await localDataSource.saveAccount(response.data!);
        return Right(response.data!.toEntity());
      } else {
        return Left(
            ServerFailure(response.message ?? 'Account not found'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(CacheFailure('Failed to get account: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Account>> createAccount({
    required String budgetId,
    required String name,
    required AccountType type,
    String currency = 'BRL',
    double openingBalance = 0.0,
  }) async {
    try {
      final now = DateTime.now();
      final localId = const Uuid().v4();

      final localModel = AccountModel(
        id: localId,
        budgetId: budgetId,
        name: name,
        type: type,
        currency: currency,
        openingBalance: openingBalance,
        currentBalance: openingBalance,
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      await localDataSource.saveAccount(localModel, isSynced: false);

      final payload = jsonEncode({
        'budgetId': budgetId,
        'name': name,
        'type': _accountTypeToString(type),
        'currency': currency,
        'openingBalance': openingBalance,
      });

      await pendingSyncDataSource.addEntry(
        entityType: 'account',
        entityId: localId,
        operation: 'CREATE',
        payload: payload,
      );

      return Right(localModel.toEntity());
    } catch (e) {
      return Left(
          CacheFailure('Failed to create account locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Account>> updateAccount({
    required String id,
    required String name,
    required String currency,
  }) async {
    try {
      final existing = await localDataSource.getAccountById(id);
      if (existing == null) {
        return const Left(CacheFailure('Account not found locally'));
      }

      final updatedModel = AccountModel(
        id: existing.id,
        budgetId: existing.budgetId,
        name: name,
        type: existing.type,
        currency: currency,
        openingBalance: existing.openingBalance,
        currentBalance: existing.currentBalance,
        active: existing.active,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      await localDataSource.saveAccount(updatedModel, isSynced: false);

      final payload = jsonEncode({
        'name': name,
        'currency': currency,
      });

      await pendingSyncDataSource.addEntry(
        entityType: 'account',
        entityId: id,
        operation: 'UPDATE',
        payload: payload,
      );

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(
          CacheFailure('Failed to update account locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) async {
    try {
      await localDataSource.softDelete(id);

      await pendingSyncDataSource.addEntry(
        entityType: 'account',
        entityId: id,
        operation: 'DELETE',
        payload: jsonEncode({'id': id}),
      );

      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure('Failed to delete account locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> transfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? description,
  }) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Transfer requires an internet connection.'));
    }

    try {
      final body = {
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
        if (description != null) 'description': description,
      };

      await remoteDataSource.transfer(body);

      // Refresh local cache for both accounts
      _backgroundRefreshAccount(fromAccountId);
      _backgroundRefreshAccount(toAccountId);

      return const Right(null);
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleAccountStatus({
    required String id,
    required bool active,
  }) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Toggling account status requires an internet connection.'));
    }

    try {
      if (active) {
        await remoteDataSource.activateAccount(id);
      } else {
        await remoteDataSource.deactivateAccount(id);
      }

      _backgroundRefreshAccount(id);

      return const Right(null);
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  void _backgroundRefreshAccount(String id) async {
    try {
      final response = await remoteDataSource.getAccountById(id);
      if (response.success && response.data != null) {
        await localDataSource.saveAccount(response.data!);
      }
    } catch (_) {}
  }

  String _accountTypeToString(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return 'CASH';
      case AccountType.checking:
        return 'CHECKING';
      case AccountType.savings:
        return 'SAVINGS';
      case AccountType.creditCard:
        return 'CREDIT_CARD';
      case AccountType.investment:
        return 'INVESTMENT';
    }
  }
}
