import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cashflow_trend.dart';

part 'cashflow_trend_model.g.dart';

/// Cashflow Trend Model
/// Data layer model for JSON serialization/deserialization
@JsonSerializable(explicitToJson: true)
class CashflowTrendModel {
  final String budgetId;
  final List<MonthlyDataModel> months;

  const CashflowTrendModel({
    required this.budgetId,
    required this.months,
  });

  /// Create model from JSON
  factory CashflowTrendModel.fromJson(Map<String, dynamic> json) =>
      _$CashflowTrendModelFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$CashflowTrendModelToJson(this);

  /// Convert model to domain entity
  CashflowTrend toEntity() {
    return CashflowTrend(
      budgetId: budgetId,
      months: months.map((model) => model.toEntity()).toList(),
    );
  }

  /// Create model from domain entity
  factory CashflowTrendModel.fromEntity(CashflowTrend entity) {
    return CashflowTrendModel(
      budgetId: entity.budgetId,
      months: entity.months.map((e) => MonthlyDataModel.fromEntity(e)).toList(),
    );
  }
}

/// Monthly Data Model
@JsonSerializable()
class MonthlyDataModel {
  final String period; // "2025-11"
  final String yearMonth; // ISO format date string for yearMonth
  final double income;
  final double expense;
  final double net;
  final int transactionCount;

  const MonthlyDataModel({
    required this.period,
    required this.yearMonth,
    required this.income,
    required this.expense,
    required this.net,
    required this.transactionCount,
  });

  factory MonthlyDataModel.fromJson(Map<String, dynamic> json) =>
      _$MonthlyDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyDataModelToJson(this);

  MonthlyData toEntity() {
    // Parse yearMonth string to DateTime
    // Backend sends [2025, 11] format, we convert to DateTime
    final date = _parseYearMonth(yearMonth);

    return MonthlyData(
      period: period,
      yearMonth: date,
      income: income,
      expense: expense,
      net: net,
      transactionCount: transactionCount,
    );
  }

  factory MonthlyDataModel.fromEntity(MonthlyData entity) {
    return MonthlyDataModel(
      period: entity.period,
      yearMonth: '${entity.yearMonth.year}-${entity.yearMonth.month.toString().padLeft(2, '0')}-01',
      income: entity.income,
      expense: entity.expense,
      net: entity.net,
      transactionCount: entity.transactionCount,
    );
  }

  /// Parse year-month to DateTime
  /// Handles both string format "2025-11" and array format [2025, 11]
  static DateTime _parseYearMonth(dynamic yearMonth) {
    if (yearMonth is String) {
      // String format: "2025-11" or "2025-11-01"
      if (yearMonth.contains('-')) {
        final parts = yearMonth.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        return DateTime(year, month, 1);
      }
    } else if (yearMonth is List) {
      // Array format: [2025, 11]
      final year = (yearMonth[0] as num).toInt();
      final month = (yearMonth[1] as num).toInt();
      return DateTime(year, month, 1);
    }

    // Fallback: try parsing as ISO string
    try {
      return DateTime.parse(yearMonth.toString());
    } catch (e) {
      // If all else fails, return current month
      return DateTime.now();
    }
  }
}
