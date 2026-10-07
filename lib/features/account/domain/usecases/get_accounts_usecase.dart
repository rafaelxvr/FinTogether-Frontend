import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class GetAccountsUseCase {
  final AccountRepository repository;

  GetAccountsUseCase(this.repository);

  Future<Either<Failure, List<Account>>> call(String budgetId) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }
    return await repository.getAccounts(budgetId);
  }
}
