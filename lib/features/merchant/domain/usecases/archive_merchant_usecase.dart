import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/merchant.dart';
import '../repositories/merchant_repository.dart';

class ArchiveMerchantUseCase {
  final MerchantRepository repository;

  ArchiveMerchantUseCase(this.repository);

  Future<Either<Failure, Merchant>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Merchant ID is required'));
    }
    return await repository.archiveMerchant(id);
  }
}
