import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/member_balance.dart';
import '../repositories/split_repository.dart';

class GetBalancesUseCase {
  final SplitRepository repository;

  GetBalancesUseCase(this.repository);

  Future<Either<Failure, List<MemberBalance>>> call(String budgetId) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }
    return await repository.getBalances(budgetId);
  }
}
