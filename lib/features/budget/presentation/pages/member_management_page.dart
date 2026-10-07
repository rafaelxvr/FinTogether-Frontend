import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_member.dart';
import '../providers/budget_provider.dart';
import '../providers/budget_state.dart';

class MemberManagementPage extends ConsumerStatefulWidget {
  final String budgetId;

  const MemberManagementPage({
    super.key,
    required this.budgetId,
  });

  @override
  ConsumerState<MemberManagementPage> createState() => _MemberManagementPageState();
}

class _MemberManagementPageState extends ConsumerState<MemberManagementPage> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(budgetProvider.notifier).loadBudgets(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetProvider);
    final budgetNotifier = ref.read(budgetProvider.notifier);
    final budgets = budgetState is BudgetsLoaded
        ? budgetState.budgets
        : budgetNotifier.budgets;

    final budget = budgets.where((b) => b.id == widget.budgetId).firstOrNull;

    if (budget == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Members'),
        ),
        body: const Center(
          child: Text('Budget not found'),
        ),
      );
    }

    // For now, we'll show mock members since the actual member data
    // might need to be fetched separately
    final members = _getMockMembers(budget);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddMemberDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Members can view and edit budget data. Viewers can only view.',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: members.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: members.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return _buildMemberTile(context, member, budget);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMemberDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
      ),
    );
  }

  Widget _buildMemberTile(BuildContext context, BudgetMember member, Budget budget) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: _getRoleColor(member.role).withOpacity(0.2),
        child: Icon(
          _getRoleIcon(member.role),
          color: _getRoleColor(member.role),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              member.userName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor(member.role).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getRoleColor(member.role).withOpacity(0.3),
              ),
            ),
            child: Text(
              _getRoleLabel(member.role),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _getRoleColor(member.role),
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(member.userEmail),
          const SizedBox(height: 2),
          Text(
            'Joined ${dateFormat.format(member.joinedAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      trailing: member.isOwner
          ? null
          : PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'change_role') {
                  _showChangeRoleDialog(context, member);
                } else if (value == 'remove') {
                  _confirmRemoveMember(context, member);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'change_role',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz),
                      SizedBox(width: 8),
                      Text('Change Role'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remove', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No members yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add members to collaborate on this budget',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'user@example.com',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            const Text(
              'The user will receive an invitation to join this budget.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement add member logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Member invitation feature coming soon'),
                ),
              );
              _emailController.clear();
            },
            child: const Text('Send Invitation'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, BudgetMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Member'),
              subtitle: const Text('Can view and edit budget data'),
              leading: Radio<BudgetMemberRole>(
                value: BudgetMemberRole.member,
                groupValue: member.role,
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateMemberRole(member, value!);
                },
              ),
            ),
            ListTile(
              title: const Text('Viewer'),
              subtitle: const Text('Can only view budget data'),
              leading: Radio<BudgetMemberRole>(
                value: BudgetMemberRole.viewer,
                groupValue: member.role,
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateMemberRole(member, value!);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveMember(BuildContext context, BudgetMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove ${member.userName} from this budget?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeMember(member);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateMemberRole(BudgetMember member, BudgetMemberRole newRole) {
    // Implement role update logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.userName} role updated to ${_getRoleLabel(newRole)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeMember(BudgetMember member) {
    // Implement remove member logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.userName} removed from budget'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  IconData _getRoleIcon(BudgetMemberRole role) {
    switch (role) {
      case BudgetMemberRole.owner:
        return Icons.star;
      case BudgetMemberRole.member:
        return Icons.person;
      case BudgetMemberRole.viewer:
        return Icons.visibility;
    }
  }

  Color _getRoleColor(BudgetMemberRole role) {
    switch (role) {
      case BudgetMemberRole.owner:
        return Colors.amber;
      case BudgetMemberRole.member:
        return Colors.blue;
      case BudgetMemberRole.viewer:
        return Colors.grey;
    }
  }

  String _getRoleLabel(BudgetMemberRole role) {
    switch (role) {
      case BudgetMemberRole.owner:
        return 'OWNER';
      case BudgetMemberRole.member:
        return 'MEMBER';
      case BudgetMemberRole.viewer:
        return 'VIEWER';
    }
  }

  List<BudgetMember> _getMockMembers(Budget budget) {
    // Return mock members for demonstration
    // In a real implementation, this would fetch from the backend
    return [
      BudgetMember(
        id: '1',
        budgetId: budget.id,
        userId: budget.ownerId,
        userName: budget.ownerName,
        userEmail: 'owner@example.com',
        role: BudgetMemberRole.owner,
        joinedAt: budget.createdAt,
      ),
    ];
  }
}
