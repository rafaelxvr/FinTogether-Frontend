import 'package:equatable/equatable.dart';

class Merchant extends Equatable {
  final String id;
  final String budgetId;
  final String name;
  final String? displayName;
  final String? logoUrl;
  final String? color;
  final String? defaultCategoryId;
  final bool archived;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Merchant({
    required this.id,
    required this.budgetId,
    required this.name,
    this.displayName,
    this.logoUrl,
    this.color,
    this.defaultCategoryId,
    required this.archived,
    required this.createdAt,
    this.updatedAt,
  });

  // Computed properties
  bool get isArchived => archived;
  bool get isActive => !archived;
  String get effectiveDisplayName => displayName ?? name;
  bool get hasDefaultCategory => defaultCategoryId != null;

  @override
  List<Object?> get props => [
        id,
        budgetId,
        name,
        displayName,
        logoUrl,
        color,
        defaultCategoryId,
        archived,
        createdAt,
        updatedAt,
      ];

  Merchant copyWith({
    String? id,
    String? budgetId,
    String? name,
    String? displayName,
    String? logoUrl,
    String? color,
    String? defaultCategoryId,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Merchant(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      logoUrl: logoUrl ?? this.logoUrl,
      color: color ?? this.color,
      defaultCategoryId: defaultCategoryId ?? this.defaultCategoryId,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
