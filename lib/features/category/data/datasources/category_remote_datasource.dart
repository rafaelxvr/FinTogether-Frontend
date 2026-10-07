import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/category_model.dart';

part 'category_remote_datasource.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class CategoryRemoteDataSource {
  factory CategoryRemoteDataSource(Dio dio, {String baseUrl}) =
      _CategoryRemoteDataSource;

  /// Get all categories for a budget with optional type and updatedSince filter
  @GET('/api/budgets/{budgetId}/categories')
  Future<ApiResponse<List<CategoryModel>>> getCategories(
    @Path('budgetId') String budgetId,
    @Query('type') String? type,
    @Query('updatedSince') String? updatedSince,
  );

  /// Get root categories (without parent)
  @GET('/api/budgets/{budgetId}/categories/root')
  Future<ApiResponse<List<CategoryModel>>> getRootCategories(
    @Path('budgetId') String budgetId,
  );

  /// Get category by ID
  @GET('/api/categories/{id}')
  Future<ApiResponse<CategoryModel>> getCategoryById(@Path('id') String id);

  /// Create category
  @POST('/api/budgets/{budgetId}/categories')
  Future<ApiResponse<CategoryModel>> createCategory(
    @Path('budgetId') String budgetId,
    @Body() Map<String, dynamic> body,
  );

  /// Update category
  @PUT('/api/categories/{id}')
  Future<ApiResponse<CategoryModel>> updateCategory(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Delete category
  @DELETE('/api/categories/{id}')
  Future<void> deleteCategory(@Path('id') String id);

  /// Archive category
  @POST('/api/categories/{id}/archive')
  Future<ApiResponse<CategoryModel>> archiveCategory(@Path('id') String id);

  /// Unarchive category
  @POST('/api/categories/{id}/unarchive')
  Future<ApiResponse<CategoryModel>> unarchiveCategory(@Path('id') String id);
}
