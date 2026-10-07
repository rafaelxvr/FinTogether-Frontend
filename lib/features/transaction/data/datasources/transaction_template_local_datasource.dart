import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/transaction_template.dart';

/// Local datasource for transaction templates backed by SharedPreferences
class TransactionTemplateLocalDatasource {
  final SharedPreferences _prefs;
  static const _key = 'transaction_templates';

  TransactionTemplateLocalDatasource({required SharedPreferences prefs})
      : _prefs = prefs;

  List<TransactionTemplate> getAll() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List;
    return list
        .map((e) => TransactionTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(TransactionTemplate template) async {
    final templates = getAll();
    templates.add(template);
    await _persist(templates);
  }

  Future<void> delete(String id) async {
    final templates = getAll();
    templates.removeWhere((t) => t.id == id);
    await _persist(templates);
  }

  Future<void> update(TransactionTemplate template) async {
    final templates = getAll();
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index >= 0) {
      templates[index] = template;
      await _persist(templates);
    }
  }

  Future<void> _persist(List<TransactionTemplate> templates) async {
    final jsonStr = jsonEncode(templates.map((t) => t.toJson()).toList());
    await _prefs.setString(_key, jsonStr);
  }
}
