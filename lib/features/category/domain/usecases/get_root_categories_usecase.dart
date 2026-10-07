import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetRootCategoriesUseCase {
  final CategoryRepository repository;

  GetRootCategoriesUseCase(this.repository);

  Future<Either<Failure, List<Category>>> call(String budgetId) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }
    return await repository.getRootCategories(budgetId);
  }
}
