import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/credit_card.dart';
import '../entities/credit_card_invoice.dart';

/// Credit Card Repository Interface
/// Defines operations for credit card management
abstract class CreditCardRepository {
  /// Get all credit cards for a budget
  Future<Either<Failure, List<CreditCard>>> getCreditCards(
    String budgetId, {
    bool activeOnly = false,
  });

  /// Get credit card by ID
  Future<Either<Failure, CreditCard>> getCreditCardById(String id);

  /// Create a new credit card
  Future<Either<Failure, CreditCard>> createCreditCard({
    required String budgetId,
    required String name,
    String? issuer,
    String? lastFour,
    String currency = 'BRL',
    required int statementCloseDay,
    required int dueDay,
    String? linkedAccountId,
  });

  /// Update credit card
  Future<Either<Failure, CreditCard>> updateCreditCard(
    String id, {
    String? name,
    String? issuer,
    String? lastFour,
    String? currency,
    int? statementCloseDay,
    int? dueDay,
    String? linkedAccountId,
  });

  /// Delete credit card
  Future<Either<Failure, void>> deleteCreditCard(String id);

  /// Toggle credit card active status
  Future<Either<Failure, CreditCard>> toggleStatus(String id, bool active);

  /// Link account to credit card
  Future<Either<Failure, CreditCard>> linkAccount(
      String id, String accountId);

  /// Unlink account from credit card
  Future<Either<Failure, CreditCard>> unlinkAccount(String id);

  /// Get invoice for a credit card and month
  Future<Either<Failure, CreditCardInvoice>> getInvoice(
      String cardId, String month);

  /// Get invoice summaries for a credit card
  Future<Either<Failure, List<InvoiceSummary>>> getInvoiceSummaries(
      String cardId, {int monthsBack = 6});
}
