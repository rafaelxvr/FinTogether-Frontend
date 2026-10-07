import '../../domain/entities/dashboard_alerts.dart';

class DashboardAlertModel {
  final String type;
  final String title;
  final String? message;
  final String severity;
  final Map<String, dynamic>? metadata;

  const DashboardAlertModel({
    required this.type,
    required this.title,
    this.message,
    required this.severity,
    this.metadata,
  });

  factory DashboardAlertModel.fromJson(Map<String, dynamic> json) {
    return DashboardAlertModel(
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String?,
      severity: json['severity'] as String? ?? 'info',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  DashboardAlert toEntity() {
    return DashboardAlert(
      type: type,
      title: title,
      message: message,
      severity: severity,
      metadata: metadata,
    );
  }
}

class DashboardAlertsReportModel {
  final List<DashboardAlertModel> lowBalanceAlerts;
  final List<DashboardAlertModel> categoryLimitAlerts;
  final List<DashboardAlertModel> creditCardDueAlerts;

  const DashboardAlertsReportModel({
    required this.lowBalanceAlerts,
    required this.categoryLimitAlerts,
    required this.creditCardDueAlerts,
  });

  factory DashboardAlertsReportModel.fromJson(Map<String, dynamic> json) {
    return DashboardAlertsReportModel(
      lowBalanceAlerts: (json['lowBalanceAlerts'] as List? ?? [])
          .map((e) => DashboardAlertModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryLimitAlerts: (json['categoryLimitAlerts'] as List? ?? [])
          .map((e) => DashboardAlertModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      creditCardDueAlerts: (json['creditCardDueAlerts'] as List? ?? [])
          .map((e) => DashboardAlertModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  DashboardAlertsReport toEntity() {
    return DashboardAlertsReport(
      lowBalanceAlerts: lowBalanceAlerts.map((e) => e.toEntity()).toList(),
      categoryLimitAlerts: categoryLimitAlerts.map((e) => e.toEntity()).toList(),
      creditCardDueAlerts: creditCardDueAlerts.map((e) => e.toEntity()).toList(),
    );
  }
}
