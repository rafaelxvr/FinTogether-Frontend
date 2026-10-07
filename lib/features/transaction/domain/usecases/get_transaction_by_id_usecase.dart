import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionByIdUseCase {
  final TransactionRepository repository;

  GetTransactionByIdUseCase(this.repository);

  Future<Either<Failure, Transaction>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Transaction ID is required'));
    }
    return await repository.getTransactionById(id);
  }
}
