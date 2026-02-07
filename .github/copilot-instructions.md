# GitHub Copilot Instructions - BeatRecall

## Project Overview

BeatRecall is a **Flutter mobile application** for training music recognition skills using a **Spaced Repetition System (SRS)**. Users learn song titles and artists by listening to YouTube audio clips and rating their recall performance.

**Purpose:** Help users prepare for pub quiz music rounds through scientifically-proven spaced repetition.

**Current Phase:** Phase 0 - Planning & Setup (Week 2)

---

## Technical Stack

### Core Technologies
- **Framework:** Flutter 3.0+
- **Language:** Dart 3.0+
- **Database:** Isar (NoSQL local storage, high-performance)
- **Media:** `youtube_player_flutter` package for YouTube integration
- **State Management:** Provider (MVP), consider Riverpod later
- **Architecture:** Layered Architecture (Presentation → Service → Domain → Data)

### Key Packages
- `isar` (^3.1.0) - Local database
- `youtube_player_flutter` (^8.0.0) - Media playback
- `provider` (^6.0.0) - State management
- `mockito` (^5.4.0) - Testing

---

## Architecture Guidelines

### Layered Architecture (4 Layers)

**Presentation Layer (UI)** → Screens, Widgets, Providers  
↓  
**Service Layer (Business Logic)** → SRS Service, Review Service, Card Service  
↓  
**Domain Layer (Entities & Interfaces)** → Flashcard, ReviewLog, Repositories  
↓  
**Data Layer (Database, API)** → Isar Database, Repository Implementations

**Rules:**
- Dependencies flow **downward only**
- Upper layers never import from lower layers except through interfaces
- Each layer has a single responsibility
- Use dependency injection for testability

### Folder Structure

```
lib/
├── main.dart
├── presentation/          # UI layer - screens, widgets, providers
├── services/              # Business logic - srs_service, review_service
├── domain/                # Entities & interfaces - flashcard, repositories
└── data/                  # Data access - isar_database, repository_impl
```

---

## Domain Language (Ubiquitous Language)

**Always use these exact terms consistently across code, comments, and documentation:**

### Core Entities
- **Flashcard** (NOT "Card", "SongCard", "MusicCard") - A learning unit with YouTube clip + metadata
- **Review Session** (NOT "Study Session", "Quiz Session") - Period of reviewing due cards
- **Due Card** (NOT "Overdue Card", "Pending Card") - Card with `nextReviewDate <= now`
- **Review Log** (NOT "History Entry", "Log Entry") - Record of a single review
- **Review Queue** (NOT "Due Queue", "Pending List") - Ordered list of due cards

### SRS Concepts
- **SM-2 Algorithm** - The specific spaced repetition algorithm used
- **Ease Factor** (NOT "Easiness Factor", "Difficulty") - Multiplier for interval calculation (1.3 to 4.0)
- **Interval** - Days between reviews (NOT "Gap", "Period")
- **Repetition** - Count of consecutive successful reviews (NOT "Streak", "Count")
- **Rating** - User's self-assessment: Again (0), Hard (1-2), Good (3), Easy (4)

### Card States
- **New** - Never reviewed (`repetitions == 0`)
- **Learning** - In initial learning phase (`repetitions < 3`)
- **Review** - In long-term review phase (`repetitions >= 3`)

**Reference:** See `docs/product/GLOSSARY.md` for complete definitions

---

## Code Conventions

### Naming

**Classes:**
- Entity classes: Singular nouns (`Flashcard`, `ReviewLog`, `ReviewSession`)
- Service classes: Noun + "Service" (`SrsService`, `ReviewService`, `CardService`)
- Repository interfaces: Noun + "Repository" (`CardRepository`)
- Screens: Noun + "Screen" (`ReviewSessionScreen`, `DashboardScreen`)
- Widgets: Descriptive noun phrase (`FlashcardWidget`, `RatingButtonGroup`)

**Variables & Functions:**
- Use domain language exactly: `nextReviewDate`, `easeFactor`, `repetitions`
- Functions: Verb phrases (`fetchDueCards()`, `calculateNextInterval()`, `saveReviewLog()`)
- Booleans: is/has/can prefix (`isDueForReview`, `hasBeenReviewed`, `canStartReview`)

**Constants:**
- Upper snake case: `DEFAULT_EASE_FACTOR`, `MIN_EASE_FACTOR`, `MAX_INTERVAL_DAYS`
- Enums: PascalCase (`CardStatus`, `Rating`)

**File Naming:**
- Dart files: `snake_case.dart`
- Test files: `*_test.dart` (mirrors source file)
- Entities: `flashcard.dart` (NOT `song_card.dart`, `card.dart`)

---

## Database Schema (Isar)

### Flashcard Collection
- **Core:** `youtubeUrl`, `youtubeId`, `title`, `artist`, `startAtSeconds`
- **SRS:** `nextReviewDate`, `easeFactor` (2.5 default), `interval`, `repetitions`
- **Metadata:** `createdAt`, `updatedAt`
- **Computed:** `status` (new/learning/review), `isDue`
- **Indexes:** `youtubeId`, `nextReviewDate`

