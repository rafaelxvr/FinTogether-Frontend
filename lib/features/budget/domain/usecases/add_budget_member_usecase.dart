import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/budget_member.dart';
import '../repositories/budget_repository.dart';

class AddBudgetMemberUseCase {
  final BudgetRepository repository;

  AddBudgetMemberUseCase(this.repository);

  Future<Either<Failure, BudgetMember>> call({
    required String budgetId,
    required String email,
    required BudgetMemberRole role,
  }) async {
    // Validate budget ID
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

    // Validate email
    if (email.trim().isEmpty) {
      return const Left(ValidationFailure('Email is required'));
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    return await repository.addBudgetMember(
      budgetId: budgetId,
      email: email.trim().toLowerCase(),
      role: role,
    );
  }
}
