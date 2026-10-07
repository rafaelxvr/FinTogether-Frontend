import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/merchant.dart';
import '../repositories/merchant_repository.dart';

class CreateMerchantUseCase {
  final MerchantRepository repository;

  CreateMerchantUseCase(this.repository);

  Future<Either<Failure, Merchant>> call({
    required String budgetId,
    required String name,
    String? displayName,
    String? color,
    String? defaultCategoryId,
  }) async {
    // Validate budget ID
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

    // Validate name
    if (name.trim().isEmpty) {
      return const Left(ValidationFailure('Merchant name is required'));
    }
    if (name.trim().length < 2) {
      return const Left(
          ValidationFailure('Merchant name must be at least 2 characters'));
    }
    if (name.length > 255) {
      return const Left(
          ValidationFailure('Merchant name must not exceed 255 characters'));
    }

    // Validate color (hex format if provided)
    if (color != null && color.trim().isNotEmpty) {
      final hexPattern = RegExp(r'^#?[0-9A-Fa-f]{6}$');
      if (!hexPattern.hasMatch(color.trim())) {
        return const Left(
            ValidationFailure('Color must be in hex format (e.g., #FF0000)'));
      }
    }

    return await repository.createMerchant(
      budgetId: budgetId.trim(),
      name: name.trim(),
      displayName: displayName?.trim(),
      color: color?.trim(),
      defaultCategoryId: defaultCategoryId?.trim(),
    );
  }
}
