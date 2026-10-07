import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/account.dart';
import '../../domain/usecases/create_account_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_account_by_id_usecase.dart';
import '../../domain/usecases/get_accounts_usecase.dart';
import '../../domain/usecases/toggle_account_status_usecase.dart';
import '../../domain/usecases/transfer_usecase.dart';
import '../../domain/usecases/update_account_usecase.dart';
import 'account_state.dart';

class AccountNotifier extends StateNotifier<AccountState> {
  final GetAccountsUseCase getAccountsUseCase;
  final GetAccountByIdUseCase getAccountByIdUseCase;
  final CreateAccountUseCase createAccountUseCase;
  final UpdateAccountUseCase updateAccountUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final TransferUseCase transferUseCase;
  final ToggleAccountStatusUseCase toggleAccountStatusUseCase;

  List<Account> _accounts = [];

  AccountNotifier({
    required this.getAccountsUseCase,
    required this.getAccountByIdUseCase,
    required this.createAccountUseCase,
    required this.updateAccountUseCase,
    required this.deleteAccountUseCase,
    required this.transferUseCase,
    required this.toggleAccountStatusUseCase,
  }) : super(AccountInitial());

  Future<void> loadAccounts(String budgetId) async {
    state = AccountLoading();
    final result = await getAccountsUseCase(budgetId);
    result.fold(
      (failure) => state = AccountError(failure.message),
      (accounts) {
        _accounts = accounts;
        state = AccountsLoaded(accounts);
      },
    );
  }

  Future<void> getAccountById(String id) async {
    state = AccountLoading();
    final result = await getAccountByIdUseCase(id);
    result.fold(
      (failure) => state = AccountError(failure.message),
      (account) => state = AccountLoaded(account),
    );
  }

  Future<void> createAccount({
    required String budgetId,
    required String name,
    required AccountType type,
    String currency = 'BRL',
    double openingBalance = 0.0,
  }) async {
    state = AccountLoading();
    final result = await createAccountUseCase(
      budgetId: budgetId,
      name: name,
      type: type,
      currency: currency,
      openingBalance: openingBalance,
    );
    result.fold(
      (failure) => state = AccountError(failure.message),
      (account) {
        _accounts = [..._accounts, account];
        state = AccountCreated(account);
        // Auto-reload to get fresh data
        loadAccounts(budgetId);
      },
    );
  }

  Future<void> updateAccount({
    required String budgetId,
    required String id,
    required String name,
    required String currency,
  }) async {
    state = AccountLoading();
    final result = await updateAccountUseCase(
      id: id,
      name: name,
      currency: currency,
    );
    result.fold(
      (failure) => state = AccountError(failure.message),
      (account) {
        _accounts = _accounts
            .map((a) => a.id == account.id ? account : a)
            .toList();
        state = AccountUpdated(account);
        // Auto-reload to get fresh data
        loadAccounts(budgetId);
      },
    );
  }

  Future<void> deleteAccount({
    required String budgetId,
    required String id,
  }) async {
    state = AccountLoading();
    final result = await deleteAccountUseCase(id);
    result.fold(
      (failure) => state = AccountError(failure.message),
      (_) {
        _accounts = _accounts.where((a) => a.id != id).toList();
        state = AccountDeleted();
        // Auto-reload to get fresh data
        loadAccounts(budgetId);
      },
    );
  }

  Future<void> transfer({
    required String budgetId,
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? description,
  }) async {
    state = AccountLoading();
    final result = await transferUseCase(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      description: description,
    );
    result.fold(
      (failure) => state = AccountError(failure.message),
      (_) {
        state = TransferCompleted();
        // Auto-reload to get updated balances
        loadAccounts(budgetId);
      },
    );
  }

  Future<void> toggleAccountStatus({
    required String budgetId,
    required String id,
    required bool active,
  }) async {
    state = AccountLoading();
    final result = await toggleAccountStatusUseCase(id: id, active: active);
    result.fold(
      (failure) => state = AccountError(failure.message),
      (_) {
        state = AccountStatusToggled();
        // Auto-reload to get fresh data
        loadAccounts(budgetId);
      },
    );
  }

  List<Account> get accounts => _accounts;
  List<Account> get activeAccounts =>
      _accounts.where((a) => a.active).toList();
  List<Account> get inactiveAccounts =>
      _accounts.where((a) => !a.active).toList();
}

final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>(
  (ref) => AccountNotifier(
    getAccountsUseCase: getIt<GetAccountsUseCase>(),
    getAccountByIdUseCase: getIt<GetAccountByIdUseCase>(),
    createAccountUseCase: getIt<CreateAccountUseCase>(),
    updateAccountUseCase: getIt<UpdateAccountUseCase>(),
    deleteAccountUseCase: getIt<DeleteAccountUseCase>(),
    transferUseCase: getIt<TransferUseCase>(),
    toggleAccountStatusUseCase: getIt<ToggleAccountStatusUseCase>(),
  ),
);
