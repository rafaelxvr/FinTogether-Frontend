import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/import_preview_row.dart';
import '../entities/import_profile.dart';
import '../entities/import_result.dart';

abstract class ImportRepository {
  Future<Either<Failure, List<ImportProfile>>> getProfiles(String budgetId);

  Future<Either<Failure, ImportProfile>> createProfile({
    required String budgetId,
    required String name,
    required Map<String, dynamic> mapping,
    String delimiter = ',',
    String encoding = 'UTF-8',
  });

  Future<Either<Failure, ImportPreviewResponse>> previewImport({
    required String budgetId,
    required File file,
    String? profileId,
    Map<String, dynamic>? mapping,
  });

  Future<Either<Failure, ImportResult>> confirmImport({
    required String budgetId,
    required List<int> selectedRowNumbers,
    String? accountId,
    String? profileId,
    Map<String, dynamic>? mapping,
    String? fileName,
  });

  Future<Either<Failure, List<ImportHistoryEntry>>> getImportHistory(
    String budgetId, {
    int page = 0,
    int size = 20,
  });
}
