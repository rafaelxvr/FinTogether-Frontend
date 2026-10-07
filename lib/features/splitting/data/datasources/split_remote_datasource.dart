import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/data/models/auth_response_model.dart';
import '../models/transaction_split_model.dart';
import '../models/member_balance_model.dart';

part 'split_remote_datasource.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class SplitRemoteDataSource {
  factory SplitRemoteDataSource(Dio dio, {String baseUrl}) =
      _SplitRemoteDataSource;

  /// Get all splits for a transaction
  @GET('/api/transactions/{transactionId}/splits')
  Future<ApiResponse<List<TransactionSplitModel>>> getSplitsForTransaction(
    @Path('transactionId') String transactionId,
  );

  /// Get balance summary for a budget
  @GET('/api/budgets/{budgetId}/splits/balances')
  Future<ApiResponse<BalanceSummaryResponseModel>> getBalances(
    @Path('budgetId') String budgetId,
  );

  /// Settle a split
  @POST('/api/splits/{splitId}/settle')
  Future<ApiResponse<TransactionSplitModel>> settleSplit(
    @Path('splitId') String splitId,
  );
}

/// Wraps the balance summary response from the API
class BalanceSummaryResponseModel {
  final String budgetId;
  final List<MemberBalanceModel> entries;

  BalanceSummaryResponseModel({
    required this.budgetId,
    required this.entries,
  });

  factory BalanceSummaryResponseModel.fromJson(Map<String, dynamic> json) {
    return BalanceSummaryResponseModel(
      budgetId: json['budgetId'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => MemberBalanceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
