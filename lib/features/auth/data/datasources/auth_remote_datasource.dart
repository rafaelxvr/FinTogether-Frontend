import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_constants.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio, {String baseUrl}) =
      _AuthRemoteDataSource;

  @POST(ApiConstants.register)
  Future<ApiResponse<AuthResponseModel>> register(
    @Body() Map<String, dynamic> body,
  );

  @POST(ApiConstants.login)
  Future<ApiResponse<AuthResponseModel>> login(
    @Body() Map<String, dynamic> body,
  );

  @POST(ApiConstants.refresh)
  Future<ApiResponse<AuthResponseModel>> refreshToken(
    @Body() Map<String, dynamic> body,
  );

  @GET(ApiConstants.me)
  Future<ApiResponse<UserModel>> getCurrentUser();

  @POST(ApiConstants.forgotPassword)
  Future<ApiResponse<String>> forgotPassword(
    @Body() Map<String, dynamic> body,
  );

  @POST(ApiConstants.resetPassword)
  Future<ApiResponse<String>> resetPassword(
    @Body() Map<String, dynamic> body,
  );
}
