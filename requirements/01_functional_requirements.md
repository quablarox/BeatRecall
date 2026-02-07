# Functional Requirements - BeatRecall

## Document Information
- **Version:** 1.0
- **Last Updated:** 2026-02-07
- **Status:** Draft

---

## 1. Core Functional Requirements

### 1.1 Spaced Repetition System (SRS)

#### FR-1.1.1: SM-2 Algorithm Implementation
- **Priority:** High
- **Description:** Implement the SuperMemo-2 (SM-2) algorithm for optimal learning intervals
- **Acceptance Criteria:**
  - System calculates next review date based on user response (Again, Hard, Good, Easy)
  - Ease factor starts at 2.5 and adjusts based on performance
  - Interval calculation follows SM-2 formula
  - Minimum ease factor is 1.3
  - Maximum interval cap can be configured

#### FR-1.1.2: Review Scheduling
- **Priority:** High
- **Description:** Schedule and manage card reviews based on SRS calculations
- **Acceptance Criteria:**
  - Cards are scheduled for review at calculated datetime
  - System supports review queue management
  - Overdue cards are prioritized
  - Review history is tracked for each card

#### FR-1.1.3: Performance Tracking
- **Priority:** Medium
- **Description:** Track user performance over time
- **Acceptance Criteria:**
  - Store review history (date, response, interval)
  - Calculate success rate per card
  - Track total reviews completed
  - Support statistics export

### 1.2 Flashcard System

#### FR-1.2.1: Dual-Sided Card Interface
- **Priority:** High
- **Description:** Display flashcard with front (question) and back (answer) sides
- **Acceptance Criteria:**
  - Front side plays YouTube audio/video
  - Back side reveals title and artist
  - Smooth transition between sides
  - Visual indicator of card state (front/back)
  - Support for keyboard shortcuts

#### FR-1.2.2: YouTube Media Player
- **Priority:** High
- **Description:** Integrate YouTube player for audio/video playback
- **Acceptance Criteria:**
  - Play YouTube videos using `youtube_player_flutter`
  - Support custom start timestamp
  - Control playback (play, pause, stop)
  - Handle network errors gracefully
  - Support audio-only mode (optional)

#### FR-1.2.3: Answer Rating
- **Priority:** High
- **Description:** Allow users to rate their recall performance
- **Acceptance Criteria:**
  - Four rating buttons: Again, Hard, Good, Easy
  - Color-coded buttons for easy identification
  - Display next review interval for each option
  - Keyboard shortcuts for quick rating
  - Touch-friendly button size (min 44x44 points)

#### FR-1.2.4: Answer Input (Optional)
- **Priority:** Low
- **Description:** Allow users to type their answer before revealing
- **Acceptance Criteria:**
  - Optional text input for title and artist
  - Fuzzy matching validation
  - Visual feedback on correctness
  - Can be skipped to directly reveal answer

### 1.3 Card Management

#### FR-1.3.1: Manual Card Creation
- **Priority:** High
- **Description:** Create cards manually via form input
- **Acceptance Criteria:**
  - Form with fields: YouTube URL, Title, Artist
  - URL validation (valid YouTube URL format)
  - Required field validation
  - Extract YouTube ID from URL
  - Confirmation dialog after creation
  - Return to library after creation

#### FR-1.3.2: Card Editing
- **Priority:** Medium
- **Description:** Edit existing card properties
- **Acceptance Criteria:**
  - Edit all card fields (URL, title, artist, start time)
  - Preserve SRS data during edit
  - Validation on save
  - Cancel option to discard changes
  - Confirmation for destructive changes

#### FR-1.3.3: Card Deletion
- **Priority:** Medium
- **Description:** Delete cards from the system
- **Acceptance Criteria:**
  - Confirmation dialog before deletion
  - Permanent deletion (no undo initially)
  - Remove from all queues
  - Update statistics after deletion

#### FR-1.3.4: Card Search and Filter
- **Priority:** Medium
- **Description:** Search and filter cards in library
- **Acceptance Criteria:**
  - Search by title or artist (case-insensitive)
  - Filter by card status (new, learning, review)
  - Filter by due date range
  - Sort options (alphabetical, due date, creation date)
  - Display search result count

### 1.4 Due Queue Management

