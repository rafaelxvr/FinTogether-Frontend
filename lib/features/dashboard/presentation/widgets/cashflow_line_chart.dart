import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/cashflow_trend.dart';

/// Cashflow Line Chart Widget
/// Displays income/expense trends over time in a line chart
class CashflowLineChart extends StatefulWidget {
  final CashflowTrend? trend;
  final String title;

  const CashflowLineChart({
    super.key,
    this.trend,
    this.title = 'Fluxo de Caixa (Últimos Meses)',
  });

  @override
  State<CashflowLineChart> createState() => _CashflowLineChartState();
}

class _CashflowLineChartState extends State<CashflowLineChart> {
  @override
  Widget build(BuildContext context) {
    if (widget.trend == null || widget.trend!.months.isEmpty) {
      return _buildEmptyState(context);
    }

    final months = widget.trend!.months;

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

            // Legend
            _buildLegend(),
            const SizedBox(height: 16),

            // Chart
            SizedBox(
              height: 200,
              child: LineChart(
                _buildChartData(months),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build legend with color indicators
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Receitas', Colors.green[600]!),
        const SizedBox(width: 20),
        _buildLegendItem('Despesas', Colors.red[600]!),
        const SizedBox(width: 20),
        _buildLegendItem('Saldo', Colors.blue[600]!),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  /// Build chart data
  LineChartData _buildChartData(List<MonthlyData> months) {
    final maxValue = _getMaxValue(months);
    final minValue = _getMinValue(months);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxValue / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= months.length) {
                return const Text('');
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  months[index].shortMonthName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxValue / 4,
            reservedSize: 45,
            getTitlesWidget: (value, meta) {
              return Text(
                _formatCurrency(value),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      minX: 0,
      maxX: (months.length - 1).toDouble(),
      minY: minValue < 0 ? minValue * 1.2 : 0,
      maxY: maxValue * 1.2,
      lineBarsData: [
        // Income line
        _buildLineData(
          months,
          (month) => month.income,
          Colors.green[600]!,
        ),

        // Expense line
        _buildLineData(
          months,
          (month) => month.expense,
          Colors.red[600]!,
        ),

        // Net line
        _buildLineData(
          months,
          (month) => month.net,
          Colors.blue[600]!,
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              String label;
              if (barSpot.barIndex == 0) {
                label = 'Receitas';
              } else if (barSpot.barIndex == 1) {
                label = 'Despesas';
              } else {
                label = 'Saldo';
              }

              final currencyFormat = NumberFormat.currency(
                locale: 'pt_BR',
                symbol: 'R\$',
                decimalDigits: 2,
              );

              return LineTooltipItem(
                '$label\n${currencyFormat.format(barSpot.y)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  /// Build line data for a specific metric
  LineChartBarData _buildLineData(
    List<MonthlyData> months,
    double Function(MonthlyData) getValue,
    Color color,
  ) {
    return LineChartBarData(
      spots: months.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          getValue(entry.value),
        );
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
    );
  }

  /// Get maximum value for Y axis
  double _getMaxValue(List<MonthlyData> months) {
    double max = 0;
    for (final month in months) {
      if (month.income > max) max = month.income;
      if (month.expense > max) max = month.expense;
      if (month.net > max) max = month.net;
    }
    return max > 0 ? max : 1000;
  }

  /// Get minimum value for Y axis (in case of negative net)
  double _getMinValue(List<MonthlyData> months) {
    double min = 0;
    for (final month in months) {
      if (month.net < min) min = month.net;
    }
    return min;
  }

  /// Format currency for axis labels
  String _formatCurrency(double value) {
    if (value >= 1000) {
      return 'R\$${(value / 1000).toStringAsFixed(1)}k';
    }
    return 'R\$${value.toStringAsFixed(0)}';
  }

  /// Build empty state
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
              Icons.show_chart,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Sem dados de fluxo de caixa',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione transações para ver as tendências',
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
