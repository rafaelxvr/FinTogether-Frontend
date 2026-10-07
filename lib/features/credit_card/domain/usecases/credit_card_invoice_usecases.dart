import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/credit_card_invoice.dart';
import '../repositories/credit_card_repository.dart';

/// Get Credit Card Invoice Use Case
class GetCreditCardInvoiceUseCase {
  final CreditCardRepository repository;

  GetCreditCardInvoiceUseCase(this.repository);

  Future<Either<Failure, CreditCardInvoice>> call(
      String cardId, String month) async {
    if (cardId.isEmpty) {
      return const Left(ValidationFailure('Card ID cannot be empty'));
    }
    if (month.isEmpty) {
      return const Left(ValidationFailure('Month cannot be empty'));
    }
    return await repository.getInvoice(cardId, month);
  }
}

/// Get Invoice Summaries Use Case
class GetInvoiceSummariesUseCase {
  final CreditCardRepository repository;

  GetInvoiceSummariesUseCase(this.repository);

  Future<Either<Failure, List<InvoiceSummary>>> call(
    String cardId, {
    int monthsBack = 6,
  }) async {
    if (cardId.isEmpty) {
      return const Left(ValidationFailure('Card ID cannot be empty'));
    }
    if (monthsBack < 1) {
      return const Left(
          ValidationFailure('Months back must be at least 1'));
    }
    return await repository.getInvoiceSummaries(cardId,
        monthsBack: monthsBack);
  }
}
