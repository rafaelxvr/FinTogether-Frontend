import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../category/domain/entities/category.dart';

class CategoryIconGrid extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<Category> onSelected;

  const CategoryIconGrid({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sortedCategories = List<Category>.from(categories)
      ..sort((a, b) {
        // Expense categories first
        if (a.isExpense && !b.isExpense) return -1;
        if (!a.isExpense && b.isExpense) return 1;
        return a.name.compareTo(b.name);
      });

    if (sortedCategories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No categories found. Create categories first.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final isSelected = category.id == selectedCategoryId;

        return _CategoryIconTile(
          category: category,
          isSelected: isSelected,
          onTap: () {
            try {
              HapticFeedback.lightImpact();
            } catch (_) {}
            onSelected(category);
          },
        );
      },
    );
  }
}

class _CategoryIconTile extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryIconTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  Color _getCategoryColor(BuildContext context) {
    if (category.color != null && category.color!.isNotEmpty) {
      try {
        final hex = category.color!.replaceFirst('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    return Theme.of(context).colorScheme.primary;
  }

  IconData _getCategoryIcon() {
    if (category.icon != null && category.icon!.isNotEmpty) {
      return _mapIconName(category.icon!);
    }
    return Icons.category;
  }

  static IconData _mapIconName(String iconName) {
    const iconMap = {
      'food': Icons.restaurant,
      'restaurant': Icons.restaurant,
      'groceries': Icons.shopping_cart,
      'shopping': Icons.shopping_bag,
      'transport': Icons.directions_car,
      'car': Icons.directions_car,
      'health': Icons.local_hospital,
      'education': Icons.school,
      'entertainment': Icons.movie,
      'home': Icons.home,
      'bills': Icons.receipt,
      'salary': Icons.account_balance_wallet,
      'investment': Icons.trending_up,
      'gift': Icons.card_giftcard,
      'travel': Icons.flight,
      'pet': Icons.pets,
      'clothing': Icons.checkroom,
      'beauty': Icons.face,
      'sports': Icons.fitness_center,
      'subscription': Icons.subscriptions,
      'utilities': Icons.flash_on,
      'internet': Icons.wifi,
      'phone': Icons.phone_android,
      'insurance': Icons.security,
      'tax': Icons.account_balance,
      'transfer': Icons.swap_horiz,
      'other': Icons.more_horiz,
    };
    return iconMap[iconName.toLowerCase()] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getCategoryColor(context);

    return Semantics(
      label: 'Category: ${category.name}',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: color, width: 3)
                : Border.all(color: Colors.transparent, width: 3),
            color: isSelected
                ? color.withOpacity(0.15)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(
                    _getCategoryIcon(),
                    color: color,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? color
                      : theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
