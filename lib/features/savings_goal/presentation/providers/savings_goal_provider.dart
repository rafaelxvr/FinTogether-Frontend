import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/usecases/create_savings_goal_usecase.dart';
import '../../domain/usecases/contribute_to_savings_goal_usecase.dart';
import '../../domain/usecases/delete_savings_goal_usecase.dart';
import '../../domain/usecases/get_contributions_usecase.dart';
import '../../domain/usecases/get_savings_goal_by_id_usecase.dart';
import '../../domain/usecases/get_savings_goals_usecase.dart';
import '../../domain/usecases/update_savings_goal_usecase.dart';
import '../../domain/usecases/withdraw_from_savings_goal_usecase.dart';
import 'savings_goal_state.dart';

class SavingsGoalNotifier extends StateNotifier<SavingsGoalState> {
  final GetSavingsGoalsUseCase getSavingsGoalsUseCase;
  final GetSavingsGoalByIdUseCase getSavingsGoalByIdUseCase;
  final CreateSavingsGoalUseCase createSavingsGoalUseCase;
  final UpdateSavingsGoalUseCase updateSavingsGoalUseCase;
  final DeleteSavingsGoalUseCase deleteSavingsGoalUseCase;
  final ContributeToSavingsGoalUseCase contributeUseCase;
  final WithdrawFromSavingsGoalUseCase withdrawUseCase;
  final GetContributionsUseCase getContributionsUseCase;

  List<SavingsGoal> _goals = [];

  SavingsGoalNotifier({
    required this.getSavingsGoalsUseCase,
    required this.getSavingsGoalByIdUseCase,
    required this.createSavingsGoalUseCase,
    required this.updateSavingsGoalUseCase,
    required this.deleteSavingsGoalUseCase,
    required this.contributeUseCase,
    required this.withdrawUseCase,
    required this.getContributionsUseCase,
  }) : super(SavingsGoalInitial());

  Future<void> loadSavingsGoals(String budgetId) async {
    state = SavingsGoalLoading();
    final result = await getSavingsGoalsUseCase(budgetId);
    result.fold(
      (failure) => state = SavingsGoalError(failure.message),
      (goals) {
        _goals = goals;
        state = SavingsGoalsLoaded(goals);
      },
    );
  }

  Future<void> getSavingsGoalById(String id) async {
    state = SavingsGoalLoading();
    final result = await getSavingsGoalByIdUseCase(id);
    result.fold(
      (failure) => state = SavingsGoalError(failure.message),
      (goal) => state = SavingsGoalLoaded(goal),
    );
  }

  Future<void> createSavingsGoal({
    required String budgetId,
    required String name,
    String? description,
    required double targetAmount,
    String currency = 'BRL',
    DateTime? deadline,
    String? accountId,
    String? icon,
    String? color,
  }) async {
    state = SavingsGoalLoading();
    final result = await createSavingsGoalUseCase(
      budgetId: budgetId,
      name: name,
      description: description,
      targetAmount: targetAmount,
      currency: currency,
      deadline: deadline,
      accountId: accountId,
      icon: icon,
      color: color,
    );
    result.fold(
      (failure) => state = SavingsGoalError(failure.message),
      (goal) {
        _goals = [..._goals, goal];
        state = SavingsGoalCreated(goal);
        loadSavingsGoals(budgetId);
      },
    );
  }

  Future<void> updateSavingsGoal({
    required String budgetId,
    required String id,
    required String name,
    String? description,
    double? targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
  }) async {
    state = SavingsGoalLoading();
    final result = await updateSavingsGoalUseCase(
      id: id,
      name: name,
      description: description,
      targetAmount: targetAmount,
      deadline: deadline,
      icon: icon,
      color: color,
    );
    result.fold(
      (failure) => state = SavingsGoalError(failure.message),
      (goal) {
        _goals = _goals.map((g) => g.id == goal.id ? goal : g).toList();
        state = SavingsGoalUpdated(goal);
        loadSavingsGoals(budgetId);
      },
    );
  }

  Future<void> deleteSavingsGoal({
    required String budgetId,
    required String id,
  }) async {
    state = SavingsGoalLoading();
    final result = await deleteSavingsGoalUseCase(id);
    result.fold(
      (failure) => state = SavingsGoalError(failure.message),
      (_) {
        _goals = _goals.where((g) => g.id != id).toList();
        state = SavingsGoalDeleted();
        loadSavingsGoals(budgetId);
      },
    );
  }

  Future<void> contribute({
    required String budgetId,
    required String id,
    required double amount,
    String? note,
  }) async {
    state = SavingsGoalLoading();
    final result = await contributeUseCase(
      id: id,
      amount: amount,
      note: note,
    );
    result.fold(
      (failure) => state = SavingsGoalError(failure.message),
      (goal) {
        _goals = _goals.map((g) => g.id == goal.id ? goal : g).toList();
        state = ContributionSuccess(goal);
        loadSavingsGoals(budgetId);
      },
    );
  }

  Future<void> withdraw({
    required String budgetId,
    required String id,
    required double amount,
    String? note,
  }) async {
    state = SavingsGoalLoading();
    final result = await withdrawUseCase(
      id: id,
      amount: amount,
      note: note,
    );
    result.fold(
      (failure) => state = SavingsGoalError(failure.message),
      (goal) {
        _goals = _goals.map((g) => g.id == goal.id ? goal : g).toList();
        state = WithdrawalSuccess(goal);
        loadSavingsGoals(budgetId);
      },
    );
  }

  Future<void> loadContributions(String savingsGoalId) async {
    state = SavingsGoalLoading();
    final result = await getContributionsUseCase(savingsGoalId);
    result.fold(
      (failure) => state = SavingsGoalError(failure.message),
      (contributions) => state = ContributionsLoaded(contributions),
    );
  }

  List<SavingsGoal> get goals => _goals;

  List<SavingsGoal> get activeGoals =>
      _goals.where((g) => g.active && !g.isCompleted).toList();

  List<SavingsGoal> get completedGoals =>
      _goals.where((g) => g.isCompleted).toList();

  double get totalSavedAmount =>
      _goals.fold(0.0, (sum, g) => sum + g.currentAmount);

  double get totalTargetAmount =>
      _goals.fold(0.0, (sum, g) => sum + g.targetAmount);

  double get overallProgress {
    if (totalTargetAmount <= 0) return 0.0;
    return (totalSavedAmount / totalTargetAmount).clamp(0.0, 1.0);
  }
}

final savingsGoalProvider =
    StateNotifierProvider<SavingsGoalNotifier, SavingsGoalState>(
  (ref) => SavingsGoalNotifier(
    getSavingsGoalsUseCase: getIt<GetSavingsGoalsUseCase>(),
    getSavingsGoalByIdUseCase: getIt<GetSavingsGoalByIdUseCase>(),
    createSavingsGoalUseCase: getIt<CreateSavingsGoalUseCase>(),
    updateSavingsGoalUseCase: getIt<UpdateSavingsGoalUseCase>(),
    deleteSavingsGoalUseCase: getIt<DeleteSavingsGoalUseCase>(),
    contributeUseCase: getIt<ContributeToSavingsGoalUseCase>(),
    withdrawUseCase: getIt<WithdrawFromSavingsGoalUseCase>(),
    getContributionsUseCase: getIt<GetContributionsUseCase>(),
  ),
);
