import 'package:equatable/equatable.dart';

/// Credit Card Entity
/// Domain model for credit cards
class CreditCard extends Equatable {
  final String id;
  final String budgetId;
  final String name;
  final String? issuer;
  final String? lastFour;
  final String currency;
  final int statementCloseDay;
  final int dueDay;
  final String? linkedAccountId;
  final String? linkedAccountName;
  final double? creditLimit;
  final bool active;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CreditCard({
    required this.id,
    required this.budgetId,
    required this.name,
    this.issuer,
    this.lastFour,
    required this.currency,
    required this.statementCloseDay,
    required this.dueDay,
    this.linkedAccountId,
    this.linkedAccountName,
    this.creditLimit,
    required this.active,
    required this.createdAt,
    this.updatedAt,
  });

  /// Display name with last four digits if available
  String get displayName {
    if (issuer != null && lastFour != null) {
      return '$issuer ****$lastFour';
    } else if (lastFour != null) {
      return '$name ****$lastFour';
    }
    return name;
  }

  /// Check if card has linked account
  bool get hasLinkedAccount => linkedAccountId != null;

  /// Get status text
  String get statusText => active ? 'Active' : 'Inactive';

  /// Get statement info text
  String get statementInfo => 'Closes day $statementCloseDay, Due day $dueDay';

  /// Copy with method for immutability
  CreditCard copyWith({
    String? id,
    String? budgetId,
    String? name,
    String? issuer,
    String? lastFour,
    String? currency,
    int? statementCloseDay,
    int? dueDay,
    String? linkedAccountId,
    String? linkedAccountName,
    double? creditLimit,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditCard(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      lastFour: lastFour ?? this.lastFour,
      currency: currency ?? this.currency,
      statementCloseDay: statementCloseDay ?? this.statementCloseDay,
      dueDay: dueDay ?? this.dueDay,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      linkedAccountName: linkedAccountName ?? this.linkedAccountName,
      creditLimit: creditLimit ?? this.creditLimit,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        budgetId,
        name,
        issuer,
        lastFour,
        currency,
        statementCloseDay,
        dueDay,
        linkedAccountId,
        linkedAccountName,
        creditLimit,
        active,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'CreditCard(id: $id, name: $name, displayName: $displayName, active: $active)';
  }
}
