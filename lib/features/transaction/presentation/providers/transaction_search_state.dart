import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_search_params.dart';

abstract class TransactionSearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TransactionSearchInitial extends TransactionSearchState {}

class TransactionSearchLoading extends TransactionSearchState {}

class TransactionSearchLoaded extends TransactionSearchState {
  final List<Transaction> results;
  final TransactionSearchParams params;
  final bool hasMore;

  TransactionSearchLoaded({
    required this.results,
    required this.params,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [results, params, hasMore];
}

class TransactionSearchEmpty extends TransactionSearchState {
  final TransactionSearchParams params;

  TransactionSearchEmpty({required this.params});

  @override
  List<Object?> get props => [params];
}

class TransactionSearchError extends TransactionSearchState {
  final String message;

  TransactionSearchError({required this.message});

  @override
  List<Object?> get props => [message];
}
