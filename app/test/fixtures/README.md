# Test Fixtures

This directory contains test data files used in unit and integration tests.

## CSV Format

All CSV files follow this format:
```csv
youtube_url,title,artist,start_at_seconds
```

**Required columns:**
- `youtube_url`: YouTube video ID or full URL
- `title`: Song title
- `artist`: Artist name

**Optional columns:**
- `start_at_seconds`: Start position in video (defaults to 0)

## CSV Test Files

### test_cards_valid.csv
Contains 10 valid flashcard entries with various YouTube URL formats:
- Direct video IDs
- Full YouTube URLs (youtube.com/watch?v=)
- Short URLs (youtu.be/)
- Mobile URLs (m.youtube.com)

All entries have valid data and can be successfully imported.

### test_cards_with_errors.csv
Contains a mix of valid and invalid entries to test error handling:
- Valid entries
- Invalid YouTube IDs
- Missing required fields (title, artist)
- Invalid start_at_seconds (non-numeric, negative)
- Empty YouTube URLs

### test_cards_duplicates.csv
Contains duplicate YouTube IDs to test duplicate detection:
- First entry is valid
- Second entry has same YouTube ID (should be skipped)
- Third entry is valid

### test_cards_pipe.csv
Pipe-delimited CSV that mimics the default example shared with users:
- Includes a UTF-8 BOM prefix to mirror exports from spreadsheet tools
- Uses `|` as the delimiter with standard headers
- Validates our delimiter auto-detection end-to-end via `importFromFile`

### test_cards_minimal.csv
Contains minimal required fields only (no album, no start_at_seconds):
- Tests default value handling
- Tests optional field support

## Usage in Tests

```dart
import 'dart:io';

// Load test fixture
final csvFile = File('test/fixtures/test_cards_valid.csv');
final csvContent = await csvFile.readAsString();

// Use in import service tests
final result = await importService.importFromCsvString(csvContent);
```
