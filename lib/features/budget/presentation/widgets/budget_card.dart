import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/budget.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onManageMembers;

  const BudgetCard({
    super.key,
    required this.budget,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onManageMembers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildIcon(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        _buildSubtitle(context),
                      ],
                    ),
                  ),
                  _buildTypeChip(context),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'members':
                          onManageMembers?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      if (budget.isShared)
                        const PopupMenuItem(
                          value: 'members',
                          child: Row(
                            children: [
                              Icon(Icons.people, size: 20),
                              SizedBox(width: 12),
                              Text('Manage Members'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (budget.isShared && budget.hasMembers) ...[
                const SizedBox(height: 12),
                _buildMemberInfo(context),
              ],
              const SizedBox(height: 8),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: budget.isShared
            ? Colors.purple.withOpacity(0.1)
            : Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        budget.isShared ? Icons.people : Icons.person,
        color: budget.isShared ? Colors.purple : Theme.of(context).primaryColor,
        size: 28,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          budget.ownerName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildTypeChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: budget.isShared ? Colors.purple[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: budget.isShared ? Colors.purple[200]! : Colors.blue[200]!,
        ),
      ),
      child: Text(
        budget.isShared ? 'Shared' : 'Personal',
        style: TextStyle(
          color: budget.isShared ? Colors.purple[700] : Colors.blue[700],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMemberInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.group, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            '${budget.memberCount} member${budget.memberCount != 1 ? 's' : ''}',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          'Created ${dateFormat.format(budget.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}
