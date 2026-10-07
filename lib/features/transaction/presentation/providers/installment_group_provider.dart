import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/usecases/create_installment_group_usecase.dart';
import '../../domain/usecases/delete_installment_group_usecase.dart';
import '../../domain/usecases/get_installment_groups_usecase.dart';
import '../../domain/usecases/get_installment_progress_usecase.dart';
import 'installment_group_state.dart';

/// Installment Group Notifier
class InstallmentGroupNotifier extends StateNotifier<InstallmentGroupState> {
  final GetInstallmentGroupsUseCase getInstallmentGroupsUseCase;
  final CreateInstallmentGroupUseCase createInstallmentGroupUseCase;
  final GetInstallmentProgressUseCase getInstallmentProgressUseCase;
  final DeleteInstallmentGroupUseCase deleteInstallmentGroupUseCase;

  InstallmentGroupNotifier({
    required this.getInstallmentGroupsUseCase,
    required this.createInstallmentGroupUseCase,
    required this.getInstallmentProgressUseCase,
    required this.deleteInstallmentGroupUseCase,
  }) : super(const InstallmentGroupInitial());

  /// Load all installment groups for a budget
  Future<void> loadGroups(String budgetId) async {
    state = const InstallmentGroupLoading();

    final result = await getInstallmentGroupsUseCase(budgetId);

    result.fold(
      (failure) => state = InstallmentGroupError(failure.message),
      (groups) => state = InstallmentGroupsLoaded(groups),
    );
  }

  /// Create a new installment group
  Future<void> createGroup({
    required String budgetId,
    required double totalAmount,
    required int installmentCount,
    double interestRate = 0,
    required DateTime startDate,
    String? description,
    String? categoryId,
    String? accountId,
    String? cardId,
  }) async {
    state = const InstallmentGroupLoading();

    final result = await createInstallmentGroupUseCase(
      budgetId: budgetId,
      totalAmount: totalAmount,
      installmentCount: installmentCount,
      interestRate: interestRate,
      startDate: startDate,
      description: description,
      categoryId: categoryId,
      accountId: accountId,
      cardId: cardId,
    );

    result.fold(
      (failure) => state = InstallmentGroupError(failure.message),
      (group) {
        state = InstallmentGroupCreated(group);
        loadGroups(budgetId);
      },
    );
  }

  /// Load progress for a specific installment group
  Future<void> loadProgress(String groupId) async {
    state = const InstallmentGroupLoading();

    final result = await getInstallmentProgressUseCase(groupId);

    result.fold(
      (failure) => state = InstallmentGroupError(failure.message),
      (progress) => state = InstallmentProgressLoaded(progress),
    );
  }

  /// Delete an installment group
  Future<void> deleteGroup(String groupId, {String? budgetId}) async {
    state = const InstallmentGroupLoading();

    final result = await deleteInstallmentGroupUseCase(groupId);

    result.fold(
      (failure) => state = InstallmentGroupError(failure.message),
      (_) {
        state = const InstallmentGroupDeleted();
        if (budgetId != null) {
          loadGroups(budgetId);
        }
      },
    );
  }

  /// Reset to initial state
  void reset() {
    state = const InstallmentGroupInitial();
  }
}

/// Installment Group Provider
final installmentGroupProvider =
    StateNotifierProvider<InstallmentGroupNotifier, InstallmentGroupState>(
  (ref) {
    return InstallmentGroupNotifier(
      getInstallmentGroupsUseCase: getIt<GetInstallmentGroupsUseCase>(),
      createInstallmentGroupUseCase: getIt<CreateInstallmentGroupUseCase>(),
      getInstallmentProgressUseCase: getIt<GetInstallmentProgressUseCase>(),
      deleteInstallmentGroupUseCase: getIt<DeleteInstallmentGroupUseCase>(),
    );
  },
);
