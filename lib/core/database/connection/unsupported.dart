import 'package:drift/drift.dart';

Future<QueryExecutor> openConnection() async {
  throw UnsupportedError(
    'No suitable database implementation found for this platform.',
  );
}
