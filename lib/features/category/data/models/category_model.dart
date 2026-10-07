import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel extends Category {
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  const CategoryModel({
    required super.id,
    required super.budgetId,
    required super.name,
    required super.type,
    super.parentId,
    super.icon,
    super.color,
    super.limitAmount,
    required super.archived,
    @JsonKey(name: 'isEssential', defaultValue: false) super.isEssential,
    required super.createdAt,
    @JsonKey(name: 'updated_at') super.updatedAt,
    required super.hasChildren,
    this.deletedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  Category toEntity() => Category(
        id: id,
        budgetId: budgetId,
        name: name,
        type: type,
        parentId: parentId,
        icon: icon,
        color: color,
        limitAmount: limitAmount,
        archived: archived,
        isEssential: isEssential,
        createdAt: createdAt,
        updatedAt: updatedAt,
        hasChildren: hasChildren,
      );

  factory CategoryModel.fromEntity(Category category) => CategoryModel(
        id: category.id,
        budgetId: category.budgetId,
        name: category.name,
        type: category.type,
        parentId: category.parentId,
        icon: category.icon,
        color: category.color,
        limitAmount: category.limitAmount,
        archived: category.archived,
        isEssential: category.isEssential,
        createdAt: category.createdAt,
        updatedAt: category.updatedAt,
        hasChildren: category.hasChildren,
      );
}
