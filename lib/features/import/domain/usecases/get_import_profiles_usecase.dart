import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/import_profile.dart';
import '../repositories/import_repository.dart';

class GetImportProfilesUseCase {
  final ImportRepository _repository;

  GetImportProfilesUseCase(this._repository);

  Future<Either<Failure, List<ImportProfile>>> call(String budgetId) {
    return _repository.getProfiles(budgetId);
  }
}
