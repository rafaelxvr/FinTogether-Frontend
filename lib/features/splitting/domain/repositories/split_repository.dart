import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/member_balance.dart';
import '../entities/transaction_split.dart';

abstract class SplitRepository {
  Future<Either<Failure, List<TransactionSplit>>> getSplitsForTransaction(
      String transactionId);

  Future<Either<Failure, List<MemberBalance>>> getBalances(String budgetId);

  Future<Either<Failure, TransactionSplit>> settleSplit(String splitId);
}
