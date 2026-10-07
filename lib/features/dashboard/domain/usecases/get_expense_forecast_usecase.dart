import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/expense_forecast.dart';
import '../repositories/dashboard_repository.dart';

class GetExpenseForecastUseCase {
  final DashboardRepository repository;

  GetExpenseForecastUseCase(this.repository);

  Future<Either<Failure, ExpenseForecast>> call(
    GetExpenseForecastParams params,
  ) async {
    if (params.budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID cannot be empty'));
    }
    return await repository.getExpenseForecast(params.budgetId);
  }
}

class GetExpenseForecastParams {
  final String budgetId;

  GetExpenseForecastParams({required this.budgetId});
}
