import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/card_monthly_cost_model.dart';
import 'card_cost_state.dart';

class CardCostNotifier extends StateNotifier<CardCostState> {
  final Dio _dio;

  CardCostNotifier({required Dio dio})
      : _dio = dio,
        super(const CardCostInitial());

  Future<void> loadAllCardsCost(String budgetId, {String? month}) async {
    state = const CardCostLoading();
    try {
      final response = await _dio.get(
        '/api/credit-cards/costs/summary',
        queryParameters: {
          'budgetId': budgetId,
          if (month != null) 'month': month,
        },
      );
      final model = AllCardsCostSummaryModel.fromJson(response.data);
      state = CardCostLoaded(costSummary: model.toEntity());
    } on DioException catch (e) {
      state = CardCostError(e.message ?? 'Failed to load card costs');
    } catch (e) {
      state = CardCostError('Failed to load card costs: $e');
    }
  }

  Future<void> loadCardComparison(String cardId, {int months = 6}) async {
    final currentState = state;
    try {
      final response = await _dio.get(
        '/api/credit-cards/$cardId/costs/comparison',
        queryParameters: {'months': months},
      );
      final model = CardCostComparisonModel.fromJson(response.data);
      if (currentState is CardCostLoaded) {
        state = currentState.copyWith(comparison: model.toEntity());
      } else {
        state = CardCostLoaded(comparison: model.toEntity());
      }
    } on DioException catch (e) {
      state = CardCostError(e.message ?? 'Failed to load cost comparison');
    } catch (e) {
      state = CardCostError('Failed to load cost comparison: $e');
    }
  }
}

final cardCostProvider =
    StateNotifierProvider<CardCostNotifier, CardCostState>((ref) {
  return CardCostNotifier(dio: getIt<DioClient>().dio);
});
