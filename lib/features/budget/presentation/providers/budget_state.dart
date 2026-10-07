import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_member.dart';

abstract class BudgetState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state
class BudgetInitial extends BudgetState {}

// Loading states
class BudgetLoading extends BudgetState {}

class BudgetMembersLoading extends BudgetState {}

// Success states
class BudgetsLoaded extends BudgetState {
  final List<Budget> budgets;

  BudgetsLoaded(this.budgets);

  @override
  List<Object?> get props => [budgets];
}

class BudgetCreated extends BudgetState {
  final Budget budget;

  BudgetCreated(this.budget);

  @override
  List<Object?> get props => [budget];
}

class BudgetUpdated extends BudgetState {
  final Budget budget;

  BudgetUpdated(this.budget);

  @override
  List<Object?> get props => [budget];
}

class BudgetDeleted extends BudgetState {}

class BudgetMembersLoaded extends BudgetState {
  final List<BudgetMember> members;

  BudgetMembersLoaded(this.members);

  @override
  List<Object?> get props => [members];
}

class BudgetMemberAdded extends BudgetState {
  final BudgetMember member;

  BudgetMemberAdded(this.member);

  @override
  List<Object?> get props => [member];
}

class BudgetMemberRemoved extends BudgetState {}

// Error state
class BudgetError extends BudgetState {
  final String message;

  BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}
