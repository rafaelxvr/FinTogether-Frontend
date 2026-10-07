import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../repositories/account_repository.dart';

class ToggleAccountStatusUseCase {
  final AccountRepository repository;

  ToggleAccountStatusUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String id,
    required bool active,
  }) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('Account ID is required'));
    }
    return await repository.toggleAccountStatus(id: id, active: active);
  }
}
