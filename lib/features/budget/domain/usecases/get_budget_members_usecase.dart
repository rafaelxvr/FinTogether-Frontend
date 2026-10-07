import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/budget_member.dart';
import '../repositories/budget_repository.dart';

class GetBudgetMembersUseCase {
  final BudgetRepository repository;

  GetBudgetMembersUseCase(this.repository);

  Future<Either<Failure, List<BudgetMember>>> call(String budgetId) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

    return await repository.getBudgetMembers(budgetId);
  }
}
