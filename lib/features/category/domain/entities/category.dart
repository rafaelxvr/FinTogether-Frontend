import 'package:equatable/equatable.dart';

enum CategoryType {
  income,
  expense,
  transfer;

  String get displayName {
    switch (this) {
      case CategoryType.income:
        return 'Income';
      case CategoryType.expense:
        return 'Expense';
      case CategoryType.transfer:
        return 'Transfer';
    }
  }

  String get icon {
    switch (this) {
      case CategoryType.income:
        return '💰';
      case CategoryType.expense:
        return '💸';
      case CategoryType.transfer:
        return '🔄';
    }
  }
}

class Category extends Equatable {
  final String id;
  final String budgetId;
  final String name;
  final CategoryType type;
  final String? parentId;
  final String? icon;
  final String? color;
  final double? limitAmount;
  final bool archived;
  final bool isEssential;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool hasChildren;

  const Category({
    required this.id,
    required this.budgetId,
    required this.name,
    required this.type,
    this.parentId,
    this.icon,
    this.color,
    this.limitAmount,
    required this.archived,
    this.isEssential = false,
    required this.createdAt,
    this.updatedAt,
    required this.hasChildren,
  });

  // Computed properties
  bool get isArchived => archived;
  bool get isActive => !archived;
  bool get isRootCategory => parentId == null;
  bool get isSubcategory => parentId != null;
  bool get hasSubcategories => hasChildren;
  bool get hasLimit => limitAmount != null && limitAmount! > 0;

  // Type checks
  bool get isIncome => type == CategoryType.income;
  bool get isExpense => type == CategoryType.expense;
  bool get isTransfer => type == CategoryType.transfer;
  bool get isEssentialExpense => isExpense && isEssential;

  // Display helpers
  String get displayIcon => icon ?? type.icon;
  String get formattedLimit =>
      limitAmount != null ? 'BRL ${limitAmount!.toStringAsFixed(2)}' : 'No limit';

  @override
  List<Object?> get props => [
        id,
        budgetId,
        name,
        type,
        parentId,
        icon,
        color,
        limitAmount,
        archived,
        isEssential,
        createdAt,
        updatedAt,
        hasChildren,
      ];

  Category copyWith({
    String? id,
    String? budgetId,
    String? name,
    CategoryType? type,
    String? parentId,
    String? icon,
    String? color,
    double? limitAmount,
    bool? archived,
    bool? isEssential,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasChildren,
  }) {
    return Category(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      limitAmount: limitAmount ?? this.limitAmount,
      archived: archived ?? this.archived,
      isEssential: isEssential ?? this.isEssential,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasChildren: hasChildren ?? this.hasChildren,
    );
  }
}
