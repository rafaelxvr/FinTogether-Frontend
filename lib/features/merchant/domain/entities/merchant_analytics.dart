import 'package:equatable/equatable.dart';

class MerchantSpendingSummary extends Equatable {
  final String merchantId;
  final String merchantName;
  final double totalAmount;
  final int transactionCount;
  final double percentage;

  const MerchantSpendingSummary({
    required this.merchantId,
    required this.merchantName,
    required this.totalAmount,
    required this.transactionCount,
    required this.percentage,
  });

  String get formattedAmount => 'BRL ${totalAmount.toStringAsFixed(2)}';
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [
        merchantId,
        merchantName,
        totalAmount,
        transactionCount,
        percentage,
      ];
}

class TopMerchantsData extends Equatable {
  final String period;
  final List<MerchantSpendingSummary> summaries;
  final double totalSpend;

  const TopMerchantsData({
    required this.period,
    required this.summaries,
    required this.totalSpend,
  });

  String get formattedTotalSpend => 'BRL ${totalSpend.toStringAsFixed(2)}';
  bool get isEmpty => summaries.isEmpty;

  @override
  List<Object?> get props => [period, summaries, totalSpend];
}
