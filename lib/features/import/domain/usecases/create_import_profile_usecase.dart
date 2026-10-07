import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/import_profile.dart';
import '../repositories/import_repository.dart';

class CreateImportProfileUseCase {
  final ImportRepository _repository;

  CreateImportProfileUseCase(this._repository);

  Future<Either<Failure, ImportProfile>> call({
    required String budgetId,
    required String name,
    required Map<String, dynamic> mapping,
    String delimiter = ',',
    String encoding = 'UTF-8',
  }) {
    return _repository.createProfile(
      budgetId: budgetId,
      name: name,
      mapping: mapping,
      delimiter: delimiter,
      encoding: encoding,
    );
  }
}
