import 'package:equatable/equatable.dart';

enum BudgetMemberRole {
  owner,
  member,
  viewer,
}

class BudgetMember extends Equatable {
  final String id;
  final String budgetId;
  final String userId;
  final String userName;
  final String userEmail;
  final BudgetMemberRole role;
  final DateTime joinedAt;
  final DateTime? updatedAt;

  const BudgetMember({
    required this.id,
    required this.budgetId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.role,
    required this.joinedAt,
    this.updatedAt,
  });

  bool get isOwner => role == BudgetMemberRole.owner;
  bool get isMember => role == BudgetMemberRole.member;
  bool get isViewer => role == BudgetMemberRole.viewer;
  bool get canEdit => isOwner || isMember;
  bool get canView => true; // All roles can view

  BudgetMember copyWith({
    String? id,
    String? budgetId,
    String? userId,
    String? userName,
    String? userEmail,
    BudgetMemberRole? role,
    DateTime? joinedAt,
    DateTime? updatedAt,
  }) {
    return BudgetMember(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        budgetId,
        userId,
        userName,
        userEmail,
        role,
        joinedAt,
        updatedAt,
      ];
}
