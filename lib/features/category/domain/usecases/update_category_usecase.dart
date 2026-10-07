import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<Either<Failure, Category>> call({
    required String id,
    required String name,
    String? icon,
    String? color,
    double? limitAmount,
    String? parentId,
  }) async {
    // Validate category ID
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Category ID is required'));
    }

    // Validate name
    if (name.trim().isEmpty) {
      return const Left(ValidationFailure('Category name is required'));
    }
    if (name.trim().length < 2) {
      return const Left(
          ValidationFailure('Category name must be at least 2 characters'));
    }
    if (name.length > 255) {
      return const Left(
          ValidationFailure('Category name must not exceed 255 characters'));
    }

    // Validate color (hex format if provided)
    if (color != null && color.trim().isNotEmpty) {
      final hexPattern = RegExp(r'^#?[0-9A-Fa-f]{6}$');
      if (!hexPattern.hasMatch(color.trim())) {
        return const Left(
            ValidationFailure('Color must be in hex format (e.g., #FF0000)'));
      }
    }

    // Validate limit amount
    if (limitAmount != null) {
      if (limitAmount < 0) {
        return const Left(ValidationFailure('Limit amount cannot be negative'));
      }
      if (limitAmount.isNaN || limitAmount.isInfinite) {
        return const Left(ValidationFailure('Invalid limit amount'));
      }
    }

    return await repository.updateCategory(
      id: id.trim(),
      name: name.trim(),
      icon: icon?.trim(),
      color: color?.trim(),
      limitAmount: limitAmount,
      parentId: parentId?.trim(),
    );
  }
}
