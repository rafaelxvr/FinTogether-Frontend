import 'package:equatable/equatable.dart';
import '../../domain/entities/credit_card.dart';

/// Credit Card State
abstract class CreditCardState extends Equatable {
  const CreditCardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CreditCardInitial extends CreditCardState {
  const CreditCardInitial();
}

/// Loading state
class CreditCardLoading extends CreditCardState {
  const CreditCardLoading();
}

/// Loaded state with list of credit cards
class CreditCardLoaded extends CreditCardState {
  final List<CreditCard> creditCards;

  const CreditCardLoaded(this.creditCards);

  @override
  List<Object?> get props => [creditCards];
}

/// Error state
class CreditCardError extends CreditCardState {
  final String message;

  const CreditCardError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Operation success state (for create/update/delete feedback)
class CreditCardOperationSuccess extends CreditCardState {
  final String message;
  final List<CreditCard> creditCards;

  const CreditCardOperationSuccess(this.message, this.creditCards);

  @override
  List<Object?> get props => [message, creditCards];
}
