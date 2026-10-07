import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/dashboard_alerts.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardAlertsUseCase {
  final DashboardRepository repository;

  GetDashboardAlertsUseCase(this.repository);

  Future<Either<Failure, DashboardAlertsReport>> call(
    GetDashboardAlertsParams params,
  ) async {
    if (params.budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID cannot be empty'));
    }
    return await repository.getDashboardAlerts(params.budgetId);
  }
}

class GetDashboardAlertsParams {
  final String budgetId;

  GetDashboardAlertsParams({required this.budgetId});
}
