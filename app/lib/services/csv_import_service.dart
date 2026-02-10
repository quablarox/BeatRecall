import 'dart:io';
import 'package:csv/csv.dart';
import '../domain/factories/flashcard_factory.dart';
import '../domain/repositories/card_repository.dart';
import '../domain/value_objects/import_result.dart';
import 'youtube_id_extractor.dart';

/// Service for importing flashcards from CSV files.
///
/// Requirements: CARDMGMT-001 (CSV Import)
/// See: docs/product/requirements/core/CARDMGMT.md
class CsvImportService {
  final CardRepository _cardRepository;

  const CsvImportService(this._cardRepository);

  /// Imports flashcards from a CSV file.
  ///
  /// Expected CSV format (with header row):
  /// ```csv
  /// youtube_url,title,artist,album,year,genre,youtube_view_count,start_at_seconds
  /// https://www.youtube.com/watch?v=dQw4w9WgXcQ,Never Gonna Give You Up,Rick Astley,Whenever You Need Somebody,1987,Pop,1500000000,0
  /// ```
  ///
  /// Supported delimiters: comma (,), semicolon (;), tab (\t), pipe (|)
  ///
  /// Required columns:
  /// - youtube_url: YouTube URL or video ID
  /// - title: Song title
  /// - artist: Artist name
  ///
  /// Optional columns:
  /// - album: Album name
  /// - year: Release year (4-digit integer)
  /// - genre: Music genre
  /// - youtube_view_count: View count (integer)
  /// - start_at_seconds: Start time in seconds (defaults to 0)
  ///
  /// Returns [ImportResult] with statistics and error details.
  Future<ImportResult> importFromFile(File file) async {
    try {
      final csvString = await file.readAsString();
      return await importFromCsvString(csvString);
    } catch (e) {
      return ImportResult(
        totalRows: 0,
        successCount: 0,
        skippedCount: 0,
        failedCount: 0,
        errors: [
          ImportError(
            rowNumber: 0,
            reason: 'Failed to read file: ${e.toString()}',
          ),
        ],
      );
    }
  }

