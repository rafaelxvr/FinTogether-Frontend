import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/base_repository_mixin.dart';
import '../../../../core/database/datasources/pending_sync_local_datasource.dart';
import '../../../../core/sync/connectivity_monitor.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/merchant.dart';
import '../../domain/entities/merchant_analytics.dart';
import '../../domain/repositories/merchant_repository.dart';
import '../datasources/merchant_local_datasource.dart';
import '../datasources/merchant_remote_datasource.dart';
import '../models/merchant_model.dart';

class MerchantRepositoryImpl
    with BaseRepositoryMixin
    implements MerchantRepository {
  final MerchantRemoteDataSource remoteDataSource;
  final MerchantLocalDataSource localDataSource;
  final PendingSyncLocalDataSource pendingSyncDataSource;
  final ConnectivityMonitor connectivityMonitor;

  MerchantRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.pendingSyncDataSource,
    required this.connectivityMonitor,
  });

  @override
  Future<Either<Failure, List<Merchant>>> getMerchants({
    required String budgetId,
  }) async {
    try {
      final localModels =
          await localDataSource.getMerchantsByBudget(budgetId);
      final localMerchants = localModels.map((m) => m.toEntity()).toList();

      if (connectivityMonitor.isOnline) {
        _backgroundRefreshMerchants(budgetId);
      }

      return Right(localMerchants);
    } catch (e) {
      return Left(
          CacheFailure('Failed to read local merchants: ${e.toString()}'));
    }
  }

  void _backgroundRefreshMerchants(String budgetId) async {
    try {
      final response = await remoteDataSource.getMerchants(budgetId);
      if (response.success && response.data != null) {
        await localDataSource.saveMerchants(response.data!);
      }
    } catch (_) {}
  }

  @override
  Future<Either<Failure, Merchant>> getMerchantById(String id) async {
    try {
      final localModel = await localDataSource.getMerchantById(id);
      if (localModel != null) {
        return Right(localModel.toEntity());
      }

      if (!connectivityMonitor.isOnline) {
        return const Left(CacheFailure('Merchant not found locally'));
      }

      final response = await remoteDataSource.getMerchantById(id);
      if (response.success && response.data != null) {
        await localDataSource.saveMerchant(response.data!);
        return Right(response.data!.toEntity());
      } else {
        return Left(
            ServerFailure(response.message ?? 'Merchant not found'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
          CacheFailure('Failed to get merchant: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Merchant>>> searchMerchants({
    required String budgetId,
    required String query,
  }) async {
    try {
      // Search locally first
      final localModels =
          await localDataSource.searchMerchantsByName(budgetId, query);
      final localMerchants = localModels.map((m) => m.toEntity()).toList();

      return Right(localMerchants);
    } catch (e) {
      return Left(
          CacheFailure('Failed to search merchants: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Merchant>> createMerchant({
    required String budgetId,
    required String name,
    String? displayName,
    String? color,
    String? defaultCategoryId,
  }) async {
    try {
      final now = DateTime.now();
      final localId = const Uuid().v4();

      final localModel = MerchantModel(
        id: localId,
        budgetId: budgetId,
        name: name,
        displayName: displayName,
        color: color,
        defaultCategoryId: defaultCategoryId,
        archived: false,
        createdAt: now,
        updatedAt: now,
      );

      await localDataSource.saveMerchant(localModel, isSynced: false);

      final payload = jsonEncode({
        'name': name,
        if (displayName != null) 'displayName': displayName,
        if (color != null) 'color': color,
        if (defaultCategoryId != null) 'defaultCategoryId': defaultCategoryId,
      });

      await pendingSyncDataSource.addEntry(
        entityType: 'merchant',
        entityId: localId,
        operation: 'CREATE',
        payload: payload,
      );

      return Right(localModel.toEntity());
    } catch (e) {
      return Left(
          CacheFailure('Failed to create merchant locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Merchant>> updateMerchant({
    required String id,
    required String name,
    String? displayName,
    String? color,
    String? defaultCategoryId,
  }) async {
    try {
      final existing = await localDataSource.getMerchantById(id);
      if (existing == null) {
        return const Left(CacheFailure('Merchant not found locally'));
      }

      final updatedModel = MerchantModel(
        id: existing.id,
        budgetId: existing.budgetId,
        name: name,
        displayName: displayName ?? existing.displayName,
        logoUrl: existing.logoUrl,
        color: color ?? existing.color,
        defaultCategoryId: defaultCategoryId ?? existing.defaultCategoryId,
        archived: existing.archived,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      await localDataSource.saveMerchant(updatedModel, isSynced: false);

      final payload = jsonEncode({
        'name': name,
        if (displayName != null) 'displayName': displayName,
        if (color != null) 'color': color,
        if (defaultCategoryId != null) 'defaultCategoryId': defaultCategoryId,
      });

      await pendingSyncDataSource.addEntry(
        entityType: 'merchant',
        entityId: id,
        operation: 'UPDATE',
        payload: payload,
      );

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(
          CacheFailure('Failed to update merchant locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMerchant(String id) async {
    try {
      await localDataSource.softDelete(id);

      await pendingSyncDataSource.addEntry(
        entityType: 'merchant',
        entityId: id,
        operation: 'DELETE',
        payload: jsonEncode({'id': id}),
      );

      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure('Failed to delete merchant locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Merchant>> archiveMerchant(String id) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Archiving a merchant requires an internet connection.'));
    }

    try {
      final response = await remoteDataSource.archiveMerchant(id);
      if (response.success && response.data != null) {
        await localDataSource.saveMerchant(response.data!);
        return Right(response.data!.toEntity());
      } else {
        return Left(
            ServerFailure(response.message ?? 'Failed to archive merchant'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Merchant>> unarchiveMerchant(String id) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Unarchiving a merchant requires an internet connection.'));
    }

    try {
      final response = await remoteDataSource.unarchiveMerchant(id);
      if (response.success && response.data != null) {
        await localDataSource.saveMerchant(response.data!);
        return Right(response.data!.toEntity());
      } else {
        return Left(
            ServerFailure(response.message ?? 'Failed to unarchive merchant'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TopMerchantsData>> getTopMerchants({
    required String budgetId,
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  }) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Top merchants analytics requires an internet connection.'));
    }

    try {
      final startStr =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endStr =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      final response = await remoteDataSource.getTopMerchants(
        budgetId,
        startStr,
        endStr,
        limit,
      );

      if (response.success && response.data != null) {
        // The API returns merchant models for top merchants; build summary from them
        final merchants = response.data!;
        final summaries = merchants.map((m) {
          return MerchantSpendingSummary(
            merchantId: m.id,
            merchantName: m.name,
            totalAmount: 0,
            transactionCount: 0,
            percentage: 0,
          );
        }).toList();

        final topMerchantsData = TopMerchantsData(
          period: '$startStr to $endStr',
          summaries: summaries,
          totalSpend: 0,
        );

        return Right(topMerchantsData);
      } else {
        return Left(
            ServerFailure(response.message ?? 'Failed to get top merchants'));
      }
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
