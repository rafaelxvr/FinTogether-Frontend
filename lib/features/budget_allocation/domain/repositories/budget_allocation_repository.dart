import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/budget_allocation.dart';

/// Budget Allocation Repository Interface
/// Defines operations for budget allocation management.
abstract class BudgetAllocationRepository {
  /// Get allocations with actual spending for a budget and month.
  Future<Either<Failure, BudgetAllocation>> getAllocations(
    String budgetId,
    String month,
  );

  /// Set or update allocations for multiple categories.
  Future<Either<Failure, BudgetAllocation>> setAllocations({
    required String budgetId,
    required String month,
    required List<CategoryAllocationInput> allocations,
  });
}
