import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/transaction_split.dart';
import '../repositories/split_repository.dart';

class GetSplitsForTransactionUseCase {
  final SplitRepository repository;

  GetSplitsForTransactionUseCase(this.repository);

  Future<Either<Failure, List<TransactionSplit>>> call(
      String transactionId) async {
    if (transactionId.trim().isEmpty) {
      return const Left(ValidationFailure('Transaction ID is required'));
    }
    return await repository.getSplitsForTransaction(transactionId);
  }
}
