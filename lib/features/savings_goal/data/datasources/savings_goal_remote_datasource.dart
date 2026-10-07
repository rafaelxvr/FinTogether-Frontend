import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/savings_goal_model.dart';
import '../models/savings_goal_contribution_model.dart';

part 'savings_goal_remote_datasource.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class SavingsGoalRemoteDataSource {
  factory SavingsGoalRemoteDataSource(Dio dio, {String baseUrl}) =
      _SavingsGoalRemoteDataSource;

  /// Get all savings goals for a budget
  @GET('/api/budgets/{budgetId}/savings-goals')
  Future<ApiResponse<List<SavingsGoalModel>>> getSavingsGoals(
    @Path('budgetId') String budgetId,
  );

  /// Get savings goal by ID
  @GET('/api/savings-goals/{id}')
  Future<ApiResponse<SavingsGoalModel>> getSavingsGoalById(
      @Path('id') String id);

  /// Create savings goal
  @POST('/api/budgets/{budgetId}/savings-goals')
  Future<ApiResponse<SavingsGoalModel>> createSavingsGoal(
    @Path('budgetId') String budgetId,
    @Body() Map<String, dynamic> body,
  );

  /// Update savings goal
  @PUT('/api/savings-goals/{id}')
  Future<ApiResponse<SavingsGoalModel>> updateSavingsGoal(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Delete savings goal
  @DELETE('/api/savings-goals/{id}')
  Future<void> deleteSavingsGoal(@Path('id') String id);

  /// Contribute to savings goal
  @POST('/api/savings-goals/{id}/contribute')
  Future<ApiResponse<SavingsGoalModel>> contribute(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Withdraw from savings goal
  @POST('/api/savings-goals/{id}/withdraw')
  Future<ApiResponse<SavingsGoalModel>> withdraw(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Get contributions for a savings goal
  @GET('/api/savings-goals/{id}/contributions')
  Future<ApiResponse<List<SavingsGoalContributionModel>>> getContributions(
    @Path('id') String id,
  );
}
