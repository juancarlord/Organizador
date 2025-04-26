import 'package:flutter/material.dart';
import '../models/processing_result.dart';
import '../utils/constants.dart';

class ResultDialog extends StatelessWidget {
  final ProcessingResult result;
  final VoidCallback onClose;

  const ResultDialog({
    Key? key,
    required this.result,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Resultado del Proceso'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Archivos procesados: ${result.processedFiles} de ${result.totalFiles}'),
            const SizedBox(height: 8),
            Text('Carpetas creadas: ${result.createdFolders}'),
            const SizedBox(height: 16),
            const Text(
              'Archivos por tipo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...result.filesByType.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text('${entry.key}: ${entry.value} archivos'),
              ),
            ),
            if (result.hasErrors) ...[
              const SizedBox(height: 16),
              const Text(
                'Errores:',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.error),
              ),
              const SizedBox(height: 8),
              ...result.errors.map(
                (error) => Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    error,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
