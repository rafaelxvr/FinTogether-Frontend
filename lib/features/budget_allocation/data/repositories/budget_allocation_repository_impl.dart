import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/data/base_repository_mixin.dart';
import '../../../../core/sync/connectivity_monitor.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/budget_allocation.dart';
import '../../domain/repositories/budget_allocation_repository.dart';
import '../datasources/budget_allocation_remote_datasource.dart';
import '../models/budget_allocation_model.dart';

/// Budget Allocation Repository Implementation
/// Online-only for writes; reads are direct from the server.
class BudgetAllocationRepositoryImpl
    with BaseRepositoryMixin
    implements BudgetAllocationRepository {
  final BudgetAllocationRemoteDataSource remoteDataSource;
  final ConnectivityMonitor connectivityMonitor;

  BudgetAllocationRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityMonitor,
  });

  @override
  Future<Either<Failure, BudgetAllocation>> getAllocations(
    String budgetId,
    String month,
  ) async {
    try {
      final model = await remoteDataSource.getAllocations(budgetId, month);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to get allocations: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BudgetAllocation>> setAllocations({
    required String budgetId,
    required String month,
    required List<CategoryAllocationInput> allocations,
  }) async {
    if (!connectivityMonitor.isOnline) {
      return const Left(
        NetworkFailure('Setting allocations requires an internet connection.'),
      );
    }

    try {
      final request = SetAllocationsRequestModel(
        month: month,
        allocations: allocations
            .map((a) => CategoryAllocationInputModel(
                  categoryId: a.categoryId,
                  allocatedAmount: a.allocatedAmount,
                ))
            .toList(),
      );
      final model = await remoteDataSource.setAllocations(budgetId, request);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to set allocations: ${e.toString()}'));
    }
  }
}
