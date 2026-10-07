import 'package:equatable/equatable.dart';

class ImportResult extends Equatable {
  final int totalImported;
  final int totalSkipped;
  final String importHistoryId;

  const ImportResult({
    required this.totalImported,
    required this.totalSkipped,
    required this.importHistoryId,
  });

  @override
  List<Object?> get props => [totalImported, totalSkipped, importHistoryId];
}

class ImportHistoryEntry extends Equatable {
  final String id;
  final String fileName;
  final int totalRows;
  final int importedRows;
  final int skippedRows;
  final int duplicateRows;
  final String status;
  final String? errorMessage;
  final DateTime createdAt;

  const ImportHistoryEntry({
    required this.id,
    required this.fileName,
    required this.totalRows,
    required this.importedRows,
    required this.skippedRows,
    required this.duplicateRows,
    required this.status,
    this.errorMessage,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, fileName, totalRows, importedRows, skippedRows, duplicateRows, status, createdAt];
}
