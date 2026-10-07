import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/account.dart';

abstract class AccountRepository {
  /// Get all accounts for a budget
  Future<Either<Failure, List<Account>>> getAccounts(String budgetId);

  /// Get account by ID
  Future<Either<Failure, Account>> getAccountById(String id);

  /// Create new account
  Future<Either<Failure, Account>> createAccount({
    required String budgetId,
    required String name,
    required AccountType type,
    String currency = 'BRL',
    double openingBalance = 0.0,
  });

  /// Update existing account
  Future<Either<Failure, Account>> updateAccount({
    required String id,
    required String name,
    required String currency,
  });

  /// Delete account
  Future<Either<Failure, void>> deleteAccount(String id);

  /// Transfer between accounts
  Future<Either<Failure, void>> transfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? description,
  });

  /// Toggle account active status
  Future<Either<Failure, void>> toggleAccountStatus({
    required String id,
    required bool active,
  });
}
