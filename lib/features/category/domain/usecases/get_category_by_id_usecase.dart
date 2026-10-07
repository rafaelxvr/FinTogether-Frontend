import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoryByIdUseCase {
  final CategoryRepository repository;

  GetCategoryByIdUseCase(this.repository);

  Future<Either<Failure, Category>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Category ID is required'));
    }
    return await repository.getCategoryById(id);
  }
}
