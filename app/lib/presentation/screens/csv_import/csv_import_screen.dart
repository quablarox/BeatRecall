import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../services/csv_import_service.dart';
import '../../../domain/value_objects/import_result.dart';
import '../library/library_viewmodel.dart';

/// CSV Import Screen - Import flashcards from CSV files.
/// 
/// **Feature:** @CARDMGMT-001 (CSV Import)
class CsvImportScreen extends StatefulWidget {
  const CsvImportScreen({super.key});

  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends State<CsvImportScreen> {
  bool _isImporting = false;
  ImportResult? _importResult;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from CSV'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInstructions(),
            const SizedBox(height: 24),
            if (_isImporting) _buildLoadingState(),
            if (_importResult != null) _buildResultDisplay(),
            if (_errorMessage != null) _buildErrorDisplay(),
            const SizedBox(height: 24),
            _buildSelectFileButton(),
            const SizedBox(height: 80), // Extra space at bottom
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'CSV Format Instructions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Your CSV file should have the following columns:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildRequirement('youtube_url (or url)', 'YouTube video URL or ID', true),
            _buildRequirement('title', 'Song title', true),
            _buildRequirement('artist', 'Artist name', true),
            _buildRequirement('album', 'Album name', false),
            _buildRequirement('start_at_seconds (or start_time)', 'Start time in seconds', false),
            const SizedBox(height: 12),
            const Text(
              'Example:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'youtube_url,title,artist,album,start_at_seconds\n'
                'dQw4w9WgXcQ,Never Gonna Give You Up,Rick Astley,,30',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String field, String description, bool required) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            required ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: required ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: field,
                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ': '),
                  TextSpan(text: description),
                  if (required)
                    const TextSpan(
                      text: ' (required)',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Importing cards...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('This may take a moment for large files'),
          ],
        ),
      ),
    );
  }

  Widget _buildResultDisplay() {
    final result = _importResult!;
    final hasErrors = result.failedCount > 0;

    return Card(
      color: hasErrors ? Colors.orange[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasErrors ? Icons.warning_amber : Icons.check_circle,
                  color: hasErrors ? Colors.orange : Colors.green,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Import Complete',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildResultRow('Total Rows', result.totalRows.toString(), Colors.blue),
            _buildResultRow('Successful', result.successCount.toString(), Colors.green),
            if (result.skippedCount > 0)
              _buildResultRow('Skipped (Duplicates)', result.skippedCount.toString(), Colors.orange),
            if (result.failedCount > 0)
              _buildResultRow('Failed', result.failedCount.toString(), Colors.red),
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Errors:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...result.errors.take(5).map((error) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• Row ${error.rowNumber}: ${error.reason}',
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  )),
              if (result.errors.length > 5)
                Text(
                  '...and ${result.errors.length - 5} more errors',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
            ],
            const SizedBox(height: 16),
            Text(
              result.getSummary(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (result.successCount > 0) ...[
              const SizedBox(height: 16),
              Tooltip(
                message: 'View imported flashcards in library',
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Refresh library and go back
                    context.read<LibraryViewModel>().loadCards();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.library_music),
                  label: const Text('View Library'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Import Failed',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectFileButton() {
    return Tooltip(
      message: 'Select a CSV file to import flashcards',
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _isImporting ? null : _selectAndImportFile,
          icon: const Icon(Icons.upload_file),
          label: Text(
            _importResult == null ? 'Select CSV File' : 'Import Another File',
          ),
        ),
      ),
    );
  }

  Future<void> _selectAndImportFile() async {
    // Capture context-dependent values before any async operations
    final importService = context.read<CsvImportService>();
    final libraryViewModel = context.read<LibraryViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        // User cancelled
        return;
      }

      final file = result.files.first;
      
      if (file.path == null) {
        setState(() {
          _errorMessage = 'Could not read file';
        });
        return;
      }

      // Start import
      setState(() {
        _isImporting = true;
        _importResult = null;
        _errorMessage = null;
      });
      
      // Import from file
      final importResult = await importService.importFromFile(File(file.path!));

      setState(() {
        _isImporting = false;
        _importResult = importResult;
      });

      await libraryViewModel.loadCards();

      // Show success snackbar
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(importResult.getSummary()),
          backgroundColor: importResult.failedCount > 0 ? Colors.orange : Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isImporting = false;
        _errorMessage = e.toString();
      });
    }
  }
}
