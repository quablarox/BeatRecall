# BeatRecall - Product Specification

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

## 3. Functional Requirements (FR)

### Phase 1: Core MVP (SRS & Quiz Loop)
| ID | Feature | Description |
| :--- | :--- | :--- |
| **FR-1.1** | **SRS Logic (SM-2)** | Implementation of the SM-2 algorithm to calculate next review dates (Again, Hard, Good, Easy). |
| **FR-1.2** | **Flashcard Player** | Dual-sided card UI. Front: YouTube audio/video plays. Back: Title & Artist are revealed. |
| **FR-1.3** | **Manual Import** | Form to add songs via YouTube URL, Title, and Artist name. |
| **FR-1.4** | **Due Queue** | Logic to fetch only cards where `nextReviewDate <= now`. |

### Phase 2: Enhanced Management & Automation
| ID | Feature | Description |
| :--- | :--- | :--- |
| **FR-2.1** | **Audio Trimming** | Custom `startAt` timestamp for each song to skip intros. |
| **FR-2.2** | **Fuzzy Matching** | Answer validation using Levenshtein Distance for typo tolerance. |
| **FR-2.3** | **Auto-Metadata** | Fetching Title/Artist automatically via YouTube metadata. |
| **FR-2.4** | **Playlist Import** | Bulk-adding songs from public YouTube playlist URLs. |

---

## 4. Data Model (Entity Definition)

```dart
class SongCard {
  String id;            // Unique identifier
  String youtubeId;     // Extracted from URL
  String title;
  String artist;

  // SRS Data
  int interval;         // In days
  double easeFactor;    // Default: 2.5
  int repetitions;      // Successive correct answers
  DateTime nextReview;  // Timestamp for next quiz session

  // Configuration
  int startAtSecond;    // Custom start point for playback
}
```

---

## 5. UI/UX Requirements
- **Dashboard:** Display count of "Due Today" cards.
- **Quiz Loop:** Minimalist player, big "Show Answer" button, color-coded rating buttons.
- **Library:** Searchable list of all cards with Edit/Delete options.
