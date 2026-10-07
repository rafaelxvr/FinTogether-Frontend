import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/import_preview_row.dart';
import '../repositories/import_repository.dart';

class PreviewImportUseCase {
  final ImportRepository _repository;

  PreviewImportUseCase(this._repository);

  Future<Either<Failure, ImportPreviewResponse>> call({
    required String budgetId,
    required File file,
    String? profileId,
    Map<String, dynamic>? mapping,
  }) {
    return _repository.previewImport(
      budgetId: budgetId,
      file: file,
      profileId: profileId,
      mapping: mapping,
    );
  }
}
