import 'package:dio/dio.dart';

/// Remote data source for recurring transaction operations.
class RecurringTransactionRemoteDataSource {
  final Dio dio;

  RecurringTransactionRemoteDataSource(this.dio);

  Future<List<Map<String, dynamic>>> getTemplates(String budgetId) async {
    final response = await dio.get('/budgets/$budgetId/recurring-templates');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> getTemplateById(String id) async {
    final response = await dio.get('/recurring-templates/$id');
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> createTemplate(
    Map<String, dynamic> data,
  ) async {
    final response = await dio.post('/recurring-templates', data: data);
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> updateTemplate(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await dio.put('/recurring-templates/$id', data: data);
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> deactivateTemplate(String id) async {
    await dio.patch('/recurring-templates/$id/deactivate');
  }

  Future<void> deleteTemplate(String id) async {
    await dio.delete('/recurring-templates/$id');
  }

  Future<List<Map<String, dynamic>>> getFixedExpenses(
    String budgetId,
  ) async {
    final response = await dio.get(
      '/budgets/$budgetId/recurring-templates/fixed-expenses',
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> getFixedExpenseSummary(
    String budgetId,
  ) async {
    final response = await dio.get(
      '/budgets/$budgetId/fixed-expense-summary',
    );
    return Map<String, dynamic>.from(response.data);
  }
}
