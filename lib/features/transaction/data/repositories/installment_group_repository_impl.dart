import 'dart:convert';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/base_repository_mixin.dart';
import '../../../../core/database/datasources/pending_sync_local_datasource.dart';
import '../../../../core/sync/connectivity_monitor.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/installment_group.dart';
import '../../domain/entities/installment_progress.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/installment_group_repository.dart';
import '../datasources/installment_group_local_datasource.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/installment_group_model.dart';
import '../models/transaction_model.dart';

class InstallmentGroupRepositoryImpl
    with BaseRepositoryMixin
    implements InstallmentGroupRepository {
  final InstallmentGroupLocalDataSource localDataSource;
  final TransactionLocalDataSource transactionLocalDataSource;
  final PendingSyncLocalDataSource pendingSyncDataSource;
  final ConnectivityMonitor connectivityMonitor;

  InstallmentGroupRepositoryImpl({
    required this.localDataSource,
    required this.transactionLocalDataSource,
    required this.pendingSyncDataSource,
    required this.connectivityMonitor,
  });

  @override
  Future<Either<Failure, InstallmentGroup>> createInstallmentGroup({
    required String budgetId,
    required double totalAmount,
    required int installmentCount,
    double interestRate = 0,
    required DateTime startDate,
    String? description,
    String? categoryId,
    String? accountId,
    String? cardId,
  }) async {
    try {
      final now = DateTime.now();
      final groupId = const Uuid().v4();

      final groupModel = InstallmentGroupModel(
        id: groupId,
        budgetId: budgetId,
        cardId: cardId,
        totalAmount: totalAmount,
        installmentCount: installmentCount,
        interestRate: interestRate,
        startDate: startDate,
        description: description,
        createdAt: now,
        updatedAt: now,
      );

      await localDataSource.saveGroup(groupModel, isSynced: false);

      // Auto-generate installment transactions
      final installmentAmount = interestRate > 0
          ? totalAmount *
              pow(1 + interestRate / 100, installmentCount) /
              installmentCount
          : totalAmount / installmentCount;

      for (int i = 0; i < installmentCount; i++) {
        final transactionDate = DateTime(
          startDate.year,
          startDate.month + i,
          startDate.day,
        );
        final transactionId = const Uuid().v4();

        final desc = description != null
            ? '$description (${i + 1}/$installmentCount)'
            : 'Installment ${i + 1}/$installmentCount';

        final transactionModel = TransactionModel(
          id: transactionId,
          budgetId: budgetId,
          transactionDate: transactionDate,
          amount: double.parse(installmentAmount.toStringAsFixed(2)),
          type: TransactionType.expense,
          accountId: accountId,
          categoryId: categoryId,
          cardId: cardId,
          description: desc,
          visibility: TransactionVisibility.shared,
          isRecurring: false,
          isInstallment: true,
          installmentGroupId: groupId,
          installmentNumber: i + 1,
          createdAt: now,
          updatedAt: now,
        );

        await transactionLocalDataSource.saveTransaction(transactionModel,
            isSynced: false);

        final txPayload = <String, dynamic>{
          'budgetId': budgetId,
          'transactionDate': _toDateString(transactionDate),
          'amount': double.parse(installmentAmount.toStringAsFixed(2)),
          'type': 'EXPENSE',
          'description': desc,
          'visibility': 'SHARED',
          'isInstallment': true,
          'installmentGroupId': groupId,
          'installmentNumber': i + 1,
        };
        if (accountId != null) txPayload['accountId'] = accountId;
        if (categoryId != null) txPayload['categoryId'] = categoryId;
        if (cardId != null) txPayload['cardId'] = cardId;

        await pendingSyncDataSource.addEntry(
          entityType: 'transaction',
          entityId: transactionId,
          operation: 'CREATE',
          payload: jsonEncode(txPayload),
        );
      }

      final groupPayload = <String, dynamic>{
        'budgetId': budgetId,
        'totalAmount': totalAmount,
        'installmentCount': installmentCount,
        'interestRate': interestRate,
        'startDate': _toDateString(startDate),
      };
      if (description != null) groupPayload['description'] = description;
      if (categoryId != null) groupPayload['categoryId'] = categoryId;
      if (accountId != null) groupPayload['accountId'] = accountId;
      if (cardId != null) groupPayload['cardId'] = cardId;

      await pendingSyncDataSource.addEntry(
        entityType: 'installment_group',
        entityId: groupId,
        operation: 'CREATE',
        payload: jsonEncode(groupPayload),
      );

      return Right(groupModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(
          'Failed to create installment group locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<InstallmentGroup>>> getInstallmentGroups(
      String budgetId) async {
    try {
      final localModels = await localDataSource.getGroupsByBudget(budgetId);
      final groups = localModels.map((m) => m.toEntity()).toList();
      return Right(groups);
    } catch (e) {
      return Left(CacheFailure(
          'Failed to read local installment groups: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, InstallmentProgress>> getInstallmentProgress(
      String groupId) async {
    try {
      final groupModel = await localDataSource.getGroupById(groupId);
      if (groupModel == null) {
        return const Left(CacheFailure('Installment group not found'));
      }

      final group = groupModel.toEntity();

      final allTransactions = await transactionLocalDataSource
          .getTransactionsByBudget(group.budgetId);
      final groupTransactions = allTransactions
          .where((t) => t.installmentGroupId == groupId)
          .map((t) => t.toEntity())
          .toList();

      groupTransactions.sort((a, b) =>
          (a.installmentNumber ?? 0).compareTo(b.installmentNumber ?? 0));

      final now = DateTime.now();
      final paidTransactions = groupTransactions
          .where((t) =>
              t.transactionDate.isBefore(now) ||
              t.transactionDate.isAtSameMomentAs(now))
          .toList();
      final paidCount = paidTransactions.length;
      final paidAmount =
          paidTransactions.fold<double>(0, (sum, t) => sum + t.amount);
      final remainingCount = group.installmentCount - paidCount;
      final remainingAmount = groupTransactions
          .where((t) => t.transactionDate.isAfter(now))
          .fold<double>(0, (sum, t) => sum + t.amount);

      return Right(InstallmentProgress(
        group: group,
        paidCount: paidCount,
        paidAmount: paidAmount,
        remainingCount: remainingCount,
        remainingAmount: remainingAmount,
        transactions: groupTransactions,
      ));
    } catch (e) {
      return Left(CacheFailure(
          'Failed to get installment progress: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInstallmentGroup(String groupId) async {
    try {
      final groupModel = await localDataSource.getGroupById(groupId);
      if (groupModel == null) {
        return const Left(CacheFailure('Installment group not found'));
      }

      await localDataSource.softDelete(groupId);

      final allTransactions = await transactionLocalDataSource
          .getTransactionsByBudget(groupModel.budgetId);
      final groupTransactions =
          allTransactions.where((t) => t.installmentGroupId == groupId);

      for (final transaction in groupTransactions) {
        await transactionLocalDataSource.softDelete(transaction.id);
        await pendingSyncDataSource.addEntry(
          entityType: 'transaction',
          entityId: transaction.id,
          operation: 'DELETE',
          payload: jsonEncode({'id': transaction.id}),
        );
      }

      await pendingSyncDataSource.addEntry(
        entityType: 'installment_group',
        entityId: groupId,
        operation: 'DELETE',
        payload: jsonEncode({'id': groupId}),
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(
          'Failed to delete installment group locally: ${e.toString()}'));
    }
  }

  String _toDateString(DateTime date) {
    return date.toIso8601String().substring(0, 10);
  }
}
