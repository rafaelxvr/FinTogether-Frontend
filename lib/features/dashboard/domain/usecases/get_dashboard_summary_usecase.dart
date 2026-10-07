import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

/// Use Case: Get Dashboard Summary
///
/// Retrieves comprehensive dashboard summary including:
/// - Total income/expense for the period
/// - Net cash flow
/// - Account balances
/// - Category breakdown
/// - Recent transactions
class GetDashboardSummaryUseCase {
  final DashboardRepository repository;

  GetDashboardSummaryUseCase(this.repository);

  /// Execute the use case
  ///
  /// [params] - Parameters including budgetId and optional month
  ///
  /// Returns Either<Failure, DashboardSummary>
  Future<Either<Failure, DashboardSummary>> call(
    GetDashboardSummaryParams params,
  ) async {
    // Validate budget ID
    if (params.budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID cannot be empty'));
    }

    // Validate month format if provided (YYYY-MM)
    if (params.yearMonth != null && params.yearMonth!.isNotEmpty) {
      final monthPattern = RegExp(r'^\d{4}-\d{2}$');
      if (!monthPattern.hasMatch(params.yearMonth!)) {
        return const Left(
          ValidationFailure('Invalid month format. Expected: YYYY-MM'),
        );
      }
    }

    // Fetch dashboard summary from repository
    return await repository.getDashboardSummary(
      params.budgetId,
      yearMonth: params.yearMonth,
    );
  }
}

/// Parameters for Get Dashboard Summary Use Case
class GetDashboardSummaryParams {
  final String budgetId;
  final String? yearMonth; // Optional, format: "2025-11"

  GetDashboardSummaryParams({
    required this.budgetId,
    this.yearMonth,
  });
}
