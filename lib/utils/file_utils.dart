import 'dart:io';
import 'package:path/path.dart' as path;

class FileUtils {
  // Extrae el número de documento de un nombre de archivo
  static String? extractDocumentNumber(String fileName) {
    // Patrón para números de documento/factura
    RegExp regExp = RegExp(r'(\d+)');
    final matches = regExp.allMatches(fileName);

    if (matches.isNotEmpty) {
      return matches.first.group(0);
    }
    return null;
  }

  // Determina el tipo de documento basado en el nombre y extensión
  static String determineDocumentType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    final baseName = path.basenameWithoutExtension(fileName).toLowerCase();

    if (baseName.contains('orden') || baseName.contains('OPF')) {
      return 'ORDEN MEDICA';
    } else if (baseName.contains('report')) {
      return 'REPORTE';
    } else if (baseName.contains('factura') || baseName.contains('fact')) {
      return 'FACTURA';
    } else if (baseName.contains('detalle') || baseName.contains('cargo')) {
      return 'DETALLE DE CARGOS';
    } else if (ext == '.json') {
      return 'JSON';
    } else if (ext == '.xml') {
      return 'XML';
    } else if (baseName.contains('cuv')) {
      return 'CUV';
    } else if (baseName.contains('validacion')) {
      return 'VALIDACIONES';
    } else if (baseName.contains('cargos')) {
      return 'CARGOS';
    }

    // Por defecto, basado en la extensión
    if (ext == '.pdf') {
      return 'FACTURA'; // Por defecto los PDF como facturas
    }

    return 'OTRO';
  }

  // Verifica si un directorio está vacío
  static bool isDirectoryEmpty(String directoryPath) {
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) {
      return true;
    }
    return dir.listSync().isEmpty;
  }

  // Crea un directorio si no existe
  static void createDirectoryIfNotExists(String directoryPath) {
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  // Lista todos los archivos en un directorio (no recursivo)
  static List<File> listFiles(String directoryPath) {
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) {
      return [];
    }

    return dir
        .listSync()
        .where((entity) => entity is File)
        .map((entity) => entity as File)
        .toList();
  }
}
