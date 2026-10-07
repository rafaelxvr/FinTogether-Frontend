import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/merchant.dart';
import '../repositories/merchant_repository.dart';

class GetMerchantsUseCase {
  final MerchantRepository repository;

  GetMerchantsUseCase(this.repository);

  Future<Either<Failure, List<Merchant>>> call({
    required String budgetId,
  }) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }
    return await repository.getMerchants(budgetId: budgetId);
  }
}
