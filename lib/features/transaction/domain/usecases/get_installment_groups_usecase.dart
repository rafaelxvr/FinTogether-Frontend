import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../entities/installment_group.dart';
import '../repositories/installment_group_repository.dart';

class GetInstallmentGroupsUseCase {
  final InstallmentGroupRepository repository;

  GetInstallmentGroupsUseCase(this.repository);

  Future<Either<Failure, List<InstallmentGroup>>> call(String budgetId) async {
    if (budgetId.trim().isEmpty) {
      return const Left(ValidationFailure('Budget ID is required'));
    }

    return await repository.getInstallmentGroups(budgetId);
  }
}
