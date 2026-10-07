import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/base_repository_mixin.dart';
import '../../../../core/database/datasources/pending_sync_local_datasource.dart';
import '../../../../core/sync/connectivity_monitor.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_search_params.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl
    with BaseRepositoryMixin
    implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;
  final TransactionSearchRemoteDataSource searchRemoteDataSource;
  final TransactionLocalDataSource localDataSource;
  final PendingSyncLocalDataSource pendingSyncDataSource;
  final ConnectivityMonitor connectivityMonitor;

  TransactionRepositoryImpl({
    required this.remoteDataSource,
    required this.searchRemoteDataSource,
    required this.localDataSource,
    required this.pendingSyncDataSource,
    required this.connectivityMonitor,
  });

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String budgetId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final localModels =
          await localDataSource.getTransactionsByBudget(budgetId);
      final localTransactions =
          localModels.map((m) => m.toEntity()).toList();

      if (connectivityMonitor.isOnline) {
        _backgroundRefreshTransactions(budgetId, startDate, endDate);
      }

      return Right(localTransactions);
    } catch (e) {
      return Left(
          CacheFailure('Failed to read local transactions: ${e.toString()}'));
    }
  }

  void _backgroundRefreshTransactions(
    String budgetId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      final startDateStr = startDate?.toIso8601String().split('T')[0];
      final endDateStr = endDate?.toIso8601String().split('T')[0];

      final response = await remoteDataSource.getTransactions(
        budgetId,
        startDateStr,
        endDateStr,
        null,
      );
      if (response.success && response.data != null) {
        await localDataSource.saveTransactions(response.data!);
      }
    } catch (_) {}
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    try {
      final localModel = await localDataSource.getTransactionById(id);
      if (localModel != null) {
        return Right(localModel.toEntity());
      }

      if (!connectivityMonitor.isOnline) {
        return const Left(CacheFailure('Transaction not found locally'));
      }

      final response = await remoteDataSource.getTransactionById(id);
      if (response.success && response.data != null) {
        await localDataSource.saveTransaction(response.data!);
        return Right(response.data!.toEntity());
      } else {
        return Left(
            ServerFailure(response.message ?? 'Transaction not found'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
          CacheFailure('Failed to get transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> createTransaction({
    required String budgetId,
    required DateTime transactionDate,
    required double amount,
    required TransactionType type,
    String? accountId,
    String? categoryId,
    String? description,
    String? notes,
    List<String>? tags,
    TransactionVisibility visibility = TransactionVisibility.shared,
  }) async {
    try {
      final now = DateTime.now();
      final localId = const Uuid().v4();

      final localModel = TransactionModel(
        id: localId,
        budgetId: budgetId,
        transactionDate: transactionDate,
        amount: amount,
        type: type,
        accountId: accountId,
        categoryId: categoryId,
        description: description,
        notes: notes,
        tags: tags,
        visibility: visibility,
        isRecurring: false,
        isInstallment: false,
        createdAt: now,
        updatedAt: now,
      );

      await localDataSource.saveTransaction(localModel, isSynced: false);

      final payload = jsonEncode({
        'budgetId': budgetId,
        'transactionDate': transactionDate.toIso8601String().split('T')[0],
        'amount': amount,
        'type': _transactionTypeToString(type),
        if (accountId != null) 'accountId': accountId,
        if (categoryId != null) 'categoryId': categoryId,
        if (description != null) 'description': description,
        if (notes != null) 'notes': notes,
        if (tags != null) 'tags': tags,
        'visibility': _visibilityToString(visibility),
      });

      await pendingSyncDataSource.addEntry(
        entityType: 'transaction',
        entityId: localId,
        operation: 'CREATE',
        payload: payload,
      );

      return Right(localModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(
          'Failed to create transaction locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction({
    required String id,
    required DateTime transactionDate,
    required double amount,
    String? description,
    String? notes,
    List<String>? tags,
    String? categoryId,
    TransactionVisibility? visibility,
  }) async {
    try {
      final existing = await localDataSource.getTransactionById(id);
      if (existing == null) {
        return const Left(CacheFailure('Transaction not found locally'));
      }

      final updatedModel = TransactionModel(
        id: existing.id,
        budgetId: existing.budgetId,
        userId: existing.userId,
        transactionDate: transactionDate,
        amount: amount,
        type: existing.type,
        accountId: existing.accountId,
        categoryId: categoryId ?? existing.categoryId,
        cardId: existing.cardId,
        description: description ?? existing.description,
        notes: notes ?? existing.notes,
        tags: tags ?? existing.tags,
        visibility: visibility ?? existing.visibility,
        isRecurring: existing.isRecurring,
        recurrenceRule: existing.recurrenceRule,
        isInstallment: existing.isInstallment,
        installmentGroupId: existing.installmentGroupId,
        installmentNumber: existing.installmentNumber,
        syncedAt: existing.syncedAt,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      await localDataSource.saveTransaction(updatedModel, isSynced: false);

      final payload = jsonEncode({
        'transactionDate': transactionDate.toIso8601String().split('T')[0],
        'amount': amount,
        if (description != null) 'description': description,
        if (notes != null) 'notes': notes,
        if (tags != null) 'tags': tags,
        if (categoryId != null) 'categoryId': categoryId,
        if (visibility != null) 'visibility': _visibilityToString(visibility),
      });

      await pendingSyncDataSource.addEntry(
        entityType: 'transaction',
        entityId: id,
        operation: 'UPDATE',
        payload: payload,
      );

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(
          'Failed to update transaction locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await localDataSource.softDelete(id);

      await pendingSyncDataSource.addEntry(
        entityType: 'transaction',
        entityId: id,
        operation: 'DELETE',
        payload: jsonEncode({'id': id}),
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(
          'Failed to delete transaction locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> searchTransactions({
    required String budgetId,
    required TransactionSearchParams params,
  }) async {
    try {
      if (connectivityMonitor.isOnline) {
        final results =
            await searchRemoteDataSource.searchTransactions(budgetId, params);
        return Right(results.map((m) => m.toEntity()).toList());
      } else {
        final results =
            await localDataSource.searchTransactions(budgetId, params);
        return Right(results.map((m) => m.toEntity()).toList());
      }
    } on DioException catch (e) {
      // Fallback to local on network error
      try {
        final results =
            await localDataSource.searchTransactions(budgetId, params);
        return Right(results.map((m) => m.toEntity()).toList());
      } catch (_) {
        return Left(handleDioError(e));
      }
    } catch (e) {
      // Fallback to local on any error
      try {
        final results =
            await localDataSource.searchTransactions(budgetId, params);
        return Right(results.map((m) => m.toEntity()).toList());
      } catch (_) {
        return Left(ServerFailure(e.toString()));
      }
    }
  }

  String _transactionTypeToString(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'INCOME';
      case TransactionType.expense:
        return 'EXPENSE';
      case TransactionType.transfer:
        return 'TRANSFER';
    }
  }

  String _visibilityToString(TransactionVisibility visibility) {
    switch (visibility) {
      case TransactionVisibility.private:
        return 'PRIVATE';
      case TransactionVisibility.shared:
        return 'SHARED';
    }
  }
}
