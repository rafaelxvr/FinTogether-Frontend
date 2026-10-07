import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class GetAccountByIdUseCase {
  final AccountRepository repository;

  GetAccountByIdUseCase(this.repository);

  Future<Either<Failure, Account>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Account ID is required'));
    }
    return await repository.getAccountById(id);
  }
}
