import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/category.dart';
import '../providers/category_provider.dart';
import '../providers/category_state.dart';
import '../widgets/category_card.dart';
import 'create_category_page.dart';

class CategoryListPage extends ConsumerStatefulWidget {
  final String budgetId;

  const CategoryListPage({
    super.key,
    required this.budgetId,
  });

  @override
  ConsumerState<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends ConsumerState<CategoryListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CategoryType _selectedType = CategoryType.expense;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabController.addListener(_handleTabChange);
    // Load categories when page opens
    Future.microtask(
      () => ref.read(categoryProvider.notifier).loadCategories(
            budgetId: widget.budgetId,
            type: _selectedType,
          ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedType = CategoryType.values[_tabController.index];
      });
      ref.read(categoryProvider.notifier).loadCategories(
            budgetId: widget.budgetId,
            type: _selectedType,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(categoryProvider);
    final notifier = ref.read(categoryProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.loadCategories(
              budgetId: widget.budgetId,
              type: _selectedType,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '${String.fromCharCode(0x1F4B0)} ${l10n.income}', icon: const Icon(Icons.trending_up)),
            Tab(text: '${String.fromCharCode(0x1F4B8)} ${l10n.expense}', icon: const Icon(Icons.trending_down)),
            Tab(text: '${String.fromCharCode(0x1F504)} ${l10n.transfer}', icon: const Icon(Icons.swap_horiz)),
          ],
        ),
      ),
      body: _buildBody(state, notifier),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCategoryDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addCategory),
      ),
    );
  }

  Widget _buildBody(CategoryState state, CategoryNotifier notifier) {
    if (state is CategoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CategoryError) {
      return _buildErrorState(state.message);
    }

    final activeCategories = notifier.activeCategories;
    final archivedCategories = notifier.archivedCategories;

    if (activeCategories.isEmpty && archivedCategories.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadCategories(
        budgetId: widget.budgetId,
        type: _selectedType,
      ),
      child: _buildCategoryList(activeCategories, archivedCategories, notifier),
    );
  }

  Widget _buildCategoryList(
    List<Category> activeCategories,
    List<Category> archivedCategories,
    CategoryNotifier notifier,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // Get root categories and subcategories
    final rootCategories =
        activeCategories.where((c) => c.parentId == null).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Card
        _buildSummaryCard(activeCategories.length, archivedCategories.length),
        const SizedBox(height: 24),

        // Active Categories (Hierarchical)
        if (rootCategories.isNotEmpty) ...[
          _buildSectionHeader(l10n.activeCategories, activeCategories.length),
          const SizedBox(height: 12),
          ...rootCategories.map((category) => Column(
                children: [
                  CategoryCard(
                    category: category,
                    onTap: () => _showCategoryDetails(context, category),
                    onEdit: () => _showEditCategoryDialog(context, category),
                    onDelete: () => _confirmDelete(context, category, notifier),
                    onArchive: () => _archiveCategory(context, category, notifier),
                  ),
                  // Show subcategories
                  ...notifier
                      .getSubcategories(category.id)
                      .map((subcategory) => Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: CategoryCard(
                              category: subcategory,
                              isSubcategory: true,
                              onTap: () =>
                                  _showCategoryDetails(context, subcategory),
                              onEdit: () =>
                                  _showEditCategoryDialog(context, subcategory),
                              onDelete: () =>
                                  _confirmDelete(context, subcategory, notifier),
                              onArchive: () =>
                                  _archiveCategory(context, subcategory, notifier),
                            ),
                          )),
                  const SizedBox(height: 12),
                ],
              )),
        ],

        // Archived Categories
        if (archivedCategories.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.archivedCategories, archivedCategories.length),
          const SizedBox(height: 12),
          ...archivedCategories.map((category) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CategoryCard(
                  category: category,
                  onTap: () => _showCategoryDetails(context, category),
                  onEdit: () => _showEditCategoryDialog(context, category),
                  onDelete: () => _confirmDelete(context, category, notifier),
                  onUnarchive: () =>
                      _unarchiveCategory(context, category, notifier),
                ),
              )),
        ],
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildSummaryCard(int activeCount, int archivedCount) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              icon: Icons.category,
              label: l10n.active,
              value: activeCount.toString(),
              valueColor: Theme.of(context).primaryColor,
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey[300],
            ),
            _buildSummaryItem(
              icon: Icons.archive,
              label: l10n.archived,
              value: archivedCount.toString(),
              valueColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _selectedType.icon,
            style: const TextStyle(fontSize: 100),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noCategoriesForType(_selectedType.displayName),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createFirstCategoryDescription(_selectedType.displayName.toLowerCase()),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateCategoryDialog(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.createCategory),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            l10n.error,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(categoryProvider.notifier).loadCategories(
                  budgetId: widget.budgetId,
                  type: _selectedType,
                ),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  void _showCreateCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateCategoryPage(
        budgetId: widget.budgetId,
        initialType: _selectedType,
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => CreateCategoryPage(
        budgetId: widget.budgetId,
        category: category,
        initialType: _selectedType,
      ),
    );
  }

  void _showCategoryDetails(BuildContext context, Category category) {
    context.go('/budgets/${widget.budgetId}/categories/${category.id}/details');
  }

  void _confirmDelete(
    BuildContext context,
    Category category,
    CategoryNotifier notifier,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(
          '${l10n.deleteConfirmWithName(category.name)}${category.hasChildren ? '\n\n${l10n.warningHasSubcategories}' : ''}\n\n${l10n.actionCannotBeUndone}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.deleteCategory(
                budgetId: widget.budgetId,
                id: category.id,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _archiveCategory(
    BuildContext context,
    Category category,
    CategoryNotifier notifier,
  ) {
    notifier.archiveCategory(
      budgetId: widget.budgetId,
      id: category.id,
    );
  }

  void _unarchiveCategory(
    BuildContext context,
    Category category,
    CategoryNotifier notifier,
  ) {
    notifier.unarchiveCategory(
      budgetId: widget.budgetId,
      id: category.id,
    );
  }
}
