import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/account_model.dart';

part 'account_remote_datasource.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class AccountRemoteDataSource {
  factory AccountRemoteDataSource(Dio dio, {String baseUrl}) =
      _AccountRemoteDataSource;

  /// Get all accounts for a budget, optionally filtered by updatedSince
  @GET('/api/budgets/{budgetId}/accounts')
  Future<ApiResponse<List<AccountModel>>> getAccounts(
    @Path('budgetId') String budgetId,
    @Query('updatedSince') String? updatedSince,
  );

  /// Get account by ID
  @GET('/api/accounts/{id}')
  Future<ApiResponse<AccountModel>> getAccountById(@Path('id') String id);

  /// Create account
  @POST('/api/budgets/{budgetId}/accounts')
  Future<ApiResponse<AccountModel>> createAccount(
    @Path('budgetId') String budgetId,
    @Body() Map<String, dynamic> body,
  );

  /// Update account
  @PUT('/api/accounts/{id}')
  Future<ApiResponse<AccountModel>> updateAccount(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Delete account
  @DELETE('/api/accounts/{id}')
  Future<void> deleteAccount(@Path('id') String id);

  /// Activate account
  @POST('/api/accounts/{id}/activate')
  Future<ApiResponse<AccountModel>> activateAccount(@Path('id') String id);

  /// Deactivate account
  @POST('/api/accounts/{id}/deactivate')
  Future<ApiResponse<AccountModel>> deactivateAccount(@Path('id') String id);

  /// Transfer between accounts
  @POST('/api/accounts/transfer')
  Future<void> transfer(@Body() Map<String, dynamic> body);
}
