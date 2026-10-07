import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/merchant.dart';
import '../repositories/merchant_repository.dart';

class UpdateMerchantUseCase {
  final MerchantRepository repository;

  UpdateMerchantUseCase(this.repository);

  Future<Either<Failure, Merchant>> call({
    required String id,
    required String name,
    String? displayName,
    String? color,
    String? defaultCategoryId,
  }) async {
    // Validate merchant ID
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Merchant ID is required'));
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

    return await repository.updateMerchant(
      id: id.trim(),
      name: name.trim(),
      displayName: displayName?.trim(),
      color: color?.trim(),
      defaultCategoryId: defaultCategoryId?.trim(),
    );
  }
}
