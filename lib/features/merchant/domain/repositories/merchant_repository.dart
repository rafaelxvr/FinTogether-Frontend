import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/merchant.dart';
import '../entities/merchant_analytics.dart';

abstract class MerchantRepository {
  /// Get all merchants for a budget
  Future<Either<Failure, List<Merchant>>> getMerchants({
    required String budgetId,
  });

  /// Get merchant by ID
  Future<Either<Failure, Merchant>> getMerchantById(String id);

  /// Search merchants by name (autocomplete)
  Future<Either<Failure, List<Merchant>>> searchMerchants({
    required String budgetId,
    required String query,
  });

  /// Create new merchant
  Future<Either<Failure, Merchant>> createMerchant({
    required String budgetId,
    required String name,
    String? displayName,
    String? color,
    String? defaultCategoryId,
  });

  /// Update existing merchant
  Future<Either<Failure, Merchant>> updateMerchant({
    required String id,
    required String name,
    String? displayName,
    String? color,
    String? defaultCategoryId,
  });

  /// Delete merchant
  Future<Either<Failure, void>> deleteMerchant(String id);

  /// Archive merchant
  Future<Either<Failure, Merchant>> archiveMerchant(String id);

  /// Unarchive merchant
  Future<Either<Failure, Merchant>> unarchiveMerchant(String id);

  /// Get top merchants by spending
  Future<Either<Failure, TopMerchantsData>> getTopMerchants({
    required String budgetId,
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  });
}
