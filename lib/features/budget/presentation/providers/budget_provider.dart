import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_member.dart';
import '../../domain/usecases/add_budget_member_usecase.dart';
import '../../domain/usecases/create_budget_usecase.dart';
import '../../domain/usecases/delete_budget_usecase.dart';
import '../../domain/usecases/get_budget_members_usecase.dart';
import '../../domain/usecases/get_budgets_usecase.dart';
import '../../domain/usecases/remove_budget_member_usecase.dart';
import '../../domain/usecases/update_budget_usecase.dart';
import 'budget_state.dart';

class BudgetNotifier extends StateNotifier<BudgetState> {
  final GetBudgetsUseCase getBudgetsUseCase;
  final CreateBudgetUseCase createBudgetUseCase;
  final UpdateBudgetUseCase updateBudgetUseCase;
  final DeleteBudgetUseCase deleteBudgetUseCase;
  final GetBudgetMembersUseCase getBudgetMembersUseCase;
  final AddBudgetMemberUseCase addBudgetMemberUseCase;
  final RemoveBudgetMemberUseCase removeBudgetMemberUseCase;

  List<Budget> _budgets = [];
  List<BudgetMember> _members = [];

  BudgetNotifier({
    required this.getBudgetsUseCase,
    required this.createBudgetUseCase,
    required this.updateBudgetUseCase,
    required this.deleteBudgetUseCase,
    required this.getBudgetMembersUseCase,
    required this.addBudgetMemberUseCase,
    required this.removeBudgetMemberUseCase,
  }) : super(BudgetInitial());

  List<Budget> get budgets => _budgets;
  List<BudgetMember> get members => _members;

  Future<void> loadBudgets() async {
    state = BudgetLoading();

    final result = await getBudgetsUseCase();

    result.fold(
      (failure) => state = BudgetError(failure.message),
      (budgets) {
        _budgets = budgets;
        state = BudgetsLoaded(budgets);
      },
    );
  }

  Future<void> createBudget({
    required String name,
    required BudgetType type,
  }) async {
    state = BudgetLoading();

    final result = await createBudgetUseCase(name: name, type: type);

    result.fold(
      (failure) => state = BudgetError(failure.message),
      (budget) {
        _budgets = [..._budgets, budget];
        state = BudgetCreated(budget);
        // Automatically reload budgets after creation
        loadBudgets();
      },
    );
  }

  Future<void> updateBudget({
    required String id,
    required String name,
    required BudgetType type,
  }) async {
    state = BudgetLoading();

    final result =
        await updateBudgetUseCase(id: id, name: name, type: type);

    result.fold(
      (failure) => state = BudgetError(failure.message),
      (budget) {
        _budgets = _budgets.map((b) => b.id == id ? budget : b).toList();
        state = BudgetUpdated(budget);
        // Reload budgets to get updated data
        loadBudgets();
      },
    );
  }

  Future<void> deleteBudget(String id) async {
    state = BudgetLoading();

    final result = await deleteBudgetUseCase(id);

    result.fold(
      (failure) => state = BudgetError(failure.message),
      (_) {
        _budgets = _budgets.where((b) => b.id != id).toList();
        state = BudgetDeleted();
        // Reload budgets
        loadBudgets();
      },
    );
  }

  Future<void> loadBudgetMembers(String budgetId) async {
    state = BudgetMembersLoading();

    final result = await getBudgetMembersUseCase(budgetId);

    result.fold(
      (failure) => state = BudgetError(failure.message),
      (members) {
        _members = members;
        state = BudgetMembersLoaded(members);
      },
    );
  }

  Future<void> addBudgetMember({
    required String budgetId,
    required String email,
    required BudgetMemberRole role,
  }) async {
    state = BudgetMembersLoading();

    final result = await addBudgetMemberUseCase(
      budgetId: budgetId,
      email: email,
      role: role,
    );

    result.fold(
      (failure) => state = BudgetError(failure.message),
      (member) {
        _members = [..._members, member];
        state = BudgetMemberAdded(member);
        // Reload members
        loadBudgetMembers(budgetId);
      },
    );
  }

  Future<void> removeBudgetMember({
    required String budgetId,
    required String memberId,
  }) async {
    state = BudgetMembersLoading();

    final result = await removeBudgetMemberUseCase(
      budgetId: budgetId,
      memberId: memberId,
    );

    result.fold(
      (failure) => state = BudgetError(failure.message),
      (_) {
        _members = _members.where((m) => m.id != memberId).toList();
        state = BudgetMemberRemoved();
        // Reload members
        loadBudgetMembers(budgetId);
      },
    );
  }
}

// Provider
final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  return BudgetNotifier(
    getBudgetsUseCase: getIt<GetBudgetsUseCase>(),
    createBudgetUseCase: getIt<CreateBudgetUseCase>(),
    updateBudgetUseCase: getIt<UpdateBudgetUseCase>(),
    deleteBudgetUseCase: getIt<DeleteBudgetUseCase>(),
    getBudgetMembersUseCase: getIt<GetBudgetMembersUseCase>(),
    addBudgetMemberUseCase: getIt<AddBudgetMemberUseCase>(),
    removeBudgetMemberUseCase: getIt<RemoveBudgetMemberUseCase>(),
  );
});
