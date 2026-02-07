# Functional Requirements - Phase 2 (BeatRecall)

## Document Information
- **Version:** 1.0
- **Last Updated:** 2026-02-07
- **Status:** Draft

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
