import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../models/processing_result.dart';
import '../services/file_organizer.dart';
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
  String? errorMessage;
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
        if (mounted) {
          setState(() {
            this.progress = progress;
            processedFiles = processed;
            totalFiles = total;
            currentOperation = operation;
          });
        }
      },
    );

    try {
      final result = await organizer.organizeFiles();
      if (mounted) {
        setState(() {
          this.result = result;
          isProcessing = false;
          isCompleted = true;
          progress = 1.0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isProcessing = false;
          errorMessage = e.toString();
          result = ProcessingResult(
            totalFiles: totalFiles,
            processedFiles: processedFiles,
            createdFolders: 0,
            errors: [errorMessage!],
            filesByType: {},
          );
        });
      }
    }
  }

  Future<void> _openOutputDirectory() async {
    final uri = Uri.file(widget.outputDirectory);
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el directorio de salida'),
          ),
        );
      }
    }
  }

  void _showResultDialog() {
    if (result != null) {
      showDialog(
        context: context,
        builder: (context) => ResultDialog(
          result: result!,
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procesando archivos'),
        automaticallyImplyLeading: !isProcessing,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isProcessing) ...[
                ProgressCard(
                  progress: progress,
                  processedFiles: processedFiles,
                  totalFiles: totalFiles,
                  currentOperation: currentOperation,
                ),
              ] else if (errorMessage != null) ...[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error durante el procesamiento',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver'),
                ),
              ] else if (isCompleted && result != null) ...[
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Procesamiento completado',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${result!.processedFiles} archivos procesados\n'
                  '${result!.createdFolders} carpetas creadas',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _showResultDialog,
                      child: const Text('Ver detalles'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _openOutputDirectory,
                      child: const Text('Abrir carpeta de salida'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
