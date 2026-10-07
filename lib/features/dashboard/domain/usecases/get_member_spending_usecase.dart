import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/member_spending.dart';
import '../repositories/dashboard_repository.dart';

class GetMemberSpendingUseCase {
  final DashboardRepository repository;

  GetMemberSpendingUseCase(this.repository);

  Future<Either<Failure, MemberSpendingReport>> call(
    GetMemberSpendingParams params,
  ) async {
    if (params.budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID cannot be empty'));
    }
    return await repository.getMemberSpending(
      params.budgetId,
      yearMonth: params.yearMonth,
    );
  }
}

class GetMemberSpendingParams {
  final String budgetId;
  final String? yearMonth;

  GetMemberSpendingParams({required this.budgetId, this.yearMonth});
}
