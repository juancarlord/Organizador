import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProgressCard extends StatelessWidget {
  final double progress;
  final int processedFiles;
  final int totalFiles;
  final String? currentOperation;

  const ProgressCard({
    Key? key,
    required this.progress,
    required this.processedFiles,
    required this.totalFiles,
    this.currentOperation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '${(progress * 100).toInt()}% ${AppStrings.completed}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.processing} $processedFiles ${AppStrings.of} $totalFiles ${AppStrings.files}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            if (currentOperation != null) ...[
              const SizedBox(height: 8),
              Text(
                currentOperation!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
