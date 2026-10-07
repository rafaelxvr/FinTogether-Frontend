import 'package:equatable/equatable.dart';

enum AccountType {
  cash,
  checking,
  savings,
  creditCard,
  investment;

  String get displayName {
    switch (this) {
      case AccountType.cash:
        return 'Cash';
      case AccountType.checking:
        return 'Checking';
      case AccountType.savings:
        return 'Savings';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.investment:
        return 'Investment';
    }
  }

  String get icon {
    switch (this) {
      case AccountType.cash:
        return '💵';
      case AccountType.checking:
        return '🏦';
      case AccountType.savings:
        return '🐷';
      case AccountType.creditCard:
        return '💳';
      case AccountType.investment:
        return '📈';
    }
  }
}

class Account extends Equatable {
  final String id;
  final String budgetId;
  final String name;
  final AccountType type;
  final String currency;
  final double openingBalance;
  final double currentBalance;
  final bool active;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Account({
    required this.id,
    required this.budgetId,
    required this.name,
    required this.type,
    required this.currency,
    required this.openingBalance,
    required this.currentBalance,
    required this.active,
    required this.createdAt,
    this.updatedAt,
  });

  // Computed properties
  bool get isActive => active;
  bool get isInactive => !active;
  bool get hasBalance => currentBalance != 0;
  bool get isPositive => currentBalance > 0;
  bool get isNegative => currentBalance < 0;
  double get balanceChange => currentBalance - openingBalance;
  bool get hasGained => balanceChange > 0;
  bool get hasLost => balanceChange < 0;

  // Type checks
  bool get isCash => type == AccountType.cash;
  bool get isChecking => type == AccountType.checking;
  bool get isSavings => type == AccountType.savings;
  bool get isCreditCard => type == AccountType.creditCard;
  bool get isInvestment => type == AccountType.investment;

  // Business logic helpers
  String get formattedBalance => '$currency ${currentBalance.toStringAsFixed(2)}';
  String get formattedOpeningBalance =>
      '$currency ${openingBalance.toStringAsFixed(2)}';
  String get formattedBalanceChange {
    final change = balanceChange.abs();
    final sign = hasGained ? '+' : (hasLost ? '-' : '');
    return '$sign$currency ${change.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [
        id,
        budgetId,
        name,
        type,
        currency,
        openingBalance,
        currentBalance,
        active,
        createdAt,
        updatedAt,
      ];

  Account copyWith({
    String? id,
    String? budgetId,
    String? name,
    AccountType? type,
    String? currency,
    double? openingBalance,
    double? currentBalance,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
