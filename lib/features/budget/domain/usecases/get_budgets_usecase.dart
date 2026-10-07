import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class GetBudgetsUseCase {
  final BudgetRepository repository;

  GetBudgetsUseCase(this.repository);

  Future<Either<Failure, List<Budget>>> call() async {
    return await repository.getBudgets();
  }
}
