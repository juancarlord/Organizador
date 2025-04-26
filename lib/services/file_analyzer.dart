import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/file_utils.dart';

class DocumentGroup {
  final String documentNumber;
  final Map<String, List<File>> filesByType;

  DocumentGroup({
    required this.documentNumber,
    required this.filesByType,
  });
}

class FileAnalyzer {
  // Analiza archivos y los agrupa por número de documento
  static Map<String, DocumentGroup> analyzeFiles(List<File> files) {
    final Map<String, DocumentGroup> documentGroups = {};

    for (final file in files) {
      final fileName = path.basename(file.path);
      final documentNumber = FileUtils.extractDocumentNumber(fileName);

      if (documentNumber == null) continue;

      final documentType = FileUtils.determineDocumentType(fileName);

      if (!documentGroups.containsKey(documentNumber)) {
        documentGroups[documentNumber] = DocumentGroup(
          documentNumber: documentNumber,
          filesByType: {},
        );
      }

      final group = documentGroups[documentNumber]!;
      if (!group.filesByType.containsKey(documentType)) {
        group.filesByType[documentType] = [];
      }

      group.filesByType[documentType]!.add(file);
    }

    return documentGroups;
  }
}