  /// Imports flashcards from CSV string content.
  Future<ImportResult> importFromCsvString(String csvContent) async {
    final List<ImportError> errors = [];
    int successCount = 0;
    int skippedCount = 0;
    int failedCount = 0;

    try {
      // Normalize content to handle BOMs and inconsistent line endings
      final normalizedCsv = _normalizeCsvContent(csvContent);

      // Parse CSV (auto-detect common delimiters)
      final List<List<dynamic>> rows = _parseCsvRows(normalizedCsv);

      if (rows.isEmpty) {
        return ImportResult(
          totalRows: 0,
          successCount: 0,
          skippedCount: 0,
          failedCount: 0,
          errors: [
            const ImportError(
              rowNumber: 0,
              reason: 'CSV file is empty',
            ),
          ],
        );
      }

      // Extract header and data rows
      final List<String> header =
          rows.first.map((cell) => cell.toString().trim().toLowerCase()).toList();
      final List<List<dynamic>> dataRows = rows.skip(1).toList();

      // Find column indices
      final int? urlIndex = _findColumnIndex(header, ['youtube_url', 'url']);
      final int? titleIndex = _findColumnIndex(header, ['title']);
      final int? artistIndex = _findColumnIndex(header, ['artist']);
      final int? albumIndex = _findColumnIndex(header, ['album']);
      final int? yearIndex = _findColumnIndex(header, ['year']);
      final int? genreIndex = _findColumnIndex(header, ['genre']);
      final int? viewCountIndex = _findColumnIndex(header, ['youtube_view_count', 'view_count', 'views']);
      final int? startTimeIndex =
          _findColumnIndex(header, ['start_at_seconds', 'start_time']);

      // Validate required columns exist
      if (urlIndex == null) {
        return ImportResult(
          totalRows: dataRows.length,
          successCount: 0,
          skippedCount: 0,
          failedCount: dataRows.length,
          errors: [
            const ImportError(
              rowNumber: 0,
              reason: 'Missing required column: youtube_url',
            ),
          ],
        );
      }

      if (titleIndex == null) {
        return ImportResult(
          totalRows: dataRows.length,
          successCount: 0,
          skippedCount: 0,
          failedCount: dataRows.length,
          errors: [
            const ImportError(
              rowNumber: 0,
              reason: 'Missing required column: title',
            ),
          ],
        );
      }

      if (artistIndex == null) {
        return ImportResult(
          totalRows: dataRows.length,
          successCount: 0,
          skippedCount: 0,
          failedCount: dataRows.length,
          errors: [
            const ImportError(
              rowNumber: 0,
              reason: 'Missing required column: artist',
            ),
          ],
        );
      }

      // Process each row
      for (int i = 0; i < dataRows.length; i++) {
        final rowNumber = i + 1; // 1-based (excluding header)
        final row = dataRows[i];

        // Extract values
        final String? youtubeUrl = _getCellValue(row, urlIndex);
        final String? title = _getCellValue(row, titleIndex);
        final String? artist = _getCellValue(row, artistIndex);
        final String? album = albumIndex != null ? _getCellValue(row, albumIndex) : null;
        final String? yearStr = yearIndex != null ? _getCellValue(row, yearIndex) : null;
        final String? genre = genreIndex != null ? _getCellValue(row, genreIndex) : null;
        final String? viewCountStr = viewCountIndex != null ? _getCellValue(row, viewCountIndex) : null;
        final String? startTimeStr =
            startTimeIndex != null ? _getCellValue(row, startTimeIndex) : null;

        // Validate YouTube URL
        if (youtubeUrl == null || youtubeUrl.isEmpty) {
          errors.add(ImportError(
            rowNumber: rowNumber,
            reason: 'Missing required field: youtube_url',
          ));
          failedCount++;
          continue;
        }

        final String? youtubeId = YouTubeIdExtractor.extract(youtubeUrl);
        if (youtubeId == null) {
          errors.add(ImportError(
            rowNumber: rowNumber,
            reason: 'Invalid YouTube URL format',
            fieldValue: youtubeUrl,
          ));
          failedCount++;
          continue;
        }

        // Validate title
        if (title == null || title.isEmpty) {
          errors.add(ImportError(
            rowNumber: rowNumber,
            reason: 'Missing required field: title',
          ));
          failedCount++;
          continue;
        }

        // Validate artist
        if (artist == null || artist.isEmpty) {
          errors.add(ImportError(
            rowNumber: rowNumber,
            reason: 'Missing required field: artist',
          ));
          failedCount++;
          continue;
        }

        // Parse and validate start time
        int startAtSecond = 0;
        if (startTimeStr != null && startTimeStr.isNotEmpty) {
          final parsed = int.tryParse(startTimeStr);
          if (parsed == null || parsed < 0) {
            errors.add(ImportError(
              rowNumber: rowNumber,
              reason: 'Invalid start_at_seconds: must be non-negative integer',
              fieldValue: startTimeStr,
            ));
            failedCount++;
            continue;
          }
          startAtSecond = parsed;
        }

        // Parse and validate year
        int? year;
        if (yearStr != null && yearStr.isNotEmpty) {
          final parsed = int.tryParse(yearStr);
          if (parsed == null || parsed < 1000 || parsed > 9999) {
            errors.add(ImportError(
              rowNumber: rowNumber,
              reason: 'Invalid year: must be a 4-digit year (1000-9999)',
              fieldValue: yearStr,
            ));
            failedCount++;
            continue;
          }
          year = parsed;
        }

        // Parse and validate view count
        int? viewCount;
        if (viewCountStr != null && viewCountStr.isNotEmpty) {
          final parsed = int.tryParse(viewCountStr);
          if (parsed == null || parsed < 0) {
            errors.add(ImportError(
              rowNumber: rowNumber,
              reason: 'Invalid youtube_view_count: must be non-negative integer',
              fieldValue: viewCountStr,
            ));
            failedCount++;
            continue;
          }
          viewCount = parsed;
        }

        // Check for duplicates
        final existingCard = await _cardRepository.findByYoutubeId(youtubeId);
        if (existingCard != null) {
          errors.add(ImportError(
            rowNumber: rowNumber,
            reason: 'Duplicate: Card with this YouTube ID already exists',
            fieldValue: youtubeId,
          ));
          skippedCount++;
          continue;
        }

        // Create and save flashcard
        try {
          final flashcard = FlashcardFactory.create(
            youtubeId: youtubeId,
            title: title,
            artist: artist,
            album: album,
            year: year,
            genre: genre,
            youtubeViewCount: viewCount,
            startAtSecond: startAtSecond,
          );

          await _cardRepository.save(flashcard);
          successCount++;
        } catch (e) {
          errors.add(ImportError(
            rowNumber: rowNumber,
            reason: 'Failed to save card: ${e.toString()}',
          ));
          failedCount++;
        }
      }

      return ImportResult(
        totalRows: dataRows.length,
        successCount: successCount,
        skippedCount: skippedCount,
        failedCount: failedCount,
        errors: errors,
      );
    } catch (e) {
      return ImportResult(
        totalRows: 0,
        successCount: successCount,
        skippedCount: skippedCount,
        failedCount: failedCount + 1,
        errors: [
          ...errors,
          ImportError(
            rowNumber: 0,
            reason: 'CSV parsing error: ${e.toString()}',
          ),
        ],
      );
    }
  }

  /// Finds column index by name (case-insensitive, tries multiple variations)
  int? _findColumnIndex(List<String> header, List<String> possibleNames) {
    for (int i = 0; i < header.length; i++) {
      final headerName = header[i].toLowerCase().trim();
      if (possibleNames.any((name) => headerName == name.toLowerCase())) {
        return i;
      }
    }
    return null;
  }

  /// Safely gets cell value from row
  String? _getCellValue(List<dynamic> row, int index) {
    if (index < 0 || index >= row.length) return null;
    final value = row[index]?.toString().trim();
    return value?.isEmpty == true ? null : value;
  }

  String _normalizeCsvContent(String csvContent) {
    var normalized = csvContent.replaceFirst(RegExp(r'^\uFEFF'), '');
    normalized = normalized.replaceAll('\r\n', '\n');
    return normalized.trim();
  }

  List<List<dynamic>> _parseCsvRows(String csvContent) {
    const delimiters = [',', ';', '\t', '|'];

    for (final delimiter in delimiters) {
      final rows = _parseCsvRowsWithDelimiter(csvContent, delimiter);
      if (rows.isEmpty) continue;

      final header =
          rows.first.map((cell) => cell.toString().trim().toLowerCase()).toList();
      final hasUrl = _findColumnIndex(header, ['youtube_url', 'url']) != null;
      final hasTitle = _findColumnIndex(header, ['title']) != null;
      final hasArtist = _findColumnIndex(header, ['artist']) != null;

      if (hasUrl && hasTitle && hasArtist) {
        return rows;
      }
    }

    return _parseCsvRowsWithDelimiter(csvContent, ',');
  }

  List<List<dynamic>> _parseCsvRowsWithDelimiter(
    String csvContent,
    String delimiter,
  ) {
    try {
      return CsvToListConverter(
        shouldParseNumbers: false, // Keep all as strings for validation
        eol: '\n', // Explicitly set end-of-line to handle various formats
        fieldDelimiter: delimiter,
      ).convert(csvContent);
    } catch (_) {
      return [];
    }
  }
}
