import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/transaction_split.dart';
import '../repositories/split_repository.dart';

class SettleSplitUseCase {
  final SplitRepository repository;

  SettleSplitUseCase(this.repository);

  Future<Either<Failure, TransactionSplit>> call(String splitId) async {
    if (splitId.trim().isEmpty) {
      return const Left(ValidationFailure('Split ID is required'));
    }
    return await repository.settleSplit(splitId);
  }
}
