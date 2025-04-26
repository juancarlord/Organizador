class ProcessingResult {
  final int totalFiles;
  final int processedFiles;
  final int createdFolders;
  final List<String> errors;
  final Map<String, int> filesByType;

  ProcessingResult({
    required this.totalFiles,
    required this.processedFiles,
    required this.createdFolders,
    required this.errors,
    required this.filesByType,
  });

  factory ProcessingResult.empty() {
    return ProcessingResult(
      totalFiles: 0,
      processedFiles: 0,
      createdFolders: 0,
      errors: [],
      filesByType: {},
    );
  }

  ProcessingResult copyWith({
    int? totalFiles,
    int? processedFiles,
    int? createdFolders,
    List<String>? errors,
    Map<String, int>? filesByType,
  }) {
    return ProcessingResult(
      totalFiles: totalFiles ?? this.totalFiles,
      processedFiles: processedFiles ?? this.processedFiles,
      createdFolders: createdFolders ?? this.createdFolders,
      errors: errors ?? this.errors,
      filesByType: filesByType ?? this.filesByType,
    );
  }

  bool get hasErrors => errors.isNotEmpty;
}
