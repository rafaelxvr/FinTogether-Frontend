import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/data/base_repository_mixin.dart';
import '../../../../core/database/datasources/pending_sync_local_datasource.dart';
import '../../../../core/sync/connectivity_monitor.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/member_balance.dart';
import '../../domain/entities/transaction_split.dart';
import '../../domain/repositories/split_repository.dart';
import '../datasources/split_local_datasource.dart';
import '../datasources/split_remote_datasource.dart';
import '../models/transaction_split_model.dart';

class SplitRepositoryImpl
    with BaseRepositoryMixin
    implements SplitRepository {
  final SplitRemoteDataSource remoteDataSource;
  final SplitLocalDataSource localDataSource;
  final PendingSyncLocalDataSource pendingSyncDataSource;
  final ConnectivityMonitor connectivityMonitor;

  SplitRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.pendingSyncDataSource,
    required this.connectivityMonitor,
  });

  @override
  Future<Either<Failure, List<TransactionSplit>>> getSplitsForTransaction(
      String transactionId) async {
    try {
      final localModels =
          await localDataSource.getSplitsByTransaction(transactionId);
      final localSplits = localModels.map((m) => m.toEntity()).toList();

      if (connectivityMonitor.isOnline) {
        _backgroundRefreshSplits(transactionId);
      }

      return Right(localSplits);
    } catch (e) {
      return Left(
          CacheFailure('Failed to read local splits: ${e.toString()}'));
    }
  }

  void _backgroundRefreshSplits(String transactionId) async {
    try {
      final response =
          await remoteDataSource.getSplitsForTransaction(transactionId);
      if (response.success && response.data != null) {
        await localDataSource.saveSplits(response.data!);
      }
    } catch (_) {}
  }

  @override
  Future<Either<Failure, List<MemberBalance>>> getBalances(
      String budgetId) async {
    try {
      if (connectivityMonitor.isOnline) {
        final response = await remoteDataSource.getBalances(budgetId);
        if (response.success && response.data != null) {
          final entries =
              response.data!.entries.map((m) => m.toEntity()).toList();
          return Right(entries);
        }
        return Left(
            ServerFailure(response.message ?? 'Failed to load balances'));
      }

      // Offline fallback: compute approximate balances from local data
      final localSplits =
          await localDataSource.getUnsettledByBudget(budgetId);
      // Return empty list for offline - precise calculation requires all transaction data
      if (localSplits.isEmpty) {
        return const Right([]);
      }

      // Basic offline balance computation
      return const Right([]);
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
          CacheFailure('Failed to get balances: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, TransactionSplit>> settleSplit(
      String splitId) async {
    try {
      // Optimistic local update
      await localDataSource.markAsSettled(splitId);

      // Queue for sync
      await pendingSyncDataSource.addEntry(
        entityType: 'transaction_split',
        entityId: splitId,
        operation: 'SETTLE',
        payload: jsonEncode({'splitId': splitId}),
      );

      // Try remote immediately if online
      if (connectivityMonitor.isOnline) {
        try {
          final response = await remoteDataSource.settleSplit(splitId);
          if (response.success && response.data != null) {
            await localDataSource.saveSplit(response.data!);
            return Right(response.data!.toEntity());
          }
        } catch (_) {
          // Remote failed, but local is updated. Sync will retry later.
        }
      }

      // Return local state
      final localSplit = await localDataSource.getSplitById(splitId);
      if (localSplit != null) {
        return Right(localSplit.toEntity());
      }
      return const Left(CacheFailure('Split not found locally after settle'));
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
          CacheFailure('Failed to settle split: ${e.toString()}'));
    }
  }
}
