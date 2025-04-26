import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../models/processing_result.dart';
import '../services/file_organizer.dart';
import '../utils/constants.dart';
import '../widgets/progress_card.dart';
import '../widgets/result_dialog.dart';

class ProcessingScreen extends StatefulWidget {
  final String sourceDirectory;
  final String outputDirectory;
  final bool createZipArchives;

  const ProcessingScreen({
    Key? key,
    required this.sourceDirectory,
    required this.outputDirectory,
    required this.createZipArchives,
  }) : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  double progress = 0.0;
  int processedFiles = 0;
  int totalFiles = 0;
  bool isProcessing = true;
  bool isCompleted = false;
  ProcessingResult? result;
  String? currentOperation;

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    final organizer = FileOrganizer(
      sourceDirectory: widget.sourceDirectory,
      outputDirectory: widget.outputDirectory,
      createZipArchives: widget.createZipArchives,
      onProgress: (progress, processed, total, operation) {
        setState(() {
          this.progress = progress;
          processedFiles = processed;
          totalFiles = total;
          currentOperation = operation;
        });
      },
    );

    try {
      final result = await organizer.organizeFiles();
      setState(() {
        this.result = result;
        isProcessing = false;
        isCompleted = true;
        progress = 1.0;
      });
    } catch (e) {
      setState(() {
        isProcessing = false;
        result = ProcessingResult(
          totalFiles: totalFiles,
          processedFiles: processedFiles,
          createdFolders: 0,
          errors: ['Error durante el procesamiento: ${e.toString()}'],
          filesByType: {},
        );
      });

      // Muestra un diálogo de error
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ResultDialog(
            result: result!,
            onClose: () => Navigator.of(context).pop(),
          ),
        );
      }
    }
  }

  void _openOutputDirectory() async {
    final directory = Directory(widget.outputDirectory);
    if (await directory.exists()) {
      try {
        final url = Uri.directory(directory.path);
        if (await url_launcher.canLaunchUrl(url)) {
          await url_launcher.launchUrl(url);
        } else {
          // Si no se puede abrir directamente, muestra un diálogo con la ruta
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Directorio de salida'),
                content:
                    Text('Los archivos se guardaron en:\n${directory.path}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            );
          }
        }
      } catch (e) {
        // Maneja el error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('No se pudo abrir el directorio: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.organizingDocuments,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: isProcessing
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                AppStrings.organizingDocuments,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              ProgressCard(
                progress: progress,
                processedFiles: processedFiles,
                totalFiles: totalFiles,
                currentOperation: currentOperation,
              ),
              const SizedBox(height: 32),
              if (isProcessing)
                ElevatedButton.icon(
                  onPressed: () {
                    // Podríamos implementar cancelación aquí
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('¿Cancelar proceso?'),
                        content: const Text(
                          'El proceso de organización se cancelará. Los archivos que ya han sido '
                          'procesados permanecerán en el directorio de salida.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(AppStrings.completed),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context)
                                  .pop(); // Volver a la pantalla anterior
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[400]),
                            child: const Text(AppStrings.cancel),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text(AppStrings.cancel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                  ),
                )
              else if (isCompleted && result != null)
                _buildCompletionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionSection() {
    return Column(
      children: [
        Icon(
          result!.hasErrors ? Icons.error : Icons.check_circle,
          size: 64,
          color: result!.hasErrors ? AppColors.error : AppColors.success,
        ),
        const SizedBox(height: 16),
        Text(
          result!.hasErrors
              ? 'Proceso completado con errores'
              : AppStrings.processCompleted,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: result!.hasErrors ? AppColors.error : AppColors.success,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${AppStrings.processing} ${result!.processedFiles} ${AppStrings.of} ${result!.totalFiles} ${AppStrings.files}',
          style: const TextStyle(fontSize: 16),
        ),
        if (result!.createdFolders > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Se crearon ${result!.createdFolders} carpetas',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        const SizedBox(height: 24),
        if (result!.hasErrors)
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ResultDialog(
                  result: result!,
                  onClose: () => Navigator.of(context).pop(),
                ),
              );
            },
            icon: const Icon(Icons.report_problem),
            label: const Text('Ver detalles de errores'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _openOutputDirectory,
          icon: const Icon(Icons.folder_open),
          label: const Text(AppStrings.openOutputDirectory),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.refresh),
          label: const Text(AppStrings.organizeMoreDocuments),
        ),
      ],
    );
  }
}
