import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/data/base_repository_mixin.dart';
import '../../../../core/sync/connectivity_monitor.dart';
import '../../../../core/utils/failure.dart';
import '../../../account/data/datasources/account_local_datasource.dart';
import '../../../transaction/data/datasources/transaction_local_datasource.dart';
import '../../domain/entities/cashflow_trend.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/essential_breakdown.dart';
import '../../domain/entities/member_spending.dart';
import '../../domain/entities/expense_forecast.dart';
import '../../domain/entities/dashboard_alerts.dart';
import '../../domain/entities/income_report.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

/// Dashboard Repository Implementation
///
/// Implements the dashboard repository interface with offline-first awareness.
/// Dashboard data is server-aggregated, so offline mode returns a network error
/// rather than attempting to replicate complex aggregation locally.
class DashboardRepositoryImpl
    with BaseRepositoryMixin
    implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final AccountLocalDataSource accountLocalDataSource;
  final TransactionLocalDataSource transactionLocalDataSource;
  final ConnectivityMonitor connectivityMonitor;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.accountLocalDataSource,
    required this.transactionLocalDataSource,
    required this.connectivityMonitor,
  });

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    String budgetId, {
    String? yearMonth,
  }) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Dashboard requires internet connection'));
    }

    try {
      final model = await remoteDataSource.getDashboardSummary(
        budgetId,
        yearMonth,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(
          'Failed to fetch dashboard summary: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CashflowTrend>> getCashflowTrend(
    String budgetId, {
    int monthsCount = 6,
  }) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Dashboard requires internet connection'));
    }

    try {
      final model = await remoteDataSource.getCashflowTrend(
        budgetId,
        monthsCount,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(
          'Failed to fetch cashflow trend: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, EssentialBreakdown>> getEssentialBreakdown(
    String budgetId, {
    String? yearMonth,
  }) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Dashboard requires internet connection'));
    }
    try {
      final model = await remoteDataSource.getEssentialBreakdown(
        budgetId,
        yearMonth,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(
          'Failed to fetch essential breakdown: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MemberSpendingReport>> getMemberSpending(
    String budgetId, {
    String? yearMonth,
  }) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Dashboard requires internet connection'));
    }
    try {
      final model = await remoteDataSource.getMemberSpending(
        budgetId,
        yearMonth,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(
          'Failed to fetch member spending: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ExpenseForecast>> getExpenseForecast(
    String budgetId,
  ) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Dashboard requires internet connection'));
    }
    try {
      final model = await remoteDataSource.getExpenseForecast(budgetId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(
          'Failed to fetch expense forecast: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DashboardAlertsReport>> getDashboardAlerts(
    String budgetId,
  ) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Dashboard requires internet connection'));
    }
    try {
      final model = await remoteDataSource.getDashboardAlerts(budgetId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(
          'Failed to fetch dashboard alerts: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, IncomeByMemberReport>> getIncomeByMember(
    String budgetId, {
    String? yearMonth,
  }) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
          NetworkFailure('Dashboard requires internet connection'));
    }
    try {
      final model = await remoteDataSource.getIncomeByMember(
        budgetId,
        yearMonth,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(
          'Failed to fetch income by member: ${e.toString()}'));
    }
  }
}
