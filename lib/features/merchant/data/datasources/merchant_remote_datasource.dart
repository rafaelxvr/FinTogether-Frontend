import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/merchant_model.dart';

part 'merchant_remote_datasource.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class MerchantRemoteDataSource {
  factory MerchantRemoteDataSource(Dio dio, {String baseUrl}) =
      _MerchantRemoteDataSource;

  /// Get all merchants for a budget
  @GET('/api/budgets/{budgetId}/merchants')
  Future<ApiResponse<List<MerchantModel>>> getMerchants(
    @Path('budgetId') String budgetId,
  );

  /// Search merchants by name (autocomplete)
  @GET('/api/budgets/{budgetId}/merchants/search')
  Future<ApiResponse<List<MerchantModel>>> searchMerchants(
    @Path('budgetId') String budgetId,
    @Query('q') String query,
  );

  /// Get merchant by ID
  @GET('/api/merchants/{id}')
  Future<ApiResponse<MerchantModel>> getMerchantById(@Path('id') String id);

  /// Create merchant
  @POST('/api/budgets/{budgetId}/merchants')
  Future<ApiResponse<MerchantModel>> createMerchant(
    @Path('budgetId') String budgetId,
    @Body() Map<String, dynamic> body,
  );

  /// Update merchant
  @PUT('/api/merchants/{id}')
  Future<ApiResponse<MerchantModel>> updateMerchant(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Delete merchant
  @DELETE('/api/merchants/{id}')
  Future<void> deleteMerchant(@Path('id') String id);

  /// Archive merchant
  @POST('/api/merchants/{id}/archive')
  Future<ApiResponse<MerchantModel>> archiveMerchant(@Path('id') String id);

  /// Unarchive merchant
  @POST('/api/merchants/{id}/unarchive')
  Future<ApiResponse<MerchantModel>> unarchiveMerchant(@Path('id') String id);

  /// Get top merchants analytics
  @GET('/api/budgets/{budgetId}/merchants/analytics/top')
  Future<ApiResponse<List<MerchantModel>>> getTopMerchants(
    @Path('budgetId') String budgetId,
    @Query('startDate') String startDate,
    @Query('endDate') String endDate,
    @Query('limit') int limit,
  );
}
