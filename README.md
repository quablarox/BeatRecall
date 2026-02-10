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
| **SRS-001** | **SRS Logic (SM-2)** | ✅ | Implementation of the SM-2 algorithm to calculate next review dates (Again, Hard, Good, Easy). **59 tests passing** |
| **CARDMGMT-001** | **CSV Import** | ✅ | CSV bulk import with validation, duplicate detection, error reporting, and common delimiters support. **40 tests passing** |
| **CARDMGMT-005** | **Library Screen** | ✅ | List cards with search, filters (status/due date), and sorting. **23 tests passing** |
| **CARDMGMT-003** | **Card Editing** | ✅ | Edit card details with pre-filled form and update operations. |
| **CARDMGMT-004** | **Card Deletion** | ✅ | Delete cards with confirmation dialog and repository cleanup. |
| **CARDMGMT-002** | **Manual Card Creation** | ⏳ | Add songs via form with YouTube URL, Title, and Artist name. |
| **FLASHSYS-001/002/005** | **Flashcard Player** | ✅ | Dual-sided card UI. Front: YouTube audio/video plays with audio-only mode. Back: Title & Artist are revealed. Enhanced interval display. Keyboard shortcuts for rating. **13 tests passing** |
| **FLASHSYS-006** | **Player Skip Controls** | ✅ | Skip backward/forward buttons (-10s/+10s) for precise playback navigation during review. |
| **FLASHSYS-007** | **Dynamic Offset Adjustment** | ✅ | "Set Start" button to update card start timestamp from current playback position with confirmation dialog. |
| **FLASHSYS-008** | **Quick Edit Access** | ✅ | Edit button in quiz screen AppBar for quick access to card editing without leaving review session. |
| **DUEQUEUE-001/002/003** | **Due Queue & Sessions** | ✅ | Logic to fetch cards with continuous session mode until no more due. Daily new cards limit integration. **11 tests passing** |
| **DASHBOARD-001** | **Dashboard** | ✅ | Overview with stats (total/due cards, success rate, streak), quick actions, refresh. Reactive to settings changes. **14 tests passing** |
| **SETTINGS-001/002/003** | **Settings System** | ✅ | Daily new cards limit (0-999), audio-only mode, theme switching, auto-play toggle. Reactive display in UI. **37 tests passing** |
| **SRS-001** | **Granular Intervals (Anki-like)** | ✅ | Modified SM-2 with minute-level precision: Again=1m, Hard=10m, Good=1d→3d, Easy=4d→7d. Anki-style learning steps with dynamic queue management. **49 tests passing** |
| **DUEQUEUE-004** | **Dynamic Queue Management** | ✅ | Cards respect actual due times, new cards inserted on-demand, deterministic ordering (nextReviewDate+UUID), session state preserved. **16 tests passing** |

**Current Status:** Sprint 4.7 Complete | **Tests:** 224 passing

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
  int intervalMinutes;  // Interval in minutes (1440 = 1 day)
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
- **Dashboard:** Overview stats (total, due, reviewed cards, success rate, streak), quick action buttons (Start Review, Library, Import CSV), pull-to-refresh.
- **Quiz Loop:** YouTube player, "Show Answer" button, color-coded rating buttons (Again/Hard/Good/Easy), keyboard shortcuts (1-4 or A/H/G/E), next interval display, tooltips, session summary.
- **Library:** Searchable list with filters (status, due date), sort options, card details, Edit/Delete options, debug reset progress.
- **Branding:** App icons for all platforms (Android/iOS/web/Windows/macOS), splash screens (Android/iOS/web with Android 12 support).
