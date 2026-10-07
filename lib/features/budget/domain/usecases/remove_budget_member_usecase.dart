import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../repositories/budget_repository.dart';

class RemoveBudgetMemberUseCase {
  final BudgetRepository repository;

  RemoveBudgetMemberUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String budgetId,
    required String memberId,
  }) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

    if (memberId.trim().isEmpty) {
      return const Left(ValidationFailure('Member ID is required'));
    }

    return await repository.removeBudgetMember(
      budgetId: budgetId,
      memberId: memberId,
    );
  }
}
