import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class CreateBudgetUseCase {
  final BudgetRepository repository;

  CreateBudgetUseCase(this.repository);

  Future<Either<Failure, Budget>> call({
    required String name,
    required BudgetType type,
  }) async {
    // Validate budget name
    if (name.trim().isEmpty) {
      return const Left(ValidationFailure('Budget name is required'));
    }

    if (name.trim().length < 2) {
      return const Left(
          ValidationFailure('Budget name must be at least 2 characters'));
    }

    if (name.length > 255) {
      return const Left(
          ValidationFailure('Budget name must not exceed 255 characters'));
    }

    return await repository.createBudget(
      name: name.trim(),
      type: type,
    );
  }
}
