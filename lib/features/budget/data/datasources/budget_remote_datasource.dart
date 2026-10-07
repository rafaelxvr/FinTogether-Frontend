import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/budget_model.dart';
import '../models/budget_member_model.dart';

part 'budget_remote_datasource.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class BudgetRemoteDataSource {
  factory BudgetRemoteDataSource(Dio dio, {String baseUrl}) =
      _BudgetRemoteDataSource;

  /// Get all budgets, optionally filtered by updatedSince
  @GET(ApiConstants.budgets)
  Future<ApiResponse<List<BudgetModel>>> getBudgets(
    @Query('updatedSince') String? updatedSince,
  );

  /// Get budget by ID
  @GET('${ApiConstants.budgets}/{id}')
  Future<ApiResponse<BudgetModel>> getBudgetById(@Path('id') String id);

  /// Create budget
  @POST(ApiConstants.budgets)
  Future<ApiResponse<BudgetModel>> createBudget(
    @Body() Map<String, dynamic> body,
  );

  /// Update budget
  @PUT('${ApiConstants.budgets}/{id}')
  Future<ApiResponse<BudgetModel>> updateBudget(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Delete budget
  @DELETE('${ApiConstants.budgets}/{id}')
  Future<void> deleteBudget(@Path('id') String id);

  /// Get budget members
  @GET('${ApiConstants.budgets}/{id}/members')
  Future<ApiResponse<List<BudgetMemberModel>>> getBudgetMembers(
    @Path('id') String budgetId,
  );

  /// Add budget member
  @POST('${ApiConstants.budgets}/{id}/members')
  Future<ApiResponse<BudgetMemberModel>> addBudgetMember(
    @Path('id') String budgetId,
    @Body() Map<String, dynamic> body,
  );

  /// Remove budget member
  @DELETE('${ApiConstants.budgets}/{budgetId}/members/{memberId}')
  Future<void> removeBudgetMember(
    @Path('budgetId') String budgetId,
    @Path('memberId') String memberId,
  );
}
