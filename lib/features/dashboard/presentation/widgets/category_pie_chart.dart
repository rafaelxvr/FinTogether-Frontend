import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Category Pie Chart Widget
/// Displays spending distribution across categories in a pie chart
class CategoryPieChart extends StatefulWidget {
  final List<CategorySpending> categories;
  final String title;

  const CategoryPieChart({
    super.key,
    required this.categories,
    this.title = 'Gastos por Categoria',
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return _buildEmptyState(context);
    }

    // Take top 5 categories
    final topCategories = widget.categories.take(5).toList();
    final total = topCategories.fold<double>(
      0,
      (sum, cat) => sum + cat.amount,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),

            // Chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex =
                            pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _buildSections(topCategories, total),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Legend
            _buildLegend(topCategories),
          ],
        ),
      ),
    );
  }

  /// Build pie chart sections
  List<PieChartSectionData> _buildSections(
    List<CategorySpending> categories,
    double total,
  ) {
    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 70.0 : 60.0;
      final fontSize = isTouched ? 16.0 : 14.0;

      final color = _getCategoryColor(category, index);

      return PieChartSectionData(
        color: color,
        value: category.amount,
        title: '${category.percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  /// Build legend with category names and amounts
  Widget _buildLegend(List<CategorySpending> categories) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return Column(
      children: categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final color = _getCategoryColor(category, index);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),

              // Category name
              Expanded(
                child: Text(
                  category.categoryName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Amount
              Text(
                currencyFormat.format(category.amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Get color for category (use custom color if available, otherwise use default palette)
  Color _getCategoryColor(CategorySpending category, int index) {
    // Try to parse custom color from category
    if (category.color != null && category.color!.isNotEmpty) {
      try {
        // Handle hex color format (#RRGGBB or RRGGBB)
        String colorString = category.color!;
        if (colorString.startsWith('#')) {
          colorString = colorString.substring(1);
        }
        if (colorString.length == 6) {
          return Color(int.parse('FF$colorString', radix: 16));
        }
      } catch (e) {
        // Fall through to default colors
      }
    }

    // Default color palette
    final defaultColors = [
      Colors.blue[400]!,
      Colors.green[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.red[400]!,
      Colors.teal[400]!,
      Colors.amber[400]!,
      Colors.indigo[400]!,
    ];

    return defaultColors[index % defaultColors.length];
  }

  /// Build empty state when no categories
  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Sem dados de categorias',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione transações para ver a distribuição',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
