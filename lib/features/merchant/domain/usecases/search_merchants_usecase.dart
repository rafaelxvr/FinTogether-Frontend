import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/merchant.dart';
import '../repositories/merchant_repository.dart';

class SearchMerchantsUseCase {
  final MerchantRepository repository;

  SearchMerchantsUseCase(this.repository);

  Future<Either<Failure, List<Merchant>>> call({
    required String budgetId,
    required String query,
  }) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }
    if (query.trim().isEmpty) {
      return const Right([]);
    }
    return await repository.searchMerchants(
      budgetId: budgetId,
      query: query.trim(),
    );
  }
}
