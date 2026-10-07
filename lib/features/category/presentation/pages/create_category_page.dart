import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../providers/category_provider.dart';
import '../providers/category_state.dart';

class CreateCategoryPage extends ConsumerStatefulWidget {
  final String budgetId;
  final Category? category; // For editing
  final CategoryType initialType;

  const CreateCategoryPage({
    super.key,
    required this.budgetId,
    this.category,
    required this.initialType,
  });

  @override
  ConsumerState<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends ConsumerState<CreateCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();
  final _limitController = TextEditingController();

  late CategoryType _selectedType;
  Category? _selectedParent;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.category?.type ?? widget.initialType;

    if (widget.category != null) {
      // Editing mode
      _nameController.text = widget.category!.name;
      _iconController.text = widget.category!.icon ?? '';
      _colorController.text = widget.category!.color ?? '';
      _limitController.text =
          widget.category!.limitAmount?.toStringAsFixed(2) ?? '';
      // Note: parentId would need to be resolved to Category object
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<CategoryState>(categoryProvider, (previous, next) {
      if (next is CategoryCreated) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.categoryCreatedSuccessfully)),
        );
      } else if (next is CategoryUpdated) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.categoryUpdatedSuccessfully)),
        );
      } else if (next is CategoryError) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return AlertDialog(
      title: Text(widget.category == null ? l10n.createCategory : l10n.editCategory),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.categoryName,
                    hintText: l10n.categoryNameHint,
                    prefixIcon: const Icon(Icons.category),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.categoryNameRequired;
                    }
                    if (value.trim().length < 2) {
                      return l10n.nameMinLengthGeneric;
                    }
                    if (value.length > 255) {
                      return l10n.nameMaxLengthGeneric;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category Type (disabled when editing)
                if (widget.category == null) ...[
                  Text(
                    l10n.categoryType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTypeSelector(),
                  const SizedBox(height: 20),
                ],

                // Parent Category (Optional)
                Text(
                  l10n.parentCategoryOptional,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildParentSelector(),
                const SizedBox(height: 20),

                // Icon (Optional)
                TextFormField(
                  controller: _iconController,
                  decoration: InputDecoration(
                    labelText: l10n.iconOptional,
                    hintText: l10n.iconHint,
                    prefixIcon: const Icon(Icons.emoji_emotions),
                  ),
                  maxLength: 2,
                ),
                const SizedBox(height: 12),

                // Color (Optional)
                TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(
                    labelText: l10n.colorOptional,
                    hintText: l10n.colorHint,
                    prefixIcon: const Icon(Icons.palette),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[#0-9A-Fa-f]')),
                  ],
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final hexPattern = RegExp(r'^#?[0-9A-Fa-f]{6}$');
                      if (!hexPattern.hasMatch(value.trim())) {
                        return l10n.colorHexFormatError;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Limit Amount (Optional, for expense categories)
                if (_selectedType == CategoryType.expense)
                  TextFormField(
                    controller: _limitController,
                    decoration: InputDecoration(
                      labelText: l10n.budgetLimitOptional,
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final limit = double.tryParse(value.trim());
                        if (limit == null) {
                          return l10n.invalidNumber;
                        }
                        if (limit < 0) {
                          return l10n.limitCannotBeNegative;
                        }
                      }
                      return null;
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.category == null ? l10n.create : l10n.update),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: CategoryType.values.map((type) {
        return _buildTypeChip(type);
      }).toList(),
    );
  }

  Widget _buildTypeChip(CategoryType type) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            type.icon,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(type.displayName),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedType = type);
        }
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildParentSelector() {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(categoryProvider.notifier);
    final availableParents = notifier.categories
        .where((c) =>
            c.type == _selectedType &&
            !c.archived &&
            c.id != widget.category?.id) // Exclude self
        .toList();

    return DropdownButtonFormField<Category>(
      value: _selectedParent,
      decoration: InputDecoration(
        hintText: l10n.noneRootCategory,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.folder),
      ),
      items: [
        DropdownMenuItem<Category>(
          value: null,
          child: Text(l10n.noneRootCategory),
        ),
        ...availableParents.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Row(
              children: [
                Text(
                  category.displayIcon,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(category.name),
              ],
            ),
          );
        }),
      ],
      onChanged: (category) {
        setState(() => _selectedParent = category);
      },
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final notifier = ref.read(categoryProvider.notifier);
    final limitAmount = _limitController.text.trim().isEmpty
        ? null
        : double.parse(_limitController.text.trim());

    if (widget.category == null) {
      // Create new category
      notifier.createCategory(
        budgetId: widget.budgetId,
        name: _nameController.text.trim(),
        type: _selectedType,
        parentId: _selectedParent?.id,
        icon: _iconController.text.trim().isEmpty
            ? null
            : _iconController.text.trim(),
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
        limitAmount: limitAmount,
      );
    } else {
      // Update existing category
      notifier.updateCategory(
        budgetId: widget.budgetId,
        id: widget.category!.id,
        name: _nameController.text.trim(),
        icon: _iconController.text.trim().isEmpty
            ? null
            : _iconController.text.trim(),
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
        limitAmount: limitAmount,
        parentId: _selectedParent?.id,
      );
    }
  }
}
