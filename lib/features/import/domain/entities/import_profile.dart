import 'package:equatable/equatable.dart';

class ImportProfile extends Equatable {
  final String id;
  final String budgetId;
  final String name;
  final String delimiter;
  final String encoding;
  final Map<String, dynamic> mapping;
  final Map<String, dynamic>? rules;
  final String? cardId;
  final DateTime createdAt;

  const ImportProfile({
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

  @override
  List<Object?> get props => [id, budgetId, name, delimiter, encoding, mapping, rules, cardId, createdAt];
}