### ReviewLog Collection
- `flashcardId`, `timestamp`, `response` (0-4), `intervalBefore`, `intervalAfter`, `easeFactorAfter`

---

## SM-2 Algorithm

**CRITICAL: Follow exact formula in `docs/product/requirements/core/SRS.md`**

**Rating Effects:**
- **Again (0):** Reset to learning mode (interval=0, repetitions=0)
- **Hard (1-2):** Shorter interval, decrease ease factor by 0.15
- **Good (3):** Standard interval, maintain ease factor
- **Easy (4):** Longer interval, increase ease factor by 0.15

**Constraints:**
- Ease Factor: 1.3 to 4.0
- Initial intervals: 1 day, 6 days, then EF multiplier
- Max interval: 365 days

---

## Testing Strategy

- **70% Unit Tests** - Business logic, SRS calculations, data transformations
- **20% Integration Tests** - Database operations, service layer interactions
- **10% E2E Tests** - Critical user flows (review session, card import)

**Conventions:**
- Test IDs reference requirements: `@SRS-001`, `@FLASHSYS-003`, `@CARDMGMT-001-F05`
- Use Given-When-Then structure
- Test file mirrors source file: `srs_service.dart` → `srs_service_test.dart`

---

## Key Principles

### Error Handling
- Use custom exceptions with actionable messages
- Show user-friendly messages in UI
- Log technical details for debugging

### State Management (Provider)
- Use `ChangeNotifier` for reactive state
- Separate business logic from UI
- Inject dependencies through providers

### Performance
- **Database:** Use indexes and filters (avoid loading all then filtering)
- **Caching:** Cache dashboard statistics (60s TTL)
- **Pagination:** Load cards in batches (default 10 items)

### UI/UX
- Material Design 3 (`useMaterial3: true`)
- Accessibility: WCAG 2.1 AA compliance
- Color coding: Red (Again), Orange (Hard), Green (Good), Blue (Easy)
- Minimum touch target: 48x48 dp

---

## Documentation References

**Always consult these before implementing features:**

### Product Requirements
- **Glossary:** `docs/product/GLOSSARY.md` - Domain terminology
- **Core Features:** `docs/product/requirements/core/` - Detailed specs
  - `SRS.md` - Spaced repetition algorithm
  - `FLASHSYS.md` - Flashcard UI and player
  - `CARDMGMT.md` - Card CRUD and CSV import
  - `DUEQUEUE.md` - Review sessions
- **Dashboard:** `docs/product/requirements/additional/DASHBOARD.md`
- **User Stories:** `docs/product/user_stories/user_stories.md`

### Engineering Documentation  
- **Architecture:** `docs/engineering/architecture/architecture.md`
- **Setup:** `docs/engineering/setup/development_setup.md`
- **Testing:** `docs/engineering/testing/testing_strategy.md`
- **NFRs:** `docs/engineering/non_functional/non_functional_requirements.md`

### Templates
- **Detailed Spec Template:** `docs/product/requirements/TEMPLATE_DETAILED_SPEC.md`
- **Specification Process:** `docs/product/requirements/README_SPECIFICATION_PROCESS.md`

---

## Quick Reference

### Feature ID → Files Mapping
- `SRS-001 to 003` → `docs/product/requirements/core/SRS.md`
- `FLASHSYS-001 to 004` → `docs/product/requirements/core/FLASHSYS.md`
- `CARDMGMT-001 to 005` → `docs/product/requirements/core/CARDMGMT.md`
- `DUEQUEUE-001 to 002` → `docs/product/requirements/core/DUEQUEUE.md`
- `DASHBOARD-001` → `docs/product/requirements/additional/DASHBOARD.md`

### When in Doubt
1. **Check the Glossary** for correct terminology
2. **Reference the requirements** for acceptance criteria
3. **Follow the architecture** - respect layer boundaries
4. **Write tests first** when implementing SRS logic
5. **Use domain language** consistently in code and comments

---

## Don't Do This ❌

- ❌ Wrong terminology: `SongCard`, `difficulty`, `successStreak`, `dueDate`
- ❌ Breaking layer boundaries: UI accessing database directly
- ❌ Magic numbers without constants
- ❌ Unclear variable names: `n`, `ef`, `List<dynamic>`
- ❌ Missing null safety
- ❌ Silent error handling

---

## Additional Context for Copilot

- This is a **mobile-first** application (Android/iOS via Flutter)
- **Offline-first** design: All data stored locally in Isar
- **Simple auth**: No user accounts in MVP (single-user app)
- **No backend**: YouTube is the only external dependency
- **Learning domain**: Apply evidence-based SRS principles strictly
- **Target users**: Pub quiz enthusiasts, music learners

**Priority Order for MVP:**
1. SRS algorithm (must be correct)
2. Review session flow (core user experience)
3. CSV import (primary method for building library)
4. Dashboard (motivation and progress visibility)
5. Manual card creation (secondary import method)

When suggesting code, prefer:
- ✅ Explicit over implicit
- ✅ Domain language over technical jargon
- ✅ Immutability where possible
- ✅ Pure functions for business logic
- ✅ Dependency injection for testability

**Remember:** This is a learning application. Correctness of the SRS algorithm is more important than fancy UI. Get the spaced repetition right first.
