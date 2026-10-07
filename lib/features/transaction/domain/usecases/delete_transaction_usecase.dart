import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Transaction ID is required'));
    }
    return await repository.deleteTransaction(id);
  }
}
