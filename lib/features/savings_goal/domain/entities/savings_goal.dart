import 'package:equatable/equatable.dart';

enum SavingsGoalStatus {
  active,
  completed,
  expired;

  String get displayName {
    switch (this) {
      case SavingsGoalStatus.active:
        return 'Active';
      case SavingsGoalStatus.completed:
        return 'Completed';
      case SavingsGoalStatus.expired:
        return 'Expired';
    }
  }
}

class SavingsGoal extends Equatable {
  final String id;
  final String budgetId;
  final String? accountId;
  final String name;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime? deadline;
  final String? icon;
  final String? color;
  final bool active;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SavingsGoal({
    required this.id,
    required this.budgetId,
    this.accountId,
    required this.name,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    this.deadline,
    this.icon,
    this.color,
    required this.active,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
  });

  // Computed properties
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  int get progressPercent => (progressPercentage * 100).toInt();

  bool get isCompleted => currentAmount >= targetAmount;

  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0, double.infinity);

  String get formattedTargetAmount =>
      '$currency ${targetAmount.toStringAsFixed(2)}';

  String get formattedCurrentAmount =>
      '$currency ${currentAmount.toStringAsFixed(2)}';

  String get formattedRemainingAmount =>
      '$currency ${remainingAmount.toStringAsFixed(2)}';

  int? get daysRemaining {
    if (deadline == null) return null;
    final days = deadline!.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  SavingsGoalStatus get status {
    if (isCompleted) return SavingsGoalStatus.completed;
    if (isExpired) return SavingsGoalStatus.expired;
    return SavingsGoalStatus.active;
  }

  bool get isExpired {
    if (deadline == null) return false;
    return deadline!.isBefore(DateTime.now()) && !isCompleted;
  }

  bool get isActive => active && !isCompleted && !isExpired;

  @override
  List<Object?> get props => [
        id,
        budgetId,
        accountId,
        name,
        description,
        targetAmount,
        currentAmount,
        currency,
        deadline,
        icon,
        color,
        active,
        completedAt,
        createdAt,
        updatedAt,
      ];

  SavingsGoal copyWith({
    String? id,
    String? budgetId,
    String? accountId,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    DateTime? deadline,
    String? icon,
    String? color,
    bool? active,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      deadline: deadline ?? this.deadline,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      active: active ?? this.active,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
