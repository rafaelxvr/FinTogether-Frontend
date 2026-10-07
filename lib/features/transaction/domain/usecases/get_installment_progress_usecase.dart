import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../entities/installment_progress.dart';
import '../repositories/installment_group_repository.dart';

class GetInstallmentProgressUseCase {
  final InstallmentGroupRepository repository;

  GetInstallmentProgressUseCase(this.repository);

  Future<Either<Failure, InstallmentProgress>> call(String groupId) async {
    if (groupId.trim().isEmpty) {
      return const Left(ValidationFailure('Group ID is required'));
    }

    return await repository.getInstallmentProgress(groupId);
  }
}
