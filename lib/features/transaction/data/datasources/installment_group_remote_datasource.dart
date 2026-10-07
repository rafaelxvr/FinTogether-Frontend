import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_constants.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/installment_group_model.dart';
import '../models/installment_progress_model.dart';

part 'installment_group_remote_datasource.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class InstallmentGroupRemoteDataSource {
  factory InstallmentGroupRemoteDataSource(Dio dio, {String baseUrl}) =
      _InstallmentGroupRemoteDataSource;

  @POST('/api/budgets/{budgetId}/installment-groups')
  Future<ApiResponse<InstallmentGroupModel>> createInstallmentGroup(
    @Path('budgetId') String budgetId,
    @Body() Map<String, dynamic> body,
  );

  @GET('/api/budgets/{budgetId}/installment-groups')
  Future<ApiResponse<List<InstallmentGroupModel>>> getInstallmentGroups(
    @Path('budgetId') String budgetId,
  );

  @GET('/api/installment-groups/{groupId}')
  Future<ApiResponse<InstallmentProgressModel>> getInstallmentProgress(
    @Path('groupId') String groupId,
  );

  @DELETE('/api/installment-groups/{groupId}')
  Future<void> deleteInstallmentGroup(
    @Path('groupId') String groupId,
  );
}
