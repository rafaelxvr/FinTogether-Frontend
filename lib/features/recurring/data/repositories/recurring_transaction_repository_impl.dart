import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/utils/failure.dart';
import '../../domain/entities/fixed_expense_summary.dart';
import '../../domain/entities/recurring_transaction_template.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';
import '../datasources/recurring_transaction_remote_datasource.dart';

/// Implementation of RecurringTransactionRepository.
class RecurringTransactionRepositoryImpl
    implements RecurringTransactionRepository {
  final RecurringTransactionRemoteDataSource remoteDataSource;

  RecurringTransactionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<RecurringTransactionTemplate>>> getTemplates(
    String budgetId,
  ) async {
    try {
      final data = await remoteDataSource.getTemplates(budgetId);
      final templates = data.map(_mapToTemplate).toList();
      return Right(templates);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load templates'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecurringTransactionTemplate>> getTemplateById(
    String id,
  ) async {
    try {
      final data = await remoteDataSource.getTemplateById(id);
      return Right(_mapToTemplate(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load template'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecurringTransactionTemplate>> createTemplate({
    required String budgetId,
    required double amount,
    required RecurringTransactionType type,
    required String description,
    required RecurrenceFrequency frequency,
    int interval = 1,
    int? dayOfMonth,
    required DateTime startDate,
    DateTime? endDate,
    bool isFixedExpense = false,
    String? categoryId,
  }) async {
    try {
      final data = await remoteDataSource.createTemplate({
        'budgetId': budgetId,
        'amount': amount,
        'type': type.name.toUpperCase(),
        'description': description,
        'frequency': frequency.name.toUpperCase(),
        'interval': interval,
        'dayOfMonth': dayOfMonth,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'isFixedExpense': isFixedExpense,
        'categoryId': categoryId,
      });
      return Right(_mapToTemplate(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to create template'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecurringTransactionTemplate>> updateTemplate({
    required String id,
    double? amount,
    RecurringTransactionType? type,
    String? description,
    RecurrenceFrequency? frequency,
    int? interval,
    int? dayOfMonth,
    DateTime? startDate,
    DateTime? endDate,
    bool? isFixedExpense,
    String? categoryId,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (amount != null) payload['amount'] = amount;
      if (type != null) payload['type'] = type.name.toUpperCase();
      if (description != null) payload['description'] = description;
      if (frequency != null) {
        payload['frequency'] = frequency.name.toUpperCase();
      }
      if (interval != null) payload['interval'] = interval;
      if (dayOfMonth != null) payload['dayOfMonth'] = dayOfMonth;
      if (startDate != null) {
        payload['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        payload['endDate'] = endDate.toIso8601String();
      }
      if (isFixedExpense != null) payload['isFixedExpense'] = isFixedExpense;
      if (categoryId != null) payload['categoryId'] = categoryId;

      final data = await remoteDataSource.updateTemplate(id, payload);
      return Right(_mapToTemplate(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update template'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateTemplate(String id) async {
    try {
      await remoteDataSource.deactivateTemplate(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'Failed to deactivate template'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTemplate(String id) async {
    try {
      await remoteDataSource.deleteTemplate(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to delete template'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecurringTransactionTemplate>>> getFixedExpenses(
    String budgetId,
  ) async {
    try {
      final data = await remoteDataSource.getFixedExpenses(budgetId);
      final templates = data.map(_mapToTemplate).toList();
      return Right(templates);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'Failed to load fixed expenses'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FixedExpenseSummary>> getFixedExpenseSummary(
    String budgetId,
  ) async {
    try {
      final data = await remoteDataSource.getFixedExpenseSummary(budgetId);
      final expenses = (data['expenses'] as List<dynamic>?)
              ?.map((e) => _mapToTemplate(Map<String, dynamic>.from(e)))
              .toList() ??
          [];
      return Right(FixedExpenseSummary(
        totalMonthlyAmount: (data['totalMonthlyAmount'] as num).toDouble(),
        expenseCount: data['expenseCount'] as int,
        expenses: expenses,
      ));
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'Failed to load fixed expense summary'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  RecurringTransactionTemplate _mapToTemplate(Map<String, dynamic> json) {
    return RecurringTransactionTemplate(
      id: json['id'] as String,
      budgetId: json['budgetId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: RecurringTransactionType.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['type'] as String).toUpperCase(),
        orElse: () => RecurringTransactionType.expense,
      ),
      description: json['description'] as String,
      frequency: RecurrenceFrequency.values.firstWhere(
        (e) =>
            e.name.toUpperCase() ==
            (json['frequency'] as String).toUpperCase(),
        orElse: () => RecurrenceFrequency.monthly,
      ),
      interval: json['interval'] as int? ?? 1,
      dayOfMonth: json['dayOfMonth'] as int?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'] as String)
          : null,
      isFixedExpense: json['isFixedExpense'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      categoryId: json['categoryId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
