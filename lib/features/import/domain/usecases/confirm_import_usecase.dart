import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/import_result.dart';
import '../repositories/import_repository.dart';

class ConfirmImportUseCase {
  final ImportRepository _repository;

  ConfirmImportUseCase(this._repository);

  Future<Either<Failure, ImportResult>> call({
    required String budgetId,
    required List<int> selectedRowNumbers,
    String? accountId,
    String? profileId,
    Map<String, dynamic>? mapping,
    String? fileName,
  }) {
    return _repository.confirmImport(
      budgetId: budgetId,
      selectedRowNumbers: selectedRowNumbers,
      accountId: accountId,
      profileId: profileId,
      mapping: mapping,
      fileName: fileName,
    );
  }
}
