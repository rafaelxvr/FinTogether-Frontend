import 'package:equatable/equatable.dart';
import '../../domain/entities/merchant.dart';

abstract class MerchantState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MerchantInitial extends MerchantState {}

class MerchantLoading extends MerchantState {}

class MerchantsLoaded extends MerchantState {
  final List<Merchant> merchants;

  MerchantsLoaded(this.merchants);

  @override
  List<Object?> get props => [merchants];
}

class MerchantLoaded extends MerchantState {
  final Merchant merchant;

  MerchantLoaded(this.merchant);

  @override
  List<Object?> get props => [merchant];
}

class MerchantCreated extends MerchantState {
  final Merchant merchant;

  MerchantCreated(this.merchant);

  @override
  List<Object?> get props => [merchant];
}

class MerchantUpdated extends MerchantState {
  final Merchant merchant;

  MerchantUpdated(this.merchant);

  @override
  List<Object?> get props => [merchant];
}

class MerchantDeleted extends MerchantState {}

class MerchantArchived extends MerchantState {
  final Merchant merchant;

  MerchantArchived(this.merchant);

  @override
  List<Object?> get props => [merchant];
}

class MerchantUnarchived extends MerchantState {
  final Merchant merchant;

  MerchantUnarchived(this.merchant);

  @override
  List<Object?> get props => [merchant];
}

class MerchantError extends MerchantState {
  final String message;

  MerchantError(this.message);

  @override
  List<Object?> get props => [message];
}
