import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class UpdateBudgetUseCase {
  final BudgetRepository repository;

  UpdateBudgetUseCase(this.repository);

  Future<Either<Failure, Budget>> call({
    required String id,
    required String name,
    required BudgetType type,
  }) async {
    // Validate budget ID
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

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

    return await repository.updateBudget(
      id: id,
      name: name.trim(),
      type: type,
    );
  }
}
