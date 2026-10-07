import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/essential_breakdown.dart';
import '../repositories/dashboard_repository.dart';

class GetEssentialBreakdownUseCase {
  final DashboardRepository repository;

  GetEssentialBreakdownUseCase(this.repository);

  Future<Either<Failure, EssentialBreakdown>> call(
    GetEssentialBreakdownParams params,
  ) async {
    if (params.budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID cannot be empty'));
    }
    return await repository.getEssentialBreakdown(
      params.budgetId,
      yearMonth: params.yearMonth,
    );
  }
}

class GetEssentialBreakdownParams {
  final String budgetId;
  final String? yearMonth;

  GetEssentialBreakdownParams({required this.budgetId, this.yearMonth});
}
