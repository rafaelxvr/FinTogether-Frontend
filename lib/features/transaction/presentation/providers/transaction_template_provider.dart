import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../data/datasources/transaction_template_local_datasource.dart';
import '../../domain/entities/transaction_template.dart';

class TransactionTemplateNotifier
    extends StateNotifier<List<TransactionTemplate>> {
  final TransactionTemplateLocalDatasource _datasource;

  TransactionTemplateNotifier({
    required TransactionTemplateLocalDatasource datasource,
  })  : _datasource = datasource,
        super([]) {
    load();
  }

  void load() {
    state = _datasource.getAll();
  }

  Future<void> saveTemplate(TransactionTemplate template) async {
    await _datasource.save(template);
    load();
  }

  Future<void> deleteTemplate(String id) async {
    await _datasource.delete(id);
    load();
  }
}

final transactionTemplateProvider = StateNotifierProvider<
    TransactionTemplateNotifier, List<TransactionTemplate>>((ref) {
  return TransactionTemplateNotifier(
    datasource: getIt<TransactionTemplateLocalDatasource>(),
  );
});
