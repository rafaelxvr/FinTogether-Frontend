import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/credit_card_invoice_usecases.dart';
import 'credit_card_invoice_state.dart';

/// Credit Card Invoice Notifier
class CreditCardInvoiceNotifier extends StateNotifier<CreditCardInvoiceState> {
  final GetCreditCardInvoiceUseCase getCreditCardInvoiceUseCase;
  final GetInvoiceSummariesUseCase getInvoiceSummariesUseCase;

  CreditCardInvoiceNotifier({
    required this.getCreditCardInvoiceUseCase,
    required this.getInvoiceSummariesUseCase,
  }) : super(const InvoiceInitial());

  /// Load a single invoice for a card and month
  Future<void> loadInvoice(String cardId, String month) async {
    state = const InvoiceLoading();

    final result = await getCreditCardInvoiceUseCase(cardId, month);

    result.fold(
      (failure) => state = InvoiceError(failure.message),
      (invoice) => state = InvoiceLoaded(invoice),
    );
  }

  /// Load invoice summaries for a card
  Future<void> loadSummaries(String cardId, {int monthsBack = 6}) async {
    state = const InvoiceLoading();

    final result = await getInvoiceSummariesUseCase(cardId, monthsBack: monthsBack);

    result.fold(
      (failure) => state = InvoiceError(failure.message),
      (summaries) => state = InvoiceSummariesLoaded(summaries),
    );
  }

  /// Navigate to a specific month's invoice
  Future<void> navigateToMonth(String cardId, String month) async {
    await loadInvoice(cardId, month);
  }

  /// Reset to initial state
  void reset() {
    state = const InvoiceInitial();
  }
}

/// Credit Card Invoice Provider
final creditCardInvoiceProvider =
    StateNotifierProvider<CreditCardInvoiceNotifier, CreditCardInvoiceState>(
  (ref) {
    return CreditCardInvoiceNotifier(
      getCreditCardInvoiceUseCase: getIt<GetCreditCardInvoiceUseCase>(),
      getInvoiceSummariesUseCase: getIt<GetInvoiceSummariesUseCase>(),
    );
  },
);