#### FR-1.4.1: Due Cards Retrieval
- **Priority:** High
- **Description:** Fetch cards that are due for review
- **Acceptance Criteria:**
  - Query: `nextReviewDate <= currentDateTime`
  - Sort by due date (oldest first)
  - Support batch loading for performance
  - Update queue after each review

#### FR-1.4.2: Review Session
- **Priority:** High
- **Description:** Manage continuous review session
- **Acceptance Criteria:**
  - Display progress (X of Y cards)
  - Navigate through due cards sequentially
  - Support session pause/resume
  - Session summary at completion
  - Option to review more cards when queue is empty

---

## 2. Phase 2 Features

### 2.1 Audio Trimming

#### FR-2.1.1: Custom Start Timestamp
- **Priority:** Medium
- **Description:** Set custom start point for each song
- **Acceptance Criteria:**
  - Field for start timestamp in seconds
  - Preview playback from set timestamp
  - Default to 0 if not set
  - UI control for easy timestamp selection
  - Save timestamp with card

### 2.2 Fuzzy Matching

#### FR-2.2.1: Answer Validation
- **Priority:** Medium
- **Description:** Validate typed answers with typo tolerance
- **Acceptance Criteria:**
  - Use Levenshtein Distance algorithm
  - Configurable threshold (e.g., 80% similarity)
  - Case-insensitive comparison
  - Ignore special characters and spacing
  - Visual feedback (correct/incorrect/partial)

### 2.3 Auto-Metadata Retrieval

#### FR-2.3.1: YouTube Metadata Fetch
- **Priority:** Medium
- **Description:** Automatically fetch song metadata from YouTube
- **Acceptance Criteria:**
  - Extract title from YouTube API
  - Parse artist name from title (if possible)
  - Pre-fill form fields with fetched data
  - Allow manual override
  - Handle API errors gracefully

### 2.4 Playlist Import

#### FR-2.4.1: Bulk Import from Playlist
- **Priority:** Low
- **Description:** Import multiple songs from YouTube playlist
- **Acceptance Criteria:**
  - Accept YouTube playlist URL
  - Fetch all videos in playlist
  - Display preview list with checkboxes
  - Batch create cards
  - Progress indicator during import
  - Error handling for unavailable videos

---

## 3. Additional Features

### 3.1 Dashboard

#### FR-3.1.1: Overview Display
- **Priority:** High
- **Description:** Show key statistics on main screen
- **Acceptance Criteria:**
  - Count of due cards today
  - Total cards in library
  - Success rate (last 7 days)
  - Review streak counter
  - Quick access to review session

### 3.2 Settings

#### FR-3.2.1: Application Settings
- **Priority:** Medium
- **Description:** Configure app behavior
- **Acceptance Criteria:**
  - SRS parameters (ease factor, intervals)
  - Default playback duration
  - Audio-only mode toggle
  - Theme selection (light/dark)
  - Language selection

#### FR-3.2.2: Data Management
- **Priority:** Medium
- **Description:** Manage application data
- **Acceptance Criteria:**
  - Export database to file
  - Import database from file
  - Clear all data (with confirmation)
  - Storage space indicator

---

## 4. Future Considerations

### 4.1 Potential Features
- **FR-4.1.1:** Spotify integration
- **FR-4.2.1:** Collaborative playlists
- **FR-4.3.1:** Offline mode with cached audio
- **FR-4.4.1:** Achievement system
- **FR-4.5.1:** Social features (leaderboards)
- **FR-4.6.1:** Custom card types (e.g., album covers)
- **FR-4.7.1:** Advanced statistics and analytics

---

## 5. Cross-Cutting Requirements

### 5.1 Performance
- App startup time < 2 seconds
- Database queries < 100ms for typical operations
- YouTube player loading < 3 seconds (network dependent)
- Smooth animations (60 FPS)

### 5.2 Reliability
- No data loss on app crash
- Graceful handling of network issues
- Automatic retry for failed operations
- Data validation on all inputs

### 5.3 Usability
- Intuitive navigation (max 3 taps to any feature)
- Consistent UI patterns
- Clear error messages
- Responsive feedback for all actions
- Support for accessibility features

### 5.4 Compatibility
- Android 6.0 (API 23) and above
- iOS 12.0 and above
- Support for tablets and large screens
- Portrait and landscape orientations
