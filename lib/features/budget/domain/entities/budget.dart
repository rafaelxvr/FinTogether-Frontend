import 'package:equatable/equatable.dart';

enum BudgetType {
  personal,
  shared,
}

class Budget extends Equatable {
  final String id;
  final String name;
  final BudgetType type;
  final String ownerId;
  final String ownerName;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.name,
    required this.type,
    required this.ownerId,
    required this.ownerName,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPersonal => type == BudgetType.personal;
  bool get isShared => type == BudgetType.shared;
  bool get hasMembers => memberCount > 1;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        ownerId,
        ownerName,
        memberCount,
        createdAt,
        updatedAt,
      ];
}
