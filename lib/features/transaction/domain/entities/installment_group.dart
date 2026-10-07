import 'dart:math';

import 'package:equatable/equatable.dart';

class InstallmentGroup extends Equatable {
  final String id;
  final String budgetId;
  final String? cardId;
  final double totalAmount;
  final int installmentCount;
  final double interestRate;
  final DateTime startDate;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const InstallmentGroup({
    required this.id,
    required this.budgetId,
    this.cardId,
    required this.totalAmount,
    required this.installmentCount,
    required this.interestRate,
    required this.startDate,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  // Computed properties
  double get totalWithInterest => interestRate > 0
      ? totalAmount * pow(1 + interestRate / 100, installmentCount)
      : totalAmount;

  double get installmentAmount => totalAmount / installmentCount;

  bool get hasCard => cardId != null;
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasInterest => interestRate > 0;

  String get formattedTotalAmount => 'BRL ${totalAmount.toStringAsFixed(2)}';
  String get formattedInstallmentAmount =>
      'BRL ${installmentAmount.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        id,
        budgetId,
        cardId,
        totalAmount,
        installmentCount,
        interestRate,
        startDate,
        description,
        createdAt,
        updatedAt,
      ];

  InstallmentGroup copyWith({
    String? id,
    String? budgetId,
    String? cardId,
    double? totalAmount,
    int? installmentCount,
    double? interestRate,
    DateTime? startDate,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InstallmentGroup(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      cardId: cardId ?? this.cardId,
      totalAmount: totalAmount ?? this.totalAmount,
      installmentCount: installmentCount ?? this.installmentCount,
      interestRate: interestRate ?? this.interestRate,
      startDate: startDate ?? this.startDate,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
