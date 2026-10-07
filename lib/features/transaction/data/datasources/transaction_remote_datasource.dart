import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../../domain/entities/transaction_search_params.dart';
import '../models/transaction_model.dart';

part 'transaction_remote_datasource.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class TransactionRemoteDataSource {
  factory TransactionRemoteDataSource(Dio dio, {String baseUrl}) =
      _TransactionRemoteDataSource;

  @GET('/api/budgets/{budgetId}/transactions')
  Future<ApiResponse<List<TransactionModel>>> getTransactions(
    @Path('budgetId') String budgetId,
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
    @Query('updatedSince') String? updatedSince,
  );

  @GET('/api/transactions/{id}')
  Future<ApiResponse<TransactionModel>> getTransactionById(
      @Path('id') String id);

  @POST('/api/budgets/{budgetId}/transactions')
  Future<ApiResponse<TransactionModel>> createTransaction(
    @Path('budgetId') String budgetId,
    @Body() Map<String, dynamic> body,
  );

  @PUT('/api/transactions/{id}')
  Future<ApiResponse<TransactionModel>> updateTransaction(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/transactions/{id}')
  Future<void> deleteTransaction(@Path('id') String id);
}

/// Separate class for transaction search using direct Dio calls,
/// since the search endpoint returns a paginated response structure
/// that does not fit the retrofit code-generation pattern cleanly.
class TransactionSearchRemoteDataSource {
  final Dio _dio;

  TransactionSearchRemoteDataSource(this._dio);

  Future<List<TransactionModel>> searchTransactions(
    String budgetId,
    TransactionSearchParams params,
  ) async {
    final response = await _dio.get(
      '/api/budgets/$budgetId/transactions/search',
      queryParameters: params.toQueryParameters(),
    );
    final responseData = response.data;
    final data = responseData['data']['content'] as List;
    return data
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
