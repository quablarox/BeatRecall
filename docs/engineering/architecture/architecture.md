# Architecture Documentation - BeatRecall

## Document Information
- **Version:** 1.0
- **Last Updated:** 2026-02-07
- **Status:** Draft

## Table of Contents
- [1. Architecture Overview](#1-architecture-overview)
  - [1.1 Development Priorities](#11-development-priorities)
  - [1.2 Code Style Preferences](#12-code-style-preferences)
- [2. Layer Responsibilities](#2-layer-responsibilities)
- [3. Naming Conventions](#3-naming-conventions)
- [4. Project Structure](#4-project-structure)
- [5. Data Flow](#5-data-flow)
- [6. State Management](#6-state-management)
- [7. Testing Architecture](#7-testing-architecture)
- [8. Dependency Injection](#8-dependency-injection)

---

## 1. Architecture Overview

BeatRecall follows a **Layered Architecture** pattern with clear separation of concerns. This architecture promotes:
- **Maintainability:** Clear boundaries between layers
- **Testability:** Each layer can be tested independently
- **Scalability:** Easy to add new features
- **Flexibility:** Can swap implementations without affecting other layers

### 1.1 Development Priorities

**Core Principle:** SRS correctness > UI polish

**Rationale:** BeatRecall is a learning application. The spaced repetition algorithm must be implemented correctly for the app to be effective. A simple but correct implementation is better than a beautiful but flawed one.

**Implications:**
- Thorough testing of SRS calculations (70% unit test coverage minimum)
- Clear, explicit code over clever abstractions
- Domain language from GLOSSARY.md used consistently
- Pure functions for business logic where possible

### 1.2 Code Style Preferences

- **Explicit over implicit:** Clear code > clever code
- **Domain language:** Use exact terms from GLOSSARY.md (Flashcard not Card, Ease Factor not Difficulty)
- **Immutability:** Prefer const constructors, final fields, return new instances
- **Pure functions:** Business logic should be side-effect free where possible
- **Dependency Injection:** Constructor injection for testability

### 1.3 Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  (UI, Screens, Widgets, State Management)               │
│  • Dashboard, Quiz, Library, Settings screens           │
│  • Reusable widgets                                     │
│  • Providers/Controllers (Provider or Riverpod)         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                    SERVICE LAYER                         │
│  (Business Logic, Algorithms)                           │
│  • SRS Service (SM-2 algorithm)                         │
│  • YouTube Service                                      │
│  • Database Service                                     │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                          │
│  (Business Rules, Use Cases, Entities)                  │
│  • Review Card use case                                 │
│  • Add Card use case                                    │
│  • Domain entities                                      │
│  • Repository interfaces                                │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                     DATA LAYER                           │
│  (Data Access, Models, Repositories)                    │
│  • Repository implementations                           │
│  • Data models                                          │
│  • Data sources (Isar, YouTube API)                     │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Layer Details

### 2.1 Presentation Layer

**Responsibility:** User Interface and User Interaction

**Components:**
- **Screens:** Full-page views (Dashboard, Quiz, Library, Settings)
- **Widgets:** Reusable UI components (CardWidget, RatingButton)
- **Providers/Controllers:** State management (using Provider or Riverpod)

**Example Structure:**
```
lib/presentation/
├── screens/
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   └── dashboard_provider.dart
│   ├── quiz/
│   │   ├── quiz_screen.dart
│   │   ├── quiz_provider.dart
│   │   └── widgets/
│   │       ├── flashcard_widget.dart
│   │       └── rating_buttons.dart
│   └── library/
│       ├── library_screen.dart
│       └── library_provider.dart
└── widgets/
    ├── common/
    │   ├── custom_button.dart
    │   └── loading_indicator.dart
    └── youtube_player_widget.dart
```

**Key Principles:**
- UI components should not contain business logic
- Use state management for reactive UI updates
- Keep widgets small and focused
- Separate stateful and stateless widgets appropriately

---

### 2.2 Service Layer

**Responsibility:** Business Logic and External Integrations

**Components:**
- **SRS Service:** Implements SM-2 algorithm
- **YouTube Service:** Handles YouTube API integration
- **Database Service:** Manages Isar database connection

**Example Structure:**
```
lib/services/
├── srs_service.dart          # SM-2 algorithm implementation
├── youtube_service.dart       # YouTube API integration
├── database_service.dart      # Isar database management
└── storage_service.dart       # Local storage for settings
```

**SRS Service Example:**
```dart
class SRSService {
  /// Calculate next review date based on SM-2 algorithm
  ReviewResult calculateNextReview({
    required int currentInterval,
    required double currentEaseFactor,
    required int currentRepetitions,
    required Rating rating,
  }) {
    // SM-2 algorithm implementation
    // ...
  }
}

enum Rating { again, hard, good, easy }

class ReviewResult {
  final int nextInterval;
  final double nextEaseFactor;
  final int nextRepetitions;
  final DateTime nextReviewDate;
}
```

**YouTube Service Example:**
```dart
class YouTubeService {
  /// Extract YouTube video ID from URL
  String? extractVideoId(String url) {
    // Extract ID from various YouTube URL formats
    // ...
  }

  /// Fetch video metadata (requires API key)
  Future<VideoMetadata?> fetchMetadata(String videoId) async {
    // Call YouTube API
    // ...
  }
}

class VideoMetadata {
  final String title;
  final String? artist;
  final int durationSeconds;
}
```

---

### 2.3 Domain Layer

**Responsibility:** Business Rules and Core Logic

**Components:**
- **Entities:** Core business objects (Flashcard entity)
- **Use Cases:** Specific business operations
- **Repository Interfaces:** Abstract data access

**Example Structure:**
```
lib/domain/
├── entities/
│   └── flashcard.dart
├── repositories/
│   └── card_repository.dart
└── use_cases/
    ├── review_card_use_case.dart
    ├── add_card_use_case.dart
    ├── get_due_cards_use_case.dart
    └── delete_card_use_case.dart
```

**Entity Example:**
```dart
class Flashcard {
  final int id;
  final String youtubeId;
  final String title;
  final String artist;
  
  // SRS data
  final int intervalDays;
  final double easeFactor;
  final int repetitions;
  final DateTime nextReviewDate;
  
  // Configuration
  final int startAtSecond;
  
  const Flashcard({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.artist,
    this.intervalDays = 0,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    required this.nextReviewDate,
    this.startAtSecond = 0,
  });
}
```

**Use Case Example:**
```dart
class ReviewCardUseCase {
  final CardRepository repository;
  final SRSService srsService;

  ReviewCardUseCase(this.repository, this.srsService);

  Future<Flashcard> execute(String cardId, Rating rating) async {
    final card = await repository.getCardById(cardId);
    
    final result = srsService.calculateNextReview(
      currentInterval: card.intervalDays,
      currentEaseFactor: card.easeFactor,
      currentRepetitions: card.repetitions,
      rating: rating,
    );
    
    final updatedCard = card.copyWith(
      intervalDays: result.nextInterval,
      easeFactor: result.nextEaseFactor,
      repetitions: result.nextRepetitions,
      nextReviewDate: result.nextReviewDate,
    );
    
    await repository.updateCard(updatedCard);
    return updatedCard;
  }
}
```

---

### 2.4 Data Layer

**Responsibility:** Data Persistence and External Data Sources

**Components:**
- **Models:** Data transfer objects (DTOs)
- **Repositories:** Concrete implementations
- **Data Sources:** Local (Isar) and Remote (YouTube API)

**Example Structure:**
```
lib/data/
├── models/
│   └── flashcard_model.dart
├── repositories/
│   └── card_repository_impl.dart
└── data_sources/
    ├── local/
    │   └── isar_data_source.dart
    └── remote/
        └── youtube_data_source.dart
```

**Model Example (Isar):**
```dart
@collection
class FlashcardModel {
  Id id = Isar.autoIncrement;
  
  late String youtubeId;
  late String title;
  late String artist;
  
  late int intervalDays;
  late double easeFactor;
  late int repetitions;
  late DateTime nextReviewDate;
  
  late int startAtSecond;
}
```

**Repository Implementation:**
```dart
class CardRepositoryImpl implements CardRepository {
  final IsarDataSource localDataSource;
  
  CardRepositoryImpl(this.localDataSource);

  @override
  Future<List<Flashcard>> getDueCards() async {
    final models = await localDataSource.getDueCards();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addCard(Flashcard card) async {
    final model = FlashcardModel.fromEntity(card);
    await localDataSource.insertCard(model);
  }

  // ... other methods
}
```

---

## 3. Data Flow

### 3.1 Typical Flow Example: Review a Card

1. **User Action:** User taps "Easy" rating button
2. **Presentation Layer:** QuizProvider receives the tap event
3. **Domain Layer:** QuizProvider calls ReviewCardUseCase
4. **Service Layer:** Use case calls SRSService to calculate next review
5. **Data Layer:** Use case saves updated card via CardRepository
6. **Persistence:** Repository saves to Isar database
7. **Update UI:** Provider notifies listeners, UI updates

```
User Tap → Provider → Use Case → Service (SRS) → Repository → Isar DB
                ↑                                                    ↓
                └────────────── Update State ←──────────────────────┘
```

### 3.2 Data Flow for Adding a Card

1. User enters YouTube URL, title, artist
2. AddCardScreen validates input
3. AddCardProvider calls AddCardUseCase
4. Use case validates and creates Flashcard entity
5. Repository saves to database
6. Provider updates UI with success message

---

## 3. Naming Conventions

### 3.1 File Naming

**Dart Files:**
- Use `snake_case.dart` for all Dart files
- Test files: `*_test.dart` (e.g., `srs_service_test.dart`)
- Screen files: `*_screen.dart` (e.g., `dashboard_screen.dart`)
- Widget files: `*_widget.dart` for reusable widgets
- Provider files: `*_provider.dart` (e.g., `quiz_provider.dart`)

**Examples:**
```
lib/presentation/screens/dashboard_screen.dart
lib/presentation/widgets/flashcard_widget.dart
lib/services/srs_service.dart
lib/domain/entities/flashcard.dart
test/services/srs_service_test.dart
```

### 3.2 Class Naming

**Use PascalCase for classes, interfaces, and types:**

```dart
// Entities
class Flashcard { }
class ReviewLog { }

// Services
class SrsService { }
class YoutubeService { }

// Repositories
abstract class CardRepository { }
class IsarCardRepository implements CardRepository { }

// Providers
class DashboardProvider extends ChangeNotifier { }

// Use Cases
class ReviewCardUseCase { }
```

**Naming Patterns:**
- Services: `*Service` (e.g., `SrsService`, `ReviewService`)
- Repositories: `*Repository` (e.g., `CardRepository`)
- Providers: `*Provider` (e.g., `QuizProvider`)
- Use Cases: `*UseCase` (e.g., `AddCardUseCase`)
- Screens: `*Screen` (e.g., `DashboardScreen`)
- Widgets: `*Widget` for reusable components (e.g., `FlashcardWidget`)

### 3.3 Variable and Method Naming

**Variables: Use camelCase with domain language from GLOSSARY.md**

```dart
// Good - uses domain language
DateTime nextReviewDate;
double easeFactor;
int repetitionCount;
List<Flashcard> dueCards;

// Bad - wrong terminology
DateTime nextDate;  // Not specific enough
double difficulty;  // Use 'easeFactor' not 'difficulty'
int reviews;        // Use 'repetitionCount'
List<Card> cards;   // Use 'Flashcard' not 'Card'
```

**Methods: Use verb phrases, camelCase**

```dart
// Good - clear action verbs
Future<List<Flashcard>> fetchDueCards();
void calculateNextInterval();
bool validateYoutubeUrl(String url);
Flashcard updateEaseFactor(Flashcard card, Rating rating);

// Bad - unclear or missing verbs
Future<List<Flashcard>> due();        // Missing verb
void interval();                       // Not descriptive
bool youtube(String url);              // Missing action
Flashcard factor(Flashcard card);      // Unclear purpose
```

### 3.4 Constants

**Use UPPER_SNAKE_CASE for constants:**

```dart
// SRS algorithm constants
const double DEFAULT_EASE_FACTOR = 2.5;
const double MIN_EASE_FACTOR = 1.3;
const int INITIAL_INTERVAL_DAYS = 1;
const int SECOND_INTERVAL_DAYS = 6;

// UI constants
const double CARD_PADDING = 16.0;
const Duration ANIMATION_DURATION = Duration(milliseconds: 300);
```

### 3.5 Boolean Variables

**Use positive naming with `is`, `has`, or `can` prefixes:**

```dart
// Good - clear and positive
bool isCardDue;
bool hasYoutubeUrl;
bool canPlayVideo;
bool shouldShowAnswer;

// Avoid - negative or unclear
bool notReady;
bool disabled;
bool show;  // Too vague
```

### 3.6 Collections

**Use plural nouns for collections:**

```dart
// Good - plural indicates collection
List<Flashcard> dueCards;
List<ReviewLog> reviewLogs;
Map<String, double> easeFactors;

// Bad - singular for collections
List<Flashcard> dueCard;
List<ReviewLog> reviewLog;
```

### 3.7 Async Methods

**Use `async`/`await`, return `Future<T>` or `Stream<T>`:**

```dart
// Good - clear async patterns
Future<List<Flashcard>> fetchDueCards() async { ... }
Future<void> saveCard(Flashcard card) async { ... }
Stream<List<Flashcard>> watchDueCards() { ... }

// Avoid - unclear async handling
void fetchDueCards() { ... }  // Returns nothing
List<Flashcard> fetchDueCards() { ... }  // Blocking call?
```

### 3.8 Domain Language

**Always use exact terminology from [GLOSSARY.md](../../product/GLOSSARY.md):**

| ✅ Correct Term | ❌ Wrong Term | Context |
|----------------|--------------|----------|
| Flashcard | Card, SongCard | Entity name |
| Ease Factor | Difficulty | SRS parameter |
| Rating | Score, Grade | User feedback |
| Again (0) | Fail, Wrong | Rating value |
| Hard (1) | Difficult | Rating value |
| Good (3) | OK, Fine | Rating value |
| Easy (4) | Correct, Right | Rating value |
| Next Review Date | Due Date | Scheduling |
| Repetition Count | Reviews, Attempts | SRS tracking |

**Example:**
```dart
// Good - correct domain language
class Flashcard {
  final double easeFactor;
  final DateTime nextReviewDate;
  final int repetitionCount;
}

enum Rating { again, hard, good, easy }

// Bad - wrong terminology
class SongCard {  // Use 'Flashcard'
  final double difficulty;  // Use 'easeFactor'
  final DateTime dueDate;   // Use 'nextReviewDate'
  final int reviews;        // Use 'repetitionCount'
}

enum Score { fail, ok, correct }  // Use Rating enum
```

---

## 4. State Management

### 4.1 Provider Pattern (Recommended for MVP)

**Advantages:**
- Simple to learn and use
- Official Flutter recommendation
- Good for small to medium apps

**Example:**
```dart
class QuizProvider extends ChangeNotifier {
  final ReviewCardUseCase reviewCardUseCase;
  final GetDueCardsUseCase getDueCardsUseCase;
  
  List<Flashcard> _dueCards = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  
  QuizProvider(this.reviewCardUseCase, this.getDueCardsUseCase);

  List<Flashcard> get dueCards => _dueCards;
  Flashcard? get currentCard => _currentIndex < _dueCards.length 
      ? _dueCards[_currentIndex] 
      : null;
  bool get isLoading => _isLoading;

  Future<void> loadDueCards() async {
    _isLoading = true;
    notifyListeners();
    
    _dueCards = await getDueCardsUseCase.execute();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> rateCard(Rating rating) async {
    if (currentCard == null) return;
    
    await reviewCardUseCase.execute(currentCard!.id, rating);
    _currentIndex++;
    notifyListeners();
  }
}
```

### 4.2 Alternative: Riverpod
