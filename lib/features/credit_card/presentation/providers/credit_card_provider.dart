import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/credit_card_usecases.dart';
import 'credit_card_state.dart';

/// Credit Card Notifier
class CreditCardNotifier extends StateNotifier<CreditCardState> {
  final GetCreditCardsUseCase getCreditCardsUseCase;
  final CreateCreditCardUseCase createCreditCardUseCase;
  final UpdateCreditCardUseCase updateCreditCardUseCase;
  final DeleteCreditCardUseCase deleteCreditCardUseCase;
  final ToggleCreditCardStatusUseCase toggleStatusUseCase;

  CreditCardNotifier({
    required this.getCreditCardsUseCase,
    required this.createCreditCardUseCase,
    required this.updateCreditCardUseCase,
    required this.deleteCreditCardUseCase,
    required this.toggleStatusUseCase,
  }) : super(const CreditCardInitial());

  /// Load credit cards for a budget
  Future<void> loadCreditCards(String budgetId,
      {bool activeOnly = false}) async {
    state = const CreditCardLoading();

    final result = await getCreditCardsUseCase(budgetId, activeOnly: activeOnly);

    result.fold(
      (failure) => state = CreditCardError(failure.message),
      (creditCards) => state = CreditCardLoaded(creditCards),
    );
  }

  /// Create a new credit card
  Future<void> createCreditCard({
    required String budgetId,
    required String name,
    String? issuer,
    String? lastFour,
    String currency = 'BRL',
    required int statementCloseDay,
    required int dueDay,
    String? linkedAccountId,
  }) async {
    final result = await createCreditCardUseCase(
      budgetId: budgetId,
      name: name,
      issuer: issuer,
      lastFour: lastFour,
      currency: currency,
      statementCloseDay: statementCloseDay,
      dueDay: dueDay,
      linkedAccountId: linkedAccountId,
    );

    await result.fold(
      (failure) async => state = CreditCardError(failure.message),
      (card) async {
        // Reload list after creation
        await loadCreditCards(budgetId);
        if (state is CreditCardLoaded) {
          state = CreditCardOperationSuccess(
            'Credit card created successfully',
            (state as CreditCardLoaded).creditCards,
          );
        }
      },
    );
  }

  /// Update a credit card
  Future<void> updateCreditCard(
    String id,
    String budgetId, {
    String? name,
    String? issuer,
    String? lastFour,
    String? currency,
    int? statementCloseDay,
    int? dueDay,
    String? linkedAccountId,
  }) async {
    final result = await updateCreditCardUseCase(
      id,
      name: name,
      issuer: issuer,
      lastFour: lastFour,
      currency: currency,
      statementCloseDay: statementCloseDay,
      dueDay: dueDay,
      linkedAccountId: linkedAccountId,
    );

    await result.fold(
      (failure) async => state = CreditCardError(failure.message),
      (card) async {
        // Reload list after update
        await loadCreditCards(budgetId);
        if (state is CreditCardLoaded) {
          state = CreditCardOperationSuccess(
            'Credit card updated successfully',
            (state as CreditCardLoaded).creditCards,
          );
        }
      },
    );
  }

  /// Delete a credit card
  Future<void> deleteCreditCard(String id, String budgetId) async {
    final result = await deleteCreditCardUseCase(id);

    await result.fold(
      (failure) async => state = CreditCardError(failure.message),
      (_) async {
        // Reload list after deletion
        await loadCreditCards(budgetId);
        if (state is CreditCardLoaded) {
          state = CreditCardOperationSuccess(
            'Credit card deleted successfully',
            (state as CreditCardLoaded).creditCards,
          );
        }
      },
    );
  }

  /// Toggle credit card active status
  Future<void> toggleStatus(String id, bool active, String budgetId) async {
    final result = await toggleStatusUseCase(id, active);

    await result.fold(
      (failure) async => state = CreditCardError(failure.message),
      (card) async {
        // Reload list after toggle
        await loadCreditCards(budgetId);
        if (state is CreditCardLoaded) {
          final statusText = active ? 'activated' : 'deactivated';
          state = CreditCardOperationSuccess(
            'Credit card $statusText successfully',
            (state as CreditCardLoaded).creditCards,
          );
        }
      },
    );
  }

  /// Clear success message and return to loaded state
  void clearSuccess() {
    if (state is CreditCardOperationSuccess) {
      state = CreditCardLoaded(
          (state as CreditCardOperationSuccess).creditCards);
    }
  }

  /// Reset to initial state
  void reset() {
    state = const CreditCardInitial();
  }
}

/// Credit Card Provider
final creditCardProvider =
    StateNotifierProvider<CreditCardNotifier, CreditCardState>(
  (ref) {
    return CreditCardNotifier(
      getCreditCardsUseCase: getIt<GetCreditCardsUseCase>(),
      createCreditCardUseCase: getIt<CreateCreditCardUseCase>(),
      updateCreditCardUseCase: getIt<UpdateCreditCardUseCase>(),
      deleteCreditCardUseCase: getIt<DeleteCreditCardUseCase>(),
      toggleStatusUseCase: getIt<ToggleCreditCardStatusUseCase>(),
    );
  },
);
