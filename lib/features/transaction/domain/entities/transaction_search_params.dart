import 'package:equatable/equatable.dart';

class TransactionSearchParams extends Equatable {
  final String? query;
  final String? type; // 'INCOME' | 'EXPENSE'
  final String? categoryId;
  final String? merchantId;
  final double? minAmount;
  final double? maxAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int size;

  const TransactionSearchParams({
    this.query,
    this.type,
    this.categoryId,
    this.merchantId,
    this.minAmount,
    this.maxAmount,
    this.startDate,
    this.endDate,
    this.page = 0,
    this.size = 20,
  });

  bool get hasActiveFilters =>
      type != null ||
      categoryId != null ||
      merchantId != null ||
      minAmount != null ||
      maxAmount != null ||
      startDate != null ||
      endDate != null;

  int get activeFilterCount {
    int count = 0;
    if (type != null) count++;
    if (categoryId != null) count++;
    if (merchantId != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    if (startDate != null || endDate != null) count++;
    return count;
  }

  TransactionSearchParams copyWith({
    String? query,
    String? type,
    String? categoryId,
    String? merchantId,
    double? minAmount,
    double? maxAmount,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? size,
    bool clearQuery = false,
    bool clearType = false,
    bool clearCategoryId = false,
    bool clearMerchantId = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return TransactionSearchParams(
      query: clearQuery ? null : (query ?? this.query),
      type: clearType ? null : (type ?? this.type),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      merchantId: clearMerchantId ? null : (merchantId ?? this.merchantId),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  TransactionSearchParams clearAllFilters() {
    return TransactionSearchParams(
      query: query,
      page: 0,
      size: size,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    if (query != null && query!.isNotEmpty) params['q'] = query;
    if (type != null) params['type'] = type;
    if (categoryId != null) params['categoryId'] = categoryId;
    if (merchantId != null) params['merchantId'] = merchantId;
    if (minAmount != null) params['minAmount'] = minAmount.toString();
    if (maxAmount != null) params['maxAmount'] = maxAmount.toString();
    if (startDate != null) {
      params['startDate'] = startDate!.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      params['endDate'] = endDate!.toIso8601String().split('T')[0];
    }
    params['page'] = page.toString();
    params['size'] = size.toString();
    return params;
  }

  @override
  List<Object?> get props => [
        query,
        type,
        categoryId,
        merchantId,
        minAmount,
        maxAmount,
        startDate,
        endDate,
        page,
        size,
      ];
}
