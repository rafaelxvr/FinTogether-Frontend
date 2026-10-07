import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../repositories/installment_group_repository.dart';

class DeleteInstallmentGroupUseCase {
  final InstallmentGroupRepository repository;

  DeleteInstallmentGroupUseCase(this.repository);

  Future<Either<Failure, void>> call(String groupId) async {
    if (groupId.trim().isEmpty) {
      return const Left(ValidationFailure('Group ID is required'));
    }

    return await repository.deleteInstallmentGroup(groupId);
  }
}
