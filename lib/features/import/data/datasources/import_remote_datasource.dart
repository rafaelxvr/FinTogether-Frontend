import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/import_preview_row_model.dart';
import '../models/import_profile_model.dart';
import '../../domain/entities/import_result.dart';

class ImportRemoteDataSource {
  final Dio _dio;

  ImportRemoteDataSource(this._dio);

  Future<List<ImportProfileModel>> getProfiles(String budgetId) async {
    final response = await _dio.get('/api/budgets/$budgetId/import/profiles');
    final data = response.data['data'] as List;
    return data
        .map((e) => ImportProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ImportProfileModel> createProfile(
    String budgetId,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post(
      '/api/budgets/$budgetId/import/profiles',
      data: body,
    );
    return ImportProfileModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<ImportPreviewResponseModel> previewImport({
    required String budgetId,
    required File file,
    String? profileId,
    Map<String, dynamic>? mapping,
  }) async {
    final requestJson = jsonEncode({
      if (profileId != null) 'profileId': profileId,
      if (mapping != null) 'mapping': mapping,
    });

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
          filename: file.path.split(Platform.pathSeparator).last),
      'request': MultipartFile.fromString(requestJson,
          contentType: DioMediaType('application', 'json')),
    });

    final response = await _dio.post(
      '/api/budgets/$budgetId/import/preview',
      data: formData,
    );

    return ImportPreviewResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> confirmImport(
    String budgetId,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post(
      '/api/budgets/$budgetId/import/confirm',
      data: body,
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<ImportHistoryEntry>> getImportHistory(
    String budgetId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/api/budgets/$budgetId/import/history',
      queryParameters: {'page': page, 'size': size},
    );
    final content = response.data['data']['content'] as List;
    return content.map((e) {
      final json = e as Map<String, dynamic>;
      return ImportHistoryEntry(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        totalRows: json['totalRows'] as int,
        importedRows: json['importedRows'] as int,
        skippedRows: json['skippedRows'] as int,
        duplicateRows: json['duplicateRows'] as int,
        status: json['status'] as String,
        errorMessage: json['errorMessage'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
    }).toList();
  }
}
