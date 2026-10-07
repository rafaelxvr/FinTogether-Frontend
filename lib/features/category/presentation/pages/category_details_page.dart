import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/category.dart';
import '../providers/category_provider.dart';
import '../providers/category_state.dart';

class CategoryDetailsPage extends ConsumerStatefulWidget {
  final String budgetId;
  final String categoryId;

  const CategoryDetailsPage({
    super.key,
    required this.budgetId,
    required this.categoryId,
  });

  @override
  ConsumerState<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends ConsumerState<CategoryDetailsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(categoryProvider.notifier).loadCategories(budgetId: widget.budgetId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoryState = ref.watch(categoryProvider);
    final notifier = ref.read(categoryProvider.notifier);
    final categories = categoryState is CategoriesLoaded
        ? categoryState.categories
        : notifier.categories;

    final category = categories.where((c) => c.id == widget.categoryId).firstOrNull;

    if (category == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.categoryDetails),
        ),
        body: Center(
          child: Text(l10n.categoryNotFound),
        ),
      );
    }

    final subcategories = categories.where((c) => c.parentId == widget.categoryId).toList();
    final parentCategory = category.isSubcategory
        ? categories.where((c) => c.id == category.parentId).firstOrNull
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit category page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.featureComingSoon(l10n.editCategory))),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'archive') {
                _toggleArchiveStatus(category);
              } else if (value == 'delete') {
                _confirmDelete(context, category);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(
                      category.isArchived ? Icons.unarchive : Icons.archive,
                      color: category.isArchived ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(category.isArchived ? l10n.unarchive : l10n.archive),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.deleteCategory),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(category, parentCategory),
            const SizedBox(height: 16),
            _buildInfoCard(category),
            const SizedBox(height: 16),
            if (category.hasLimit) _buildLimitCard(category),
            if (category.hasLimit) const SizedBox(height: 16),
            if (subcategories.isNotEmpty) _buildSubcategoriesCard(subcategories),
            if (subcategories.isNotEmpty) const SizedBox(height: 16),
            _buildQuickActionsCard(context, category),
            const SizedBox(height: 16),
            _buildTransactionsSummaryCard(),
          ],
        ),
      ),
      floatingActionButton: category.isRootCategory && !category.hasSubcategories
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.featureComingSoon(l10n.addSubcategory))),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.addSubcategory),
            )
          : null,
    );
  }

  Widget _buildHeaderCard(Category category, Category? parentCategory) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: category.color != null && category.color!.isNotEmpty
          ? _parseColor(category.color!)
          : Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  category.displayIcon,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.type.displayName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (category.isArchived)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.archived,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (parentCategory != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.subdirectory_arrow_right, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      l10n.subcategoryOf(parentCategory.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Category category) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.categoryInformation,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            _buildInfoRow(l10n.type, category.type.displayName),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.status, category.isActive ? l10n.active : l10n.archived),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.structure, category.isRootCategory ? l10n.rootCategory : l10n.subcategory),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.hasSubcategories, category.hasSubcategories ? l10n.yes : l10n.no),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.created, dateFormat.format(category.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitCard(Category category) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.budgetLimit,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.monthlyLimit,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.formattedLimit,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const LinearProgressIndicator(
              value: 0.0, // This would be calculated based on actual spending
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.spentPercent('BRL', '0.00', '0'),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoriesCard(List<Category> subcategories) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.nSubcategories(subcategories.length),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.featureComingSoon(l10n.addSubcategory))),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...subcategories.map((subcat) => ListTile(
                  leading: Text(
                    subcat.displayIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(subcat.name),
                  subtitle: Text(subcat.type.displayName),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.go('/budgets/${widget.budgetId}/categories/${subcat.id}/details');
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, Category category) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickActions,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context,
              icon: Icons.add_circle,
              title: l10n.addTransaction,
              subtitle: l10n.createTransactionInCategory,
              color: Colors.green,
              onTap: () {
                context.go('/budgets/${widget.budgetId}/transactions/create?categoryId=${widget.categoryId}');
              },
            ),
            _buildActionTile(
              context,
              icon: Icons.receipt_long,
              title: l10n.viewTransactions,
              subtitle: l10n.viewAllTransactions,
              color: Colors.blue,
              onTap: () {
                context.go('/budgets/${widget.budgetId}/transactions?categoryId=${widget.categoryId}');
              },
            ),
            _buildActionTile(
              context,
              icon: Icons.pie_chart,
              title: l10n.viewReports,
              subtitle: l10n.categorySpendingAnalysis,
              color: Colors.purple,
              onTap: () {
                context.go('/dashboard/${widget.budgetId}');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildTransactionsSummaryCard() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.transactionSummary,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: l10n.thisMonth,
                    value: 'BRL 0.00',
                    icon: Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: l10n.total,
                    value: 'BRL 0.00',
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      // Remove # if present and parse hex color
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Theme.of(context).primaryColor;
    }
  }

  void _toggleArchiveStatus(Category category) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (category.isArchived) {
        await ref.read(categoryProvider.notifier).unarchiveCategory(budgetId: widget.budgetId, id: category.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.categoryUnarchived),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await ref.read(categoryProvider.notifier).archiveCategory(budgetId: widget.budgetId, id: category.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.categoryArchived),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, Category category) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(
          '${l10n.deleteConfirmWithName(category.name)} ${l10n.actionCannotBeUndone}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(categoryProvider.notifier).deleteCategory(budgetId: widget.budgetId, id: category.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.categoryDeletedSuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.go('/budgets/${widget.budgetId}/categories');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.errorWithMessage(e.toString())),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
