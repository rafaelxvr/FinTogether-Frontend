import 'package:equatable/equatable.dart';
import '../../domain/entities/member_balance.dart';
import '../../domain/entities/transaction_split.dart';

abstract class SplitState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SplitInitial extends SplitState {}

class SplitLoading extends SplitState {}

class BalancesLoaded extends SplitState {
  final List<MemberBalance> balances;

  BalancesLoaded(this.balances);

  @override
  List<Object?> get props => [balances];
}

class SplitsLoaded extends SplitState {
  final List<TransactionSplit> splits;

  SplitsLoaded(this.splits);

  @override
  List<Object?> get props => [splits];
}

class SplitSettled extends SplitState {
  final TransactionSplit split;

  SplitSettled(this.split);

  @override
  List<Object?> get props => [split];
}

class SplitError extends SplitState {
  final String message;

  SplitError(this.message);

  @override
  List<Object?> get props => [message];
}
