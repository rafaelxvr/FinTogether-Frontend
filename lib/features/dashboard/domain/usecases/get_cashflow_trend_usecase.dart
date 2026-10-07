import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/cashflow_trend.dart';
import '../repositories/dashboard_repository.dart';

/// Use Case: Get Cashflow Trend
///
/// Retrieves monthly income/expense trend data for visualization
/// Typically used for line charts showing financial trends over time
class GetCashflowTrendUseCase {
  final DashboardRepository repository;

  GetCashflowTrendUseCase(this.repository);

  /// Execute the use case
  ///
  /// [params] - Parameters including budgetId and months count
  ///
  /// Returns Either<Failure, CashflowTrend>
  Future<Either<Failure, CashflowTrend>> call(
    GetCashflowTrendParams params,
  ) async {
    // Validate budget ID
    if (params.budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID cannot be empty'));
    }

    // Validate months count
    if (params.monthsCount < 1) {
      return const Left(ValidationFailure('Months count must be at least 1'));
    }

    if (params.monthsCount > 24) {
      return const Left(
        ValidationFailure('Months count cannot exceed 24'),
      );
    }

    // Fetch cashflow trend from repository
    return await repository.getCashflowTrend(
      params.budgetId,
      monthsCount: params.monthsCount,
    );
  }
}

/// Parameters for Get Cashflow Trend Use Case
class GetCashflowTrendParams {
  final String budgetId;
  final int monthsCount; // 1-24 months

  GetCashflowTrendParams({
    required this.budgetId,
    this.monthsCount = 6,
  });
}
