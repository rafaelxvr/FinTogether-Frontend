import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/merchant_analytics.dart';
import '../repositories/merchant_repository.dart';

class GetTopMerchantsUseCase {
  final MerchantRepository repository;

  GetTopMerchantsUseCase(this.repository);

  Future<Either<Failure, TopMerchantsData>> call({
    required String budgetId,
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  }) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }
    if (startDate.isAfter(endDate)) {
      return const Left(
          ValidationFailure('Start date must be before end date'));
    }
    if (limit < 1 || limit > 50) {
      return const Left(
          ValidationFailure('Limit must be between 1 and 50'));
    }

    return await repository.getTopMerchants(
      budgetId: budgetId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }
}
