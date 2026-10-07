import 'package:dio/dio.dart';
import '../models/budget_allocation_model.dart';

/// Budget Allocation Remote Data Source
/// Handles API communication for budget allocation endpoints.
class BudgetAllocationRemoteDataSource {
  final Dio _dio;

  BudgetAllocationRemoteDataSource(this._dio);

  /// Get allocations with actual spending for a budget and month.
  Future<BudgetAllocationModel> getAllocations(
    String budgetId,
    String month,
  ) async {
    final response = await _dio.get(
      '/api/budgets/$budgetId/allocations',
      queryParameters: {'month': month},
    );
    return BudgetAllocationModel.fromJson(response.data['data']);
  }

  /// Set or update allocations for multiple categories.
  Future<BudgetAllocationModel> setAllocations(
    String budgetId,
    SetAllocationsRequestModel request,
  ) async {
    final response = await _dio.put(
      '/api/budgets/$budgetId/allocations',
      data: request.toJson(),
    );
    return BudgetAllocationModel.fromJson(response.data['data']);
  }
}
