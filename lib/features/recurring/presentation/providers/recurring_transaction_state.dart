import 'package:equatable/equatable.dart';

import '../../domain/entities/fixed_expense_summary.dart';
import '../../domain/entities/recurring_transaction_template.dart';

/// Recurring Transaction State
abstract class RecurringTransactionState extends Equatable {
  const RecurringTransactionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class RecurringInitial extends RecurringTransactionState {
  const RecurringInitial();
}

/// Loading state
class RecurringLoading extends RecurringTransactionState {
  const RecurringLoading();
}

/// Loaded state with list of templates
class TemplatesLoaded extends RecurringTransactionState {
  final List<RecurringTransactionTemplate> templates;

  const TemplatesLoaded(this.templates);

  @override
  List<Object?> get props => [templates];
}

/// State after successfully creating a template
class TemplateCreated extends RecurringTransactionState {
  final RecurringTransactionTemplate template;

  const TemplateCreated(this.template);

  @override
  List<Object?> get props => [template];
}

/// Loaded state with fixed expense summary
class FixedExpenseSummaryLoaded extends RecurringTransactionState {
  final FixedExpenseSummary summary;

  const FixedExpenseSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

/// Error state
class RecurringError extends RecurringTransactionState {
  final String message;

  const RecurringError(this.message);

  @override
  List<Object?> get props => [message];
}
