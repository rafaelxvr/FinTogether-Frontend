import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/income_report.dart';
import '../repositories/dashboard_repository.dart';

class GetIncomeByMemberUseCase {
  final DashboardRepository repository;

  GetIncomeByMemberUseCase(this.repository);

  Future<Either<Failure, IncomeByMemberReport>> call(
    GetIncomeByMemberParams params,
  ) async {
    if (params.budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID cannot be empty'));
    }
    return await repository.getIncomeByMember(
      params.budgetId,
      yearMonth: params.yearMonth,
    );
  }
}

class GetIncomeByMemberParams {
  final String budgetId;
  final String? yearMonth;

  GetIncomeByMemberParams({required this.budgetId, this.yearMonth});
}
