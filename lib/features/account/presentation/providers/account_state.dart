import 'package:equatable/equatable.dart';
import '../../domain/entities/account.dart';

abstract class AccountState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountsLoaded extends AccountState {
  final List<Account> accounts;

  AccountsLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class AccountLoaded extends AccountState {
  final Account account;

  AccountLoaded(this.account);

  @override
  List<Object?> get props => [account];
}

class AccountCreated extends AccountState {
  final Account account;

  AccountCreated(this.account);

  @override
  List<Object?> get props => [account];
}

class AccountUpdated extends AccountState {
  final Account account;

  AccountUpdated(this.account);

  @override
  List<Object?> get props => [account];
}

class AccountDeleted extends AccountState {}

class TransferCompleted extends AccountState {}

class AccountStatusToggled extends AccountState {}

class AccountError extends AccountState {
  final String message;

  AccountError(this.message);

  @override
  List<Object?> get props => [message];
}
