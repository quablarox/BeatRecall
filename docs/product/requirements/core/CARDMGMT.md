# CARDMGMT - Card Management

**Feature ID:** `CARDMGMT`  
**Version:** 1.0  
**Last Updated:** 2026-02-09  
**Status:** Draft

## Table of Contents
- [Feature Overview](#feature-overview)
- [Requirements](#requirements)
  - [CARDMGMT-001: CSV Import](#cardmgmt-001-csv-import-)
  - [CARDMGMT-002: Manual Card Creation](#cardmgmt-002-manual-card-creation)
  - [CARDMGMT-003: Card Editing](#cardmgmt-003-card-editing)
  - [CARDMGMT-004: Card Deletion](#cardmgmt-004-card-deletion)
  - [CARDMGMT-005: Card Search and Filter](#cardmgmt-005-card-search-and-filter)
- [User Flows](#user-flows)
- [Future Enhancements](#future-enhancements)
- [Test References](#test-references)
- [Related Documents](#related-documents)

---

## Feature Overview

Card Management provides tools for creating, editing, deleting, searching, and bulk importing flashcards. Users can build their music quiz library through CSV import for bulk operations or manual creation for individual cards.

**Key Benefits:**
- Quick bulk import via CSV files
- Flexible manual card creation
- Full CRUD operations
- Powerful search and filtering
- Data validation and duplicate detection

---

## Requirements

### CARDMGMT-001: CSV Import ⭐

**Priority:** High  
**Status:** Not Started

**Description:**  
Load flashcards in bulk from a CSV file. This is the primary method for quickly building a card library, especially for users with existing music collections or playlists.

**Acceptance Criteria:**
- User can select a CSV file from device storage (via file picker)
- CSV format supports header row with columns:
  - `youtube_url` (required): Full YouTube URL or video ID
  - `title` (required): Song title
  - `artist` (required): Artist name
  - `album` (optional): Album name
  - `year` (optional): Release year
  - `genre` (optional): Genre
  - `youtube_view_count` (optional): YouTube view count
  - `start_at_seconds` (optional): Start timestamp in seconds, defaults to 0
- CSV parsing supports common delimiters:
  - Comma (`,`) 
  - Semicolon (`;`)
  - Tab (`\t`)
  - Pipe (`|`)
- Each row is validated before import:
  - `youtube_url` must be a valid YouTube URL format
  - `title` and `artist` must be non-empty strings
  - `start_at_seconds` must be a non-negative integer if provided
- Invalid rows are skipped with detailed error reason logged:
  - "Invalid YouTube URL format"
  - "Missing required field: title"
  - "Missing required field: artist"
  - "Invalid start_at_seconds: must be non-negative integer"
- Duplicate detection:
  - Check for existing cards with same YouTube ID
  - Skip duplicates and report count
  - Option to "Update existing" vs "Skip duplicates" (future enhancement)
- Import summary displayed:
  - Total rows in CSV
  - Successfully imported
  - Skipped (duplicates)
  - Failed (validation errors)
- Preview mode (optional): Show first 5 rows before confirming import
- Default `start_at_seconds` to 0 when column is missing or empty
- Progress indicator for large CSV files (> 50 rows)

**Technical Notes:**
- Use `csv` package for parsing
- Use `file_picker` package for file selection
- Extract YouTube ID from various URL formats:
  - `https://www.youtube.com/watch?v=VIDEO_ID`
  - `https://youtu.be/VIDEO_ID`
  - `VIDEO_ID` (direct ID)

**Example CSV:**
```csv
youtube_url,title,artist,album,year,genre,youtube_view_count,start_at_seconds
https://www.youtube.com/watch?v=dQw4w9WgXcQ,Never Gonna Give You Up,Rick Astley,Whenever You Need Somebody,1987,Pop,1400000000,0
https://youtu.be/9bZkp7q19f0,Gangnam Style,PSY,,2012,K-Pop,5000000000,30
kJQP7kiw5Fk,Despacito,Luis Fonsi,,,Reggaeton,,15
```

---

### CARDMGMT-002: Manual Card Creation

**Priority:** Medium  
**Status:** Not Started

**Description:**  
Create individual flashcards manually via a form. Useful for adding single cards or when CSV import is not available.

**Acceptance Criteria:**
- Form with fields:
  - YouTube URL (text input, required)
  - Title (text input, required)
  - Artist (text input, required)
  - Album (text input, optional)
  - Year (number input, optional)
  - Genre (text input, optional)
  - YouTube View Count (number input, optional)
  - Start Time (number input, optional, default: 0)
- URL validation:
  - Must be valid YouTube URL format
  - Extract and validate YouTube video ID
  - Display error message for invalid URLs
- Required field validation:
  - Show error if title or artist is empty
  - Disable "Save" button until all required fields are valid
- YouTube ID extraction from URL
- Duplicate detection:
  - Warn if card with same YouTube ID already exists
  - Allow user to proceed or cancel
- Preview playback (optional):
  - Show YouTube player with start time
  - Confirm playback before saving
- Confirmation dialog after creation: "Card added successfully"
- Return to library view after creation
- Form reset after successful creation (if user stays on form)

**Design Notes:**
- Clear, simple form layout
- Real-time validation feedback
- Helpful error messages

---

### CARDMGMT-003: Card Editing

**Priority:** Medium  
**Status:** Not Started

**Description:**  
Edit existing flashcard properties. Users can correct mistakes, update metadata, or adjust start times.

**Acceptance Criteria:**
- Edit all card fields:
  - YouTube URL
  - Title
  - Artist
  - Album
  - Year
  - Genre
  - YouTube View Count
  - Start time (in seconds)
- Preserve SRS data during edit:
  - `nextReviewDate`
  - `easeFactor`
  - `interval`
  - `reviewHistory`
- Validation on save (same rules as creation)
- Cancel option to discard changes
- Confirmation dialog for destructive changes (e.g., changing YouTube URL)
- Changes take effect immediately in library and review queue
- Edit form pre-populated with current values

**Notes:**
- Changing YouTube URL effectively creates a new card (consider warning)
- SRS data should NOT reset on edit (unless URL changes)

---

### CARDMGMT-004: Card Deletion

**Priority:** Medium  
**Status:** Not Started

**Description:**  
Delete flashcards from the system permanently. Useful for removing incorrect or unwanted cards.

**Acceptance Criteria:**
- Confirmation dialog before deletion:
  - Display card title and artist
  - "Are you sure you want to delete this card?"
  - "Delete" button (red/destructive)
  - "Cancel" button
- Permanent deletion (no undo in MVP)
- Remove card from:
  - Library
  - All review queues
  - Due queue (if currently due)
- Update statistics after deletion:
  - Decrement total card count
  - Remove from "cards reviewed" count if applicable
- Success message: "Card deleted"
- Return to library view

**Notes:**
- Future enhancement: Soft delete with undo/trash folder
- Consider export before delete warning for large libraries

---

### CARDMGMT-005: Card Search and Filter

**Priority:** Medium  
**Status:** Not Started

**Description:**  
Search and filter flashcards in the library view. Essential for managing large card collections.

**Acceptance Criteria:**
- Search by title or artist:
  - Case-insensitive search
  - Partial match support (e.g., "beat" matches "Beatles")
  - Real-time search results as user types
- Filter by card status:
  - **New:** Never reviewed (`repetitions == 0`)
  - **Learning:** In learning phase (`repetitions > 0 && repetitions < 3`)
  - **Review:** In review phase (`repetitions >= 3`)
- Filter by due date range:
  - Due today
  - Overdue (due before today)
  - Due this week
  - All cards
- Sort options:
  - Alphabetical (A-Z, Z-A)
  - Due date (oldest first, newest first)
  - Creation date (newest first, oldest first)
  - Artist name (A-Z)
- Display search result count: "Showing X of Y cards"
- Clear filters button to reset all filters and search
- Persist filter/sort preferences (optional)

**Performance Notes:**
- Optimize search for large libraries (> 1000 cards)
- Consider debouncing search input (300ms delay)

---

## User Flows

### CSV Import Flow
```
1. User taps "Import from CSV" button
   ↓
2. File picker opens
   ↓
3. User selects CSV file
   ↓
4. System validates and parses CSV
   ↓
5. Preview shown (optional): First 5 rows
   ↓
6. User confirms import
   ↓
7. Progress indicator during import
   ↓
8. Import summary displayed:
   - 47 cards imported
   - 3 duplicates skipped
   - 2 failed validation
   ↓
9. Return to library with new cards visible
```

### Manual Creation Flow
```
1. User taps "Add Card" button
   ↓
2. Form appears with empty fields
   ↓
3. User enters YouTube URL
   ↓
4. System validates URL and extracts video ID
   ↓
5. User enters title and artist
   ↓
6. (Optional) User adjusts start time
   ↓
7. User taps "Save"
   ↓
8. Duplicate check performed
   ↓
9. Card saved to database
   ↓
10. Confirmation: "Card added successfully"
   ↓
11. Return to library
```

---

## Future Enhancements

**Potential Subdivisions (Detailed Spec Phase):**

#### CARDMGMT-001: CSV Import
- `CARDMGMT-001-F01`: Open file picker and read CSV file
- `CARDMGMT-001-F02`: Parse CSV with header detection
- `CARDMGMT-001-F03`: Validate each row (URL, title, artist, start_at_seconds)
- `CARDMGMT-001-F04`: Extract YouTube ID from URL
- `CARDMGMT-001-F05`: Check for duplicates
- `CARDMGMT-001-F06`: Import valid rows to database
- `CARDMGMT-001-F07`: Generate import summary
- `CARDMGMT-001-F08`: Display progress indicator

#### CARDMGMT-002: Manual Card Creation
- `CARDMGMT-002-F01`: Render creation form
- `CARDMGMT-002-F02`: Validate YouTube URL in real-time
- `CARDMGMT-002-F03`: Validate required fields
- `CARDMGMT-002-F04`: Extract YouTube ID
- `CARDMGMT-002-F05`: Check for duplicates
- `CARDMGMT-002-F06`: Save card to database
- `CARDMGMT-002-F07`: Show confirmation message

#### CARDMGMT-003: Card Editing
- `CARDMGMT-003-F01`: Load card data into form
- `CARDMGMT-003-F02`: Validate changes
- `CARDMGMT-003-F03`: Preserve SRS data
- `CARDMGMT-003-F04`: Update card in database
- `CARDMGMT-003-F05`: Refresh library view

#### CARDMGMT-004: Card Deletion
- `CARDMGMT-004-F01`: Show confirmation dialog
- `CARDMGMT-004-F02`: Delete card from database
- `CARDMGMT-004-F03`: Remove from queues
- `CARDMGMT-004-F04`: Update statistics

#### CARDMGMT-005: Card Search and Filter
- `CARDMGMT-005-F01`: Implement text search (title/artist)
- `CARDMGMT-005-F02`: Filter by card status
- `CARDMGMT-005-F03`: Filter by due date range
- `CARDMGMT-005-F04`: Apply sort options
- `CARDMGMT-005-F05`: Display result count
- `CARDMGMT-005-F06`: Clear filters

---

## Test References

**Gherkin Scenario Examples:**

```gherkin
@CARDMGMT-001
Scenario: Successfully import cards from valid CSV
  Given a CSV file with 10 valid card entries
  When I select the file and confirm import
  Then 10 cards should be added to my library
  And I should see "10 cards imported successfully"

@CARDMGMT-001
Scenario: Skip duplicate cards during CSV import
  Given my library contains a card with YouTube ID "dQw4w9WgXcQ"
  And a CSV file contains a row with the same YouTube ID
  When I import the CSV
  Then the duplicate should be skipped
  And I should see "1 duplicate skipped" in the summary

@CARDMGMT-001
Scenario: Skip invalid rows and report errors
  Given a CSV file with 3 rows
  And row 2 has an invalid YouTube URL
  When I import the CSV
  Then 2 cards should be imported
  And 1 row should be skipped
  And I should see "Invalid YouTube URL format" for row 2

@CARDMGMT-002
Scenario: Create card manually with valid data
  Given I am on the card creation form
  When I enter a valid YouTube URL "https://www.youtube.com/watch?v=abc123"
  And I enter title "Test Song"
  And I enter artist "Test Artist"
  And I tap "Save"
  Then a new card should be created
  And I should see "Card added successfully"

@CARDMGMT-005
Scenario: Search cards by title
  Given my library contains 20 cards
  And one card has title "Bohemian Rhapsody"
  When I search for "bohemian"
  Then I should see 1 card in the results
  And the card should be "Bohemian Rhapsody"
```

---

## Related Documents

- [SRS.md](SRS.md) - SRS data preserved during edits
- [FLASHSYS.md](FLASHSYS.md) - Cards used in review sessions
- [Glossary](../../GLOSSARY.md) - Domain terminology (Card Status, CSV Import, Validation, etc.)
- [Architecture](../../../engineering/architecture/architecture.md) - Data layer implementation
- [User Stories](../../user_stories/user_stories.md) - Stories 2.1-2.5
