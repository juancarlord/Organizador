import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/processing_result.dart';
import '../utils/file_utils.dart';
import '../utils/json_parser.dart';
import '../utils/logger.dart';
import 'file_analyzer.dart';
import 'zip_creator.dart';

class FileOrganizer {
  final String sourceDirectory;
  final String outputDirectory;
  final bool createZipArchives;
  final Function(double progress, int processedFiles, int totalFiles,
      String currentOperation)? onProgress;

  FileOrganizer({
    required this.sourceDirectory,
    required this.outputDirectory,
    this.createZipArchives = true,
    this.onProgress,
  });

  // Clean filename by removing whitespaces
  String _cleanFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'\s+'), '');
  }

  // Extract MR number from filename (e.g., "OPF_900308472_MR85089" -> "MR85089")
  String? _extractMRNumber(String fileName) {
    // Pattern for FOMAG files: [PREFIX]_[NUMBER]_MR[ID]
    final match = RegExp(r'_MR\d+').firstMatch(fileName);
    if (match != null) {
      return match.group(0)?.substring(1); // Remove the leading underscore
    }
    return null;
  }

  Future<ProcessingResult> organizeFiles() async {
    AppLogger.info('Starting file organization process');
    AppLogger.info('Source directory: $sourceDirectory');
    AppLogger.info('Output directory: $outputDirectory');

    // Check if this is a CAPRESOCA folder
    //final isCapresoca = sourceDirectory.toLowerCase().contains('capresoca');
    const isCapresoca = true;
    AppLogger.info('Is CAPRESOCA folder: $isCapresoca');

    // Create output directory if it doesn't exist
    FileUtils.createDirectoryIfNotExists(outputDirectory);

    // Define the subfolders to process
    final subfolders = [
      'ORDEN MEDICA',
      'AUTORIZACION Y ORDEN',
      'REPORTE',
      'FACTURA',
      'XML',
      'JSON Y CUV',
      'VALIDACIONES',
      'CARGOS'
    ];

    // Statistics
    int totalFiles = 0;
    int processedFiles = 0;
    int createdFolders = 0;
    List<String> errors = [];
    Map<String, int> filesByType = {};

    // First, process JSON files to get document numbers and create folder mapping
    final jsonFolderPath = path.join(sourceDirectory, 'JSON Y CUV');
    final Map<String, String> jsonToDocumentNumber =
        {}; // Maps JSON filename to document number
    final Map<String, String> documentNumberToFolder =
        {}; // Maps document number to folder name

    if (Directory(jsonFolderPath).existsSync()) {
      AppLogger.info('Processing JSON files first');
      final jsonFiles = FileUtils.listFiles(jsonFolderPath)
          .where((file) => file.path.toLowerCase().endsWith('.json'))
          .toList();

      for (final jsonFile in jsonFiles) {
        try {
          final documentNumber =
              await JsonParser.extractDocumentNumber(jsonFile.path);
          if (documentNumber != null) {
            final fileName =
                _cleanFileName(path.basenameWithoutExtension(jsonFile.path));
            jsonToDocumentNumber[fileName] = documentNumber;
            documentNumberToFolder[documentNumber] = fileName;
            AppLogger.info(
                'Found document number $documentNumber for $fileName');
          }
        } catch (e, stackTrace) {
          AppLogger.error(
              'Error processing JSON file ${jsonFile.path}', e, stackTrace);
          errors.add('Error al procesar archivo JSON ${jsonFile.path}: $e');
        }
      }
    }

    // Process each subfolder
    for (final subfolder in subfolders) {
      final subfolderPath = path.join(sourceDirectory, subfolder);
      if (!Directory(subfolderPath).existsSync()) {
        AppLogger.warning('Subfolder not found: $subfolder');
        continue;
      }

      AppLogger.info('Processing subfolder: $subfolder');

      // List all files in the subfolder
      final files = FileUtils.listFiles(subfolderPath);
      totalFiles += files.length;

      // Process each file
      for (final file in files) {
        try {
          final fileName = path.basename(file.path);
          final cleanFileName = _cleanFileName(fileName);
          String? folderName;
          String targetFileName = cleanFileName;

          if (isCapresoca) {
            // CAPRESOCA-specific behavior
            if (subfolder == 'JSON Y CUV' &&
                fileName.toLowerCase().endsWith('.json')) {
              final baseName =
                  _cleanFileName(path.basenameWithoutExtension(fileName));
              // CAPRESOCA-specific behavior: Handle _CUV files differently
              final matchName = baseName.replaceAll('_CUV', '');
              folderName = jsonToDocumentNumber.containsKey(matchName)
                  ? documentNumberToFolder[jsonToDocumentNumber[matchName]!]
                  : null;
            } else if (subfolder == 'REPORTE' ||
                subfolder == 'AUTORIZACION Y ORDEN') {
              for (final entry in documentNumberToFolder.entries) {
                final documentNumber = entry.key;
                if (cleanFileName.contains(documentNumber)) {
                  folderName = entry.value;

                  // CAPRESOCA-specific behavior: Append RPT to REPORTE files
                  if (subfolder == 'REPORTE') {
                    final ext = path.extension(cleanFileName);
                    targetFileName =
                        '${path.basenameWithoutExtension(cleanFileName)}_RPT$ext';
                  }
                  AppLogger.info(
                      'Found matching document number $documentNumber in $cleanFileName');
                  break;
                }
              }
            } else if (subfolder == 'VALIDACIONES') {
              // For VALIDACIONES, use MR number for organization
              final match = RegExp(r'MR\d+').firstMatch(cleanFileName);
              if (match != null) {
                folderName = match.group(0);
                final ext = path.extension(cleanFileName);
                targetFileName =
                    '${path.basenameWithoutExtension(cleanFileName)}_VLD$ext';
                AppLogger.info('Found MR number $folderName in $cleanFileName');
              }
            } else if (subfolder == 'FACTURA') {
              // For VALIDACIONES, use MR number for organization
              final match = RegExp(r'MR\d+').firstMatch(cleanFileName);
              if (match != null) {
                folderName = match.group(0);
                final ext = path.extension(cleanFileName);
                targetFileName =
                    '${path.basenameWithoutExtension(cleanFileName)}_FCT$ext';
                AppLogger.info('Found MR number $folderName in $cleanFileName');
              }
            } else {
              final jsonFileName =
                  _cleanFileName(path.basenameWithoutExtension(fileName));
              folderName = jsonToDocumentNumber.containsKey(jsonFileName)
                  ? documentNumberToFolder[jsonToDocumentNumber[jsonFileName]!]
                  : null;
            }
          }
          /* 
          else {
            // Non-CAPRESOCA behavior: Use MR number for organization
            // For XML and JSON Y CUV, the filename is just MRdigits
            if (subfolder == 'XML' || subfolder == 'JSON Y CUV') {
              final match = RegExp(r'MR\d+').firstMatch(cleanFileName);
              if (match != null) {
                folderName = match.group(0);
                AppLogger.info('Found MR number $folderName in $cleanFileName');
              }
            } else {
              final mrNumber = _extractMRNumber(cleanFileName);
              if (mrNumber != null) {
                folderName = mrNumber;
                AppLogger.info('Found MR number $mrNumber in $cleanFileName');
              }
            }
          }
          */
          // Determine target directory
          String targetDir;
          if (folderName != null) {
            targetDir = path.join(outputDirectory, folderName);
          } else {
            // For files without matching identifier, use their original subfolder
            targetDir = path.join(outputDirectory, subfolder);
          }

          // Create target directory if it doesn't exist
          FileUtils.createDirectoryIfNotExists(targetDir);
          createdFolders++;

          // Copy file to target directory with new name if needed
          final destPath = path.join(targetDir, targetFileName);
          await file.copy(destPath);

          // Update statistics
          processedFiles++;
          if (!filesByType.containsKey(subfolder)) {
            filesByType[subfolder] = 0;
          }
          filesByType[subfolder] = filesByType[subfolder]! + 1;

          // Report progress
          if (onProgress != null) {
            final progress = processedFiles / totalFiles;
            onProgress!(progress, processedFiles, totalFiles, subfolder);
          }

          AppLogger.debug(
              'Copied file: $fileName to $targetDir as $targetFileName');
        } catch (e, stackTrace) {
          AppLogger.error('Error processing file ${file.path}', e, stackTrace);
          errors.add('Error al procesar archivo ${file.path}: $e');
        }
      }
    }

    // Create zip archives if requested
    if (createZipArchives) {
      AppLogger.info('Creating zip archives for organized folders');
      try {
        final folders = Directory(outputDirectory)
            .listSync()
            .whereType<Directory>()
            .toList();

        for (final folder in folders) {
          final folderName = path.basename(folder.path);
          final zipPath = path.join(outputDirectory, '$folderName.zip');

          await ZipCreator.createZipFromDirectory(folder.path, zipPath);
          AppLogger.info('Created zip archive: $zipPath');
        }
      } catch (e, stackTrace) {
        AppLogger.error('Error creating zip archives', e, stackTrace);
        errors.add('Error al crear archivos ZIP: $e');
      }
    }

    AppLogger.info('File organization completed');
    AppLogger.info('Total files processed: $processedFiles/$totalFiles');
    AppLogger.info('Folders created: $createdFolders');
    AppLogger.info('Errors encountered: ${errors.length}');
    AppLogger.info('Files by type: $filesByType');

    return ProcessingResult(
      totalFiles: totalFiles,
      processedFiles: processedFiles,
      createdFolders: createdFolders,
      errors: errors,
      filesByType: filesByType,
    );
  }
}
