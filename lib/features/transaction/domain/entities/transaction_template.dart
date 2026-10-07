import 'package:equatable/equatable.dart';
import 'transaction.dart';

/// Template for saving transaction patterns for quick reuse
class TransactionTemplate extends Equatable {
  final String id;
  final String name;
  final double? amount;
  final TransactionType type;
  final String? categoryId;
  final String? accountId;
  final String? cardId;
  final String? description;
  final DateTime createdAt;

  const TransactionTemplate({
    required this.id,
    required this.name,
    this.amount,
    required this.type,
    this.categoryId,
    this.accountId,
    this.cardId,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'accountId': accountId,
      'cardId': cardId,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionTemplate.fromJson(Map<String, dynamic> json) {
    return TransactionTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      categoryId: json['categoryId'] as String?,
      accountId: json['accountId'] as String?,
      cardId: json['cardId'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, name, amount, type, categoryId, accountId, cardId, description, createdAt];
}
