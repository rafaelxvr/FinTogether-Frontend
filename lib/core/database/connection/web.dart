import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

Future<QueryExecutor> openConnection() async {
  final result = await WasmDatabase.open(
    databaseName: 'fintogether',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );

  if (result.missingFeatures.isNotEmpty) {
    // ignore: avoid_print
    print('Using ${result.chosenImplementation} due to unsupported '
        'browser features: ${result.missingFeatures}');
  }

  return result.resolvedExecutor;
}
