/// Result of a CSV import operation containing statistics and details.
class ImportResult {
  /// Total number of rows in the CSV (excluding header)
  final int totalRows;

  /// Number of successfully imported cards
  final int successCount;

  /// Number of skipped cards (duplicates)
  final int skippedCount;

  /// Number of failed rows (validation errors)
  final int failedCount;

  /// Detailed list of import errors
  final List<ImportError> errors;

  const ImportResult({
    required this.totalRows,
    required this.successCount,
    required this.skippedCount,
    required this.failedCount,
    required this.errors,
  });

  /// Checks if the import was completely successful
  bool get isFullySuccessful => failedCount == 0 && skippedCount == 0;

  /// Checks if import had any successful imports
  bool get hasSuccesses => successCount > 0;

  /// Creates a summary message for display
  String getSummary() {
    final buffer = StringBuffer();
    buffer.writeln('Import Complete:');
    buffer.writeln('✓ Imported: $successCount');
    if (skippedCount > 0) {
      buffer.writeln('⊘ Skipped (duplicates): $skippedCount');
    }
    if (failedCount > 0) {
      buffer.writeln('✗ Failed: $failedCount');
    }
    buffer.writeln('Total rows: $totalRows');
    return buffer.toString();
  }
}

/// Details about a single row import error
class ImportError {
  /// Row number (1-based, excluding header)
  final int rowNumber;

  /// Reason for the error
  final String reason;

  /// Optional: The problematic field value
  final String? fieldValue;

  const ImportError({
    required this.rowNumber,
    required this.reason,
    this.fieldValue,
  });

  @override
  String toString() {
    if (fieldValue != null) {
      return 'Row $rowNumber: $reason (value: "$fieldValue")';
    }
    return 'Row $rowNumber: $reason';
  }
}

/// Enum for import error types
enum ImportErrorType {
  invalidYouTubeUrl,
  missingTitle,
  missingArtist,
  invalidStartTime,
  duplicate,
  parseError,
}
