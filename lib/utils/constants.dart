import 'package:flutter/material.dart';

class AppColors {
  static const Color primary =
      Color(0xFF2E5B9A); // Azul principal similar a Mundo Radiológico
  static const Color secondary = Color(0xFF4285F4);
  static const Color accent = Color(0xFF00A3E0);
  static const Color background = Colors.white;
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFC107);
}

class AppStrings {
  static const String appTitle = 'Organizador de Documentos Médicos';
  static const String configuration = 'Configuración';
  static const String directorySelection = 'Selección de directorios';
  static const String sourceDirectory = 'Directorio de archivos a organizar';
  static const String outputDirectory = 'Directorio de salida';
  static const String browse = 'Explorar';
  static const String processingOptions = 'Opciones de procesamiento';
  static const String createZip = 'Crear archivos ZIP';
  static const String zipDescription =
      'Generar un archivo ZIP por cada grupo de documentos organizados';
  static const String startOrganization = 'Iniciar Organización';
  static const String organizingDocuments = 'Organizando documentos';
  static const String completed = 'completado';
  static const String processing = 'Procesando';
  static const String of = 'de';
  static const String files = 'archivos';
  static const String cancel = 'Cancelar';
  static const String processCompleted = '¡Proceso completado con éxito!';
  static const String openOutputDirectory = 'Abrir directorio de salida';
  static const String organizeMoreDocuments = 'Organizar más documentos';
  static const String selectSourceDirectory = 'Seleccione el directorio origen';
  static const String selectDestinationDirectory =
      'Seleccione el directorio destino';
}
