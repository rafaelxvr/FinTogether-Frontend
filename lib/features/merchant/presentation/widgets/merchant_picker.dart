import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/merchant.dart';
import '../../domain/usecases/search_merchants_usecase.dart';
import '../pages/create_merchant_page.dart';

class MerchantPickerWidget extends ConsumerStatefulWidget {
  final String budgetId;
  final String? initialMerchantId;
  final String? initialMerchantName;
  final ValueChanged<Merchant?> onMerchantSelected;

  const MerchantPickerWidget({
    super.key,
    required this.budgetId,
    this.initialMerchantId,
    this.initialMerchantName,
    required this.onMerchantSelected,
  });

  @override
  ConsumerState<MerchantPickerWidget> createState() =>
      _MerchantPickerWidgetState();
}

class _MerchantPickerWidgetState extends ConsumerState<MerchantPickerWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;
  List<Merchant> _suggestions = [];
  bool _showSuggestions = false;
  Merchant? _selectedMerchant;

  @override
  void initState() {
    super.initState();
    if (widget.initialMerchantName != null) {
      _controller.text = widget.initialMerchantName!;
    }
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() => _showSuggestions = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    final searchUseCase = getIt<SearchMerchantsUseCase>();
    final result = await searchUseCase(
      budgetId: widget.budgetId,
      query: query,
    );

    result.fold(
      (failure) {
        // Silently ignore search failures
      },
      (merchants) {
        if (mounted) {
          setState(() {
            _suggestions = merchants;
            _showSuggestions = true;
          });
        }
      },
    );
  }

  void _selectMerchant(Merchant merchant) {
    setState(() {
      _selectedMerchant = merchant;
      _controller.text = merchant.effectiveDisplayName;
      _showSuggestions = false;
    });
    widget.onMerchantSelected(merchant);
  }

  void _clearSelection() {
    setState(() {
      _selectedMerchant = null;
      _controller.clear();
      _showSuggestions = false;
    });
    widget.onMerchantSelected(null);
  }

  void _showCreateMerchantDialog() {
    setState(() => _showSuggestions = false);
    showDialog(
      context: context,
      builder: (context) => CreateMerchantPage(
        budgetId: widget.budgetId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'Merchant (Optional)',
            hintText: 'Search or add a merchant',
            prefixIcon: const Icon(Icons.store),
            suffixIcon: _selectedMerchant != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSelection,
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),

        // Suggestions dropdown
        if (_showSuggestions)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                ..._suggestions.map((merchant) => ListTile(
                      leading: Icon(
                        Icons.store,
                        color: merchant.color != null
                            ? _parseColor(merchant.color!)
                            : Colors.teal,
                      ),
                      title: Text(merchant.effectiveDisplayName),
                      subtitle: merchant.displayName != null &&
                              merchant.displayName != merchant.name
                          ? Text(merchant.name,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]))
                          : null,
                      trailing: merchant.hasDefaultCategory
                          ? const Icon(Icons.category,
                              size: 16, color: Colors.grey)
                          : null,
                      onTap: () => _selectMerchant(merchant),
                    )),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.add_circle, color: Colors.green),
                  title: const Text('Create new merchant'),
                  onTap: _showCreateMerchantDialog,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.teal;
    }
  }
}
