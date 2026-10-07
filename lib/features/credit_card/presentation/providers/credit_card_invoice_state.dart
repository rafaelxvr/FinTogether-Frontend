import 'package:equatable/equatable.dart';
import '../../domain/entities/credit_card_invoice.dart';

/// Credit Card Invoice State
abstract class CreditCardInvoiceState extends Equatable {
  const CreditCardInvoiceState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class InvoiceInitial extends CreditCardInvoiceState {
  const InvoiceInitial();
}

/// Loading state
class InvoiceLoading extends CreditCardInvoiceState {
  const InvoiceLoading();
}

/// Loaded state with a single invoice
class InvoiceLoaded extends CreditCardInvoiceState {
  final CreditCardInvoice invoice;

  const InvoiceLoaded(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

/// Loaded state with invoice summaries list
class InvoiceSummariesLoaded extends CreditCardInvoiceState {
  final List<InvoiceSummary> summaries;

  const InvoiceSummariesLoaded(this.summaries);

  @override
  List<Object?> get props => [summaries];
}

/// Error state
class InvoiceError extends CreditCardInvoiceState {
  final String message;

  const InvoiceError(this.message);

  @override
  List<Object?> get props => [message];
}
