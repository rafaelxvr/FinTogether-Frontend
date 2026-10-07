import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/merchant_analytics.dart';
import '../../domain/usecases/get_top_merchants_usecase.dart';

class TopMerchantsWidget extends ConsumerStatefulWidget {
  final String budgetId;

  const TopMerchantsWidget({
    super.key,
    required this.budgetId,
  });

  @override
  ConsumerState<TopMerchantsWidget> createState() =>
      _TopMerchantsWidgetState();
}

class _TopMerchantsWidgetState extends ConsumerState<TopMerchantsWidget> {
  TopMerchantsData? _data;
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = 'this_month';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    if (_selectedPeriod == 'this_month') {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0);
    } else {
      startDate = DateTime(now.year, now.month - 1, 1);
      endDate = DateTime(now.year, now.month, 0);
    }

    try {
      final useCase = getIt<GetTopMerchantsUseCase>();
      final result = await useCase(
        budgetId: widget.budgetId,
        startDate: startDate,
        endDate: endDate,
        limit: 5,
      );

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _error = failure.message;
              _isLoading = false;
            });
          }
        },
        (data) {
          if (mounted) {
            setState(() {
              _data = data;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Merchants',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // Period selector
                DropdownButton<String>(
                  value: _selectedPeriod,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 'this_month',
                      child: Text('This Month'),
                    ),
                    DropdownMenuItem(
                      value: 'last_month',
                      child: Text('Last Month'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPeriod = value);
                      _loadData();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.grey[400], size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Unable to load data',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else if (_data == null || _data!.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.store, color: Colors.grey[300], size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'No merchant data yet',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildMerchantList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantList() {
    return Column(
      children: [
        // Total spend
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Spend',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                _data!.formattedTotalSpend,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Merchant rows
        ...List.generate(_data!.summaries.length, (index) {
          final summary = _data!.summaries[index];
          return _buildMerchantRow(index + 1, summary);
        }),
      ],
    );
  }

  Widget _buildMerchantRow(int rank, MerchantSpendingSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? Colors.teal : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Merchant name and count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.merchantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${summary.transactionCount} transaction${summary.transactionCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Amount and percentage
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                summary.formattedAmount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                summary.formattedPercentage,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
