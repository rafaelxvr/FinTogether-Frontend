import 'package:equatable/equatable.dart';

class DashboardAlertsReport extends Equatable {
  final List<DashboardAlert> lowBalanceAlerts;
  final List<DashboardAlert> categoryLimitAlerts;
  final List<DashboardAlert> creditCardDueAlerts;

  const DashboardAlertsReport({
    required this.lowBalanceAlerts,
    required this.categoryLimitAlerts,
    required this.creditCardDueAlerts,
  });

  List<DashboardAlert> get allAlerts => [
        ...lowBalanceAlerts,
        ...categoryLimitAlerts,
        ...creditCardDueAlerts,
      ];

  bool get hasAlerts => allAlerts.isNotEmpty;

  @override
  List<Object?> get props => [lowBalanceAlerts, categoryLimitAlerts, creditCardDueAlerts];
}

class DashboardAlert extends Equatable {
  final String type; // 'low_balance', 'category_limit', 'credit_card_due'
  final String title;
  final String? message;
  final String severity; // 'info', 'warning', 'critical'
  final Map<String, dynamic>? metadata;

  const DashboardAlert({
    required this.type,
    required this.title,
    this.message,
    required this.severity,
    this.metadata,
  });

  @override
  List<Object?> get props => [type, title, message, severity];
}
