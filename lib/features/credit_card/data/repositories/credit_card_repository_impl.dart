import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/base_repository_mixin.dart';
import '../../../../core/database/datasources/pending_sync_local_datasource.dart';
import '../../../../core/sync/connectivity_monitor.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/entities/credit_card_invoice.dart';
import '../../domain/repositories/credit_card_repository.dart';
import '../datasources/credit_card_local_datasource.dart';
import '../datasources/credit_card_remote_datasource.dart';
import '../models/credit_card_model.dart';

/// Credit Card Repository Implementation
class CreditCardRepositoryImpl
    with BaseRepositoryMixin
    implements CreditCardRepository {
  final CreditCardRemoteDataSource remoteDataSource;
  final CreditCardLocalDataSource localDataSource;
  final PendingSyncLocalDataSource pendingSyncDataSource;
  final ConnectivityMonitor connectivityMonitor;

  CreditCardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.pendingSyncDataSource,
    required this.connectivityMonitor,
  });

  @override
  Future<Either<Failure, List<CreditCard>>> getCreditCards(
    String budgetId, {
    bool activeOnly = false,
  }) async {
    try {
      final localModels =
          await localDataSource.getCreditCardsByBudget(budgetId);
      final filtered = activeOnly
          ? localModels.where((m) => m.active).toList()
          : localModels;
      final localCards = filtered.map((m) => m.toEntity()).toList();

      if (connectivityMonitor.isOnline) {
        _backgroundRefreshCreditCards(budgetId, activeOnly);
      }

      return Right(localCards);
    } catch (e) {
      return Left(
          CacheFailure('Failed to read local credit cards: ${e.toString()}'));
    }
  }

  void _backgroundRefreshCreditCards(
      String budgetId, bool activeOnly) async {
    try {
      final models =
          await remoteDataSource.getCreditCards(budgetId, activeOnly, null);
      await localDataSource.saveCreditCards(models);
    } catch (_) {}
  }

  @override
  Future<Either<Failure, CreditCard>> getCreditCardById(String id) async {
    try {
      final localModel = await localDataSource.getCreditCardById(id);
      if (localModel != null) {
        return Right(localModel.toEntity());
      }

      if (!connectivityMonitor.isOnline) {
        return const Left(CacheFailure('Credit card not found locally'));
      }

      final model = await remoteDataSource.getCreditCardById(id);
      await localDataSource.saveCreditCard(model);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
          CacheFailure('Failed to get credit card: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CreditCard>> createCreditCard({
    required String budgetId,
    required String name,
    String? issuer,
    String? lastFour,
    String currency = 'BRL',
    required int statementCloseDay,
    required int dueDay,
    String? linkedAccountId,
  }) async {
    try {
      final now = DateTime.now();
      final localId = const Uuid().v4();

      final localModel = CreditCardModel(
        id: localId,
        budgetId: budgetId,
        name: name,
        issuer: issuer,
        lastFour: lastFour,
        currency: currency,
        statementCloseDay: statementCloseDay,
        dueDay: dueDay,
        linkedAccountId: linkedAccountId,
        active: true,
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      await localDataSource.saveCreditCard(localModel, isSynced: false);

      final payload = jsonEncode({
        'budgetId': budgetId,
        'name': name,
        if (issuer != null) 'issuer': issuer,
        if (lastFour != null) 'lastFour': lastFour,
        'currency': currency,
        'statementCloseDay': statementCloseDay,
        'dueDay': dueDay,
        if (linkedAccountId != null) 'linkedAccountId': linkedAccountId,
      });

      await pendingSyncDataSource.addEntry(
        entityType: 'credit_card',
        entityId: localId,
        operation: 'CREATE',
        payload: payload,
      );

      return Right(localModel.toEntity());
    } catch (e) {
      return Left(
          CacheFailure('Failed to create credit card locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CreditCard>> updateCreditCard(
    String id, {
    String? name,
    String? issuer,
    String? lastFour,
    String? currency,
    int? statementCloseDay,
    int? dueDay,
    String? linkedAccountId,
  }) async {
    try {
      final existing = await localDataSource.getCreditCardById(id);
      if (existing == null) {
        return const Left(CacheFailure('Credit card not found locally'));
      }

      final updatedModel = CreditCardModel(
        id: existing.id,
        budgetId: existing.budgetId,
        name: name ?? existing.name,
        issuer: issuer ?? existing.issuer,
        lastFour: lastFour ?? existing.lastFour,
        currency: currency ?? existing.currency,
        statementCloseDay: statementCloseDay ?? existing.statementCloseDay,
        dueDay: dueDay ?? existing.dueDay,
        linkedAccountId: linkedAccountId ?? existing.linkedAccountId,
        linkedAccountName: existing.linkedAccountName,
        active: existing.active,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );

      await localDataSource.saveCreditCard(updatedModel, isSynced: false);

      final request = <String, dynamic>{};
      if (name != null) request['name'] = name;
      if (issuer != null) request['issuer'] = issuer;
      if (lastFour != null) request['lastFour'] = lastFour;
      if (currency != null) request['currency'] = currency;
      if (statementCloseDay != null) {
        request['statementCloseDay'] = statementCloseDay;
      }
      if (dueDay != null) request['dueDay'] = dueDay;
      if (linkedAccountId != null) request['linkedAccountId'] = linkedAccountId;

      await pendingSyncDataSource.addEntry(
        entityType: 'credit_card',
        entityId: id,
        operation: 'UPDATE',
        payload: jsonEncode(request),
      );

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(
          CacheFailure('Failed to update credit card locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCreditCard(String id) async {
    try {
      await localDataSource.softDelete(id);

      await pendingSyncDataSource.addEntry(
        entityType: 'credit_card',
        entityId: id,
        operation: 'DELETE',
        payload: jsonEncode({'id': id}),
      );

      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure('Failed to delete credit card locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CreditCard>> toggleStatus(
      String id, bool active) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Toggling credit card status requires an internet connection.'));
    }

    try {
      final request = {'active': active};
      final model = await remoteDataSource.toggleStatus(id, request);
      await localDataSource.saveCreditCard(model);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
          ServerFailure('Failed to toggle credit card status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CreditCard>> linkAccount(
      String id, String accountId) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Linking account requires an internet connection.'));
    }

    try {
      final request = {'accountId': accountId};
      final model = await remoteDataSource.linkAccount(id, request);
      await localDataSource.saveCreditCard(model);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
          ServerFailure('Failed to link account: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CreditCard>> unlinkAccount(String id) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Unlinking account requires an internet connection.'));
    }

    try {
      final model = await remoteDataSource.unlinkAccount(id);
      await localDataSource.saveCreditCard(model);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
          ServerFailure('Failed to unlink account: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CreditCardInvoice>> getInvoice(
      String cardId, String month) async {
    try {
      final model = await remoteDataSource.getInvoice(cardId, month);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
          ServerFailure('Failed to get invoice: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<InvoiceSummary>>> getInvoiceSummaries(
      String cardId, {int monthsBack = 6}) async {
    try {
      final models =
          await remoteDataSource.getInvoiceSummaries(cardId, monthsBack);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
          ServerFailure('Failed to get invoice summaries: ${e.toString()}'));
    }
  }
}
