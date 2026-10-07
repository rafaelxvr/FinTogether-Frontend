import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../repositories/category_repository.dart';

class DeleteCategoryUseCase {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Category ID is required'));
    }
    return await repository.deleteCategory(id);
  }
}
