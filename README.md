# BeatRecall - Product Specification

> **📚 Full Documentation:** See [docs/README.md](docs/README.md) for complete navigation

## 1. Project Vision
BeatRecall is a mobile application built with **Flutter** designed to help users train their music recognition skills for Pub Quizzes. It utilizes a **Spaced Repetition System (SRS)**—similar to Anki—to optimize the learning process for song titles and artists using **YouTube** as the primary media source.

---

## 2. Technical Stack
- **Framework:** Flutter (Android/iOS)
- **Language:** Dart
- **Database:** Isar (NoSQL) for high-performance local persistence.
- **Media:** `youtube_player_flutter` for YouTube integration.
- **State Management:** Provider or Riverpod.
- **Architecture:** Layered Architecture (Data, Domain, Service, Presentation).

---

## 3. Functional Requirements

### Phase 1: Core MVP (SRS & Quiz Loop)
| ID | Feature | Status | Description |
| :--- | :--- | :---: | :--- |
| **SRS-001** | **SRS Logic (SM-2)** | ✅ | Implementation of the SM-2 algorithm to calculate next review dates (Again, Hard, Good, Easy). **46 tests passing** |
| **CARDMGMT-001** | **CSV Import** | ✅ | CSV bulk import with validation, duplicate detection, error reporting. **40 tests passing** |
| **CARDMGMT-005** | **Library Screen** | ✅ | List cards with search, filters (status/due date), and sorting. **23 tests passing** |
| **CARDMGMT-002** | **Manual Card Creation** | ⏳ | Add songs via form with YouTube URL, Title, and Artist name. |
| **FLASHSYS-001/002** | **Flashcard Player** | ⏳ | Dual-sided card UI. Front: YouTube audio/video plays. Back: Title & Artist are revealed. |
| **DUEQUEUE-001/002** | **Due Queue & Sessions** | ⏳ | Logic to fetch cards where `nextReviewDate <= now` and manage review sessions. |

**Current Status:** Sprint 2 (40% complete) | **Tests:** 113 passing

### Phase 2: Enhanced Management & Automation
| ID | Feature | Description |
| :--- | :--- | :--- |
| **FR-2.1** | **Audio Trimming** | Custom start timestamp (in seconds) for each song to skip intros. |
| **FR-2.2** | **Fuzzy Matching** | Answer validation using Levenshtein Distance for typo tolerance. |
| **FR-2.3** | **Auto-Metadata** | Fetching Title/Artist automatically via YouTube metadata. |
| **FR-2.4** | **Playlist Import** | Bulk-adding songs from public YouTube playlist URLs. |

---

## 4. Data Model (Entity Definition)

```dart
class Flashcard {
  String uuid;          // Unique identifier (UUID v4)
  String youtubeId;     // Extracted from URL
  String title;
  String artist;

  // SRS Data
  int intervalDays;     // In days
  double easeFactor;    // Default: 2.5
  int repetitions;      // Successive correct answers
  DateTime nextReviewDate;  // Timestamp for next review

  // Configuration
  int startAtSecond;    // Start Timestamp (seconds)
  
  // Metadata
  DateTime createdAt;
  DateTime updatedAt;
}
```

---

## 5. UI/UX Requirements
- **Dashboard:** Display count of "Due Today" cards.
- **Quiz Loop:** Minimalist player, big "Show Answer" button, color-coded rating buttons.
- **Library:** Searchable list of all cards with Edit/Delete options.
