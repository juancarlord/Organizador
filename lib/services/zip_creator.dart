import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

class ZipCreator {
  static Future<void> createZipFromDirectory(
    String sourceDirectory,
    String outputZipPath,
  ) async {
    final sourceDir = Directory(sourceDirectory);
    if (!sourceDir.existsSync()) {
      throw Exception('El directorio de origen no existe: $sourceDirectory');
    }

    // Crear un archivo ZIP en memoria
    final archive = Archive();

    // Función recursiva para agregar archivos al archivo
    void addFilesToArchive(Directory dir, String basePath) {
      final entities = dir.listSync();

      for (final entity in entities) {
        final relativePath = path.relative(entity.path, from: basePath);

        if (entity is File) {
          final bytes = entity.readAsBytesSync();
          final archiveFile = ArchiveFile(relativePath, bytes.length, bytes);
          archive.addFile(archiveFile);
        } else if (entity is Directory) {
          addFilesToArchive(entity, basePath);
        }
      }
    }

    // Agregar todos los archivos al archivo
    addFilesToArchive(sourceDir, sourceDirectory);

    // Codificar y guardar el archivo ZIP
    final encoder = ZipEncoder();
    final outputFile = File(outputZipPath);
    final bytes = encoder.encode(archive);

    if (bytes != null) {
      await outputFile.writeAsBytes(bytes);
    }
  }
}
