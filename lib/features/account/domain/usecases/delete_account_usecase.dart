import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../repositories/account_repository.dart';

class DeleteAccountUseCase {
  final AccountRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Account ID is required'));
    }
    return await repository.deleteAccount(id);
  }
}
