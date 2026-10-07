import 'package:equatable/equatable.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_goal_contribution.dart';

abstract class SavingsGoalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SavingsGoalInitial extends SavingsGoalState {}

class SavingsGoalLoading extends SavingsGoalState {}

class SavingsGoalsLoaded extends SavingsGoalState {
  final List<SavingsGoal> goals;

  SavingsGoalsLoaded(this.goals);

  @override
  List<Object?> get props => [goals];
}

class SavingsGoalLoaded extends SavingsGoalState {
  final SavingsGoal goal;

  SavingsGoalLoaded(this.goal);

  @override
  List<Object?> get props => [goal];
}

class SavingsGoalCreated extends SavingsGoalState {
  final SavingsGoal goal;

  SavingsGoalCreated(this.goal);

  @override
  List<Object?> get props => [goal];
}

class SavingsGoalUpdated extends SavingsGoalState {
  final SavingsGoal goal;

  SavingsGoalUpdated(this.goal);

  @override
  List<Object?> get props => [goal];
}

class SavingsGoalDeleted extends SavingsGoalState {}

class ContributionSuccess extends SavingsGoalState {
  final SavingsGoal updatedGoal;

  ContributionSuccess(this.updatedGoal);

  @override
  List<Object?> get props => [updatedGoal];
}

class WithdrawalSuccess extends SavingsGoalState {
  final SavingsGoal updatedGoal;

  WithdrawalSuccess(this.updatedGoal);

  @override
  List<Object?> get props => [updatedGoal];
}

class ContributionsLoaded extends SavingsGoalState {
  final List<SavingsGoalContribution> contributions;

  ContributionsLoaded(this.contributions);

  @override
  List<Object?> get props => [contributions];
}

class SavingsGoalError extends SavingsGoalState {
  final String message;

  SavingsGoalError(this.message);

  @override
  List<Object?> get props => [message];
}
