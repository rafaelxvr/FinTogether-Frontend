import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../repositories/merchant_repository.dart';

class DeleteMerchantUseCase {
  final MerchantRepository repository;

  DeleteMerchantUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Merchant ID is required'));
    }
    return await repository.deleteMerchant(id);
  }
}
