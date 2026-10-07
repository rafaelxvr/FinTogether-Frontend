import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<Category>>> call({
    required String budgetId,
    CategoryType? type,
  }) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }
    return await repository.getCategories(budgetId: budgetId, type: type);
  }
}
