import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/import_profile.dart';

part 'import_profile_model.g.dart';

@JsonSerializable()
class ImportProfileModel {
  final String id;
  final String budgetId;
  final String name;
  final String delimiter;
  final String encoding;
  final Map<String, dynamic> mapping;
  final Map<String, dynamic>? rules;
  final String? cardId;
  final String createdAt;

  const ImportProfileModel({
    required this.id,
    required this.budgetId,
    required this.name,
    this.delimiter = ',',
    this.encoding = 'UTF-8',
    required this.mapping,
    this.rules,
    this.cardId,
    required this.createdAt,
  });

  factory ImportProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ImportProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImportProfileModelToJson(this);

  ImportProfile toEntity() => ImportProfile(
        id: id,
        budgetId: budgetId,
        name: name,
        delimiter: delimiter,
        encoding: encoding,
        mapping: mapping,
        rules: rules,
        cardId: cardId,
        createdAt: DateTime.parse(createdAt),
      );
}
