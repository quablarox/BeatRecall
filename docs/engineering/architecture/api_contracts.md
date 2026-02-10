# API Contracts & Project Structure

## Table of Contents
- [Overview](#overview)
- [Project Structure](#project-structure)
- [Repository Interfaces](#repository-interfaces)
  - [CardRepository](#cardrepository)
  - [ReviewLogRepository](#reviewlogrepository)
- [Service Interfaces](#service-interfaces)
  - [SrsService](#srsservice)
  - [ReviewService](#reviewservice)
  - [CardService](#cardservice)
  - [ImportService](#importservice)
  - [StatisticsService](#statisticsservice)
  - [YoutubeService](#youtubeservice)
- [Provider Patterns](#provider-patterns)
- [Data Models](#data-models)
- [Dependency Injection Setup](#dependency-injection-setup)
- [Error Handling](#error-handling)
- [Testing Contracts](#testing-contracts)

---

## Overview

This document defines the **API contracts** between layers and the **complete project structure** for BeatRecall. All layers communicate through well-defined interfaces to ensure loose coupling and testability.

---

## Project Structure

```
lib/
├── main.dart                           # App entry point, DI setup
│
├── presentation/                       # Presentation Layer (UI)
│   ├── screens/
│   │   ├── dashboard_screen.dart       # Home screen with statistics
│   │   ├── review_session_screen.dart  # Active review session
│   │   ├── card_list_screen.dart       # Browse all cards
│   │   ├── card_detail_screen.dart     # View/edit single card
│   │   └── import_screen.dart          # CSV import UI
│   │
│   ├── widgets/
│   │   ├── flashcard_player_widget.dart    # YouTube player component
│   │   ├── rating_buttons_widget.dart      # Again/Hard/Good/Easy buttons
│   │   ├── dashboard_stat_card.dart        # Individual stat display
│   │   ├── card_list_item.dart             # Card list tile
│   │   └── session_progress_bar.dart       # Review progress indicator
│   │
│   └── providers/
│       ├── dashboard_provider.dart         # Dashboard state
│       ├── review_session_provider.dart    # Review session state
│       ├── card_list_provider.dart         # Card browsing state
│       └── import_provider.dart            # CSV import state
│
├── services/                           # Service Layer (Business Logic)
│   ├── srs_service.dart                # SM-2 algorithm calculations
│   ├── review_service.dart             # Review session orchestration
│   ├── card_service.dart               # Card CRUD operations
│   ├── import_service.dart             # CSV import logic
│   ├── statistics_service.dart         # Dashboard statistics
│   └── youtube_service.dart            # YouTube ID extraction
│
├── domain/                             # Domain Layer (Entities & Interfaces)
│   ├── entities/
│   │   ├── flashcard.dart              # Flashcard entity (Isar collection)
│   │   ├── review_log.dart             # ReviewLog entity (Isar collection)
│   │   ├── session_state.dart          # Session state model
│   │   ├── import_result.dart          # CSV import result model
│   │   └── dashboard_stats.dart        # Dashboard statistics model
│   │
│   ├── enums/
│   │   ├── card_status.dart            # New, Learning, Review
│   │   └── rating.dart                 # Again, Hard, Good, Easy
│   │
│   └── repositories/
│       ├── card_repository.dart        # Abstract card repository
│       └── review_log_repository.dart  # Abstract review log repository
│
└── data/                               # Data Layer (Database & Implementation)
    ├── database/
    │   └── isar_database.dart          # Isar instance singleton
    │
    └── repositories/
        ├── card_repository_impl.dart       # Isar card repository
        └── review_log_repository_impl.dart # Isar review log repository

test/
├── unit/
│   ├── services/
│   │   ├── srs_service_test.dart
│   │   ├── review_service_test.dart
│   │   └── card_service_test.dart
│   └── domain/
│       └── entities/
│           └── flashcard_test.dart
│
├── integration/
│   ├── repositories/
│   │   ├── card_repository_test.dart
│   │   └── review_log_repository_test.dart
│   └── services/
│       └── review_service_integration_test.dart
│
└── e2e/
    ├── review_session_flow_test.dart
    └── import_flow_test.dart
```

---

## Layer Communication Flow

```
User Action (UI)
    ↓
Provider (ChangeNotifier)
    ↓
Service (Business Logic)
    ↓
Repository Interface (Domain)
    ↓
Repository Implementation (Data)
    ↓
Isar Database
```

**Key Principle:** Upper layers depend on abstractions (interfaces), not implementations.

---

## Domain Layer Contracts

### 1. Repository Interfaces

#### CardRepository

```dart
abstract class CardRepository {
  /// Fetch all cards that are due for review (nextReviewDate <= now)
  Future<List<Flashcard>> fetchDueCards({int limit = 100});
  
  /// Fetch a single card by ID
  Future<Flashcard?> findById(int id);
  
  /// Fetch all cards in the library
  Future<List<Flashcard>> fetchAllCards({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
  });
  
  /// Count total cards in library
  Future<int> countAllCards();
  
  /// Count cards due for review
  Future<int> countDueCards();
  
  /// Save a card (insert or update)
  Future<void> save(Flashcard card);
  
  /// Save multiple cards in a transaction
  Future<void> saveAll(List<Flashcard> cards);
  
  /// Delete a card by ID
  Future<void> delete(int id);
  
  /// Check if a YouTube ID already exists
  Future<bool> existsByYoutubeId(String youtubeId);
  
  /// Update only SRS fields after review
  Future<void> updateSrsFields({
    required int cardId,
    required DateTime nextReviewDate,
    required double easeFactor,
    required int interval,
    required int repetitions,
  });
}
```

#### ReviewLogRepository

```dart
abstract class ReviewLogRepository {
  /// Save a review log entry
  Future<void> save(ReviewLog log);
  
  /// Fetch review logs for a specific card
  Future<List<ReviewLog>> fetchByCardId(int cardId, {int limit = 50});
  
  /// Fetch all review logs within a date range
  Future<List<ReviewLog>> fetchByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// Count reviews in the last N days
  Future<int> countReviewsInLastDays(int days);
  
  /// Calculate success rate (Good+Easy %) in last N days
  Future<double> calculateSuccessRate(int days);
  
  /// Check if user reviewed on a specific date
  Future<bool> hasReviewOnDate(DateTime date);
}
```

---

## Service Layer Contracts

### 1. SrsService

**Purpose:** SM-2 algorithm calculations (pure business logic, no database access)

```dart
class SrsService {
  /// Calculate next review parameters using SM-2 algorithm
  /// Returns: (nextInterval, newEaseFactor, newRepetitions)
  (int, double, int) calculateNextReview({
    required int currentInterval,
    required double currentEaseFactor,
    required int currentRepetitions,
    required Rating rating,
  });
  
  /// Calculate next review date from interval in minutes
  DateTime calculateNextReviewDate(int intervalMinutes);
  
  /// Determine card status based on repetitions
  CardStatus determineCardStatus(int repetitions);
}
```

**Dependencies:** None (pure functions)

---

### 2. ReviewService

**Purpose:** Orchestrate review sessions (fetch cards, process ratings, save logs)

```dart
class ReviewService {
  final CardRepository _cardRepository;
  final ReviewLogRepository _reviewLogRepository;
  final SrsService _srsService;
  
  /// Fetch all cards due for review
  Future<List<Flashcard>> getDueCards({int limit = 100});
  
  /// Process a user's rating for a card
  /// - Calculate new SRS parameters
  /// - Update card in database
  /// - Save review log
  Future<void> processReview({
    required Flashcard card,
    required Rating rating,
  });
  
  /// Get count of due cards
  Future<int> getDueCardsCount();
}
```

**Dependencies:** CardRepository, ReviewLogRepository, SrsService

---

### 3. CardService

**Purpose:** Card CRUD operations and validation

```dart
class CardService {
  final CardRepository _cardRepository;
  final YoutubeService _youtubeService;
  
  /// Create a new card with validation
  Future<Flashcard> createCard({
    required String youtubeUrl,
    required String title,
    required String artist,
    int startAtSeconds = 0,
  });
  
  /// Update an existing card
  Future<void> updateCard(Flashcard card);
  
  /// Delete a card by ID
  Future<void> deleteCard(int id);
  
  /// Fetch all cards with optional search/filter
  Future<List<Flashcard>> getAllCards({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
  });
  
  /// Check if YouTube URL already exists (duplicate detection)
  Future<bool> isDuplicateUrl(String youtubeUrl);
  
  /// Validate card data before saving
  void validateCard({
    required String youtubeUrl,
    required String title,
    required String artist,
  });
}
```

**Dependencies:** CardRepository, YoutubeService

---

### 4. ImportService

**Purpose:** CSV file parsing and batch card creation

```dart
class ImportService {
  final CardService _cardService;
  
  /// Import cards from CSV file
  /// Returns: ImportResult with success count and error details
  Future<ImportResult> importFromCsv(String filePath);
  
  /// Validate CSV format (headers, required columns)
  Future<void> validateCsvFormat(String filePath);
  
  /// Parse a single CSV row into a Flashcard
  /// Throws ValidationException if invalid
  Flashcard parseCsvRow(List<String> row, List<String> headers);
}
```

**Dependencies:** CardService

---

### 5. StatisticsService

**Purpose:** Calculate dashboard metrics with caching

```dart
class StatisticsService {
  final CardRepository _cardRepository;
  final ReviewLogRepository _reviewLogRepository;
  
  // Cache
  DashboardStats? _cachedStats;
  DateTime? _lastFetchTime;
  static const cacheDuration = Duration(seconds: 60);
  
  /// Get all dashboard statistics (with caching)
  Future<DashboardStats> getDashboardStats();
  
  /// Force refresh statistics (bypass cache)
  Future<DashboardStats> refreshStats();
  
  /// Invalidate cache (call after reviews)
  void invalidateCache();
  
  /// Calculate review streak (consecutive days with reviews)
  Future<int> calculateReviewStreak();
  
  /// Calculate success rate in last N days
  Future<double> calculateSuccessRate({int days = 7});
}
```

**Dependencies:** CardRepository, ReviewLogRepository

---

### 6. YoutubeService

**Purpose:** YouTube URL/ID extraction and validation

```dart
class YoutubeService {
  /// Extract YouTube ID from various URL formats
  /// Supports: youtube.com/watch?v=ID, youtu.be/ID, direct ID
  String? extractYoutubeId(String input);
  
  /// Validate YouTube ID format (11 characters, valid chars)
  bool isValidYoutubeId(String id);
  
  /// Build full YouTube URL from ID
  String buildYoutubeUrl(String youtubeId);
}
```

**Dependencies:** None

---

## Presentation Layer Contracts

### Provider Structure

All providers extend `ChangeNotifier` and follow this pattern:

```dart
class ExampleProvider extends ChangeNotifier {
  final ExampleService _service;
  
  // Private state
  StateType _state = initialState;
  
  // Public getters
  StateType get state => _state;
  
  // Constructor with DI
  ExampleProvider(this._service);
  
  // Public methods (async operations)
  Future<void> performAction() async {
    try {
      // Call service
      final result = await _service.doSomething();
      
      // Update state
      _state = result;
      notifyListeners();
    } catch (e) {
      // Handle error
      _handleError(e);
    }
  }
  
  void _handleError(dynamic error) {
    // Show user-friendly error, log technical details
  }
}
```

### Key Providers

#### DashboardProvider

```dart
class DashboardProvider extends ChangeNotifier {
  final StatisticsService _statisticsService;
  
  DashboardStats? _stats;
  bool _isLoading = false;
  String? _error;
  
  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadStats();
  Future<void> refreshStats();
}
```

#### ReviewSessionProvider

```dart
class ReviewSessionProvider extends ChangeNotifier {
  final ReviewService _reviewService;
  
  List<Flashcard> _remainingCards = [];
  int _currentIndex = 0;
  SessionState _state = SessionState.idle;
  
  Flashcard? get currentCard;
  int get totalCards;
  int get cardsReviewed;
  SessionState get state;
  
  Future<void> startSession();
  Future<void> rateCurrentCard(Rating rating);
  void endSession();
}
```

#### CardListProvider

```dart
class CardListProvider extends ChangeNotifier {
  final CardService _cardService;
  
  List<Flashcard> _cards = [];
  bool _isLoading = false;
  String? _searchQuery;
  
  List<Flashcard> get cards => _cards;
  bool get isLoading => _isLoading;
  
  Future<void> loadCards({int offset = 0});
  Future<void> searchCards(String query);
  Future<void> deleteCard(int id);
}
```

#### ImportProvider

```dart
class ImportProvider extends ChangeNotifier {
  final ImportService _importService;
  
  ImportResult? _result;
  bool _isImporting = false;
  double _progress = 0.0;
  
  ImportResult? get result => _result;
  bool get isImporting => _isImporting;
  double get progress => _progress;
  
  Future<void> importCsv(String filePath);
}
```

---

## Data Models

### Domain Entities

#### DashboardStats

```dart
class DashboardStats {
  final int dueCardsCount;
  final int totalCardsCount;
  final double successRate;      // Percentage 0-100
  final int reviewStreak;        // Consecutive days
  
  const DashboardStats({
    required this.dueCardsCount,
    required this.totalCardsCount,
    required this.successRate,
    required this.reviewStreak,
  });
}
```

#### SessionState

```dart
enum SessionState {
  idle,           // No active session
  inProgress,     // Currently reviewing
  completed,      // All cards reviewed
}
```

#### ImportResult

```dart
class ImportResult {
  final int successCount;
  final int errorCount;
  final List<ImportError> errors;
  
  ImportResult({
    required this.successCount,
    required this.errorCount,
    required this.errors,
  });
}

class ImportError {
  final int rowNumber;
  final String message;
  
  const ImportError({
    required this.rowNumber,
    required this.message,
  });
}
```

---

## Dependency Injection Setup

### main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar database
  final isar = await IsarDatabase.initialize();
  
  // Instantiate repositories
  final cardRepository = CardRepositoryImpl(isar);
  final reviewLogRepository = ReviewLogRepositoryImpl(isar);
  
  // Instantiate services
  final srsService = SrsService();
  final youtubeService = YoutubeService();
  final reviewService = ReviewService(cardRepository, reviewLogRepository, srsService);
  final cardService = CardService(cardRepository, youtubeService);
  final importService = ImportService(cardService);
  final statisticsService = StatisticsService(cardRepository, reviewLogRepository);
  
  runApp(
    MultiProvider(
      providers: [
        // Providers
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(statisticsService),
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewSessionProvider(reviewService),
        ),
        ChangeNotifierProvider(
          create: (_) => CardListProvider(cardService),
        ),
        ChangeNotifierProvider(
          create: (_) => ImportProvider(importService),
        ),
        
        // Services (for direct access if needed)
        Provider.value(value: cardService),
        Provider.value(value: reviewService),
      ],
      child: const BeatRecallApp(),
    ),
  );
}
```

---

## Error Handling Patterns

### Custom Exceptions

```dart
// Domain exceptions
class CardNotFoundException implements Exception {
  final int cardId;
  CardNotFoundException(this.cardId);
  @override
  String toString() => 'Card with ID $cardId not found';
}

class DuplicateCardException implements Exception {
  final String youtubeId;
  DuplicateCardException(this.youtubeId);
  @override
  String toString() => 'Card with YouTube ID $youtubeId already exists';
}

class InvalidYoutubeUrlException implements Exception {
  final String url;
  InvalidYoutubeUrlException(this.url);
  @override
  String toString() => 'Invalid YouTube URL: $url';
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  @override
  String toString() => 'Validation error: $message';
}

// Import exceptions
class InvalidCsvFormatException implements Exception {
  final String message;
  InvalidCsvFormatException(this.message);
  @override
  String toString() => 'Invalid CSV format: $message';
}
```

### Error Handling in Services

```dart
// Services throw exceptions with technical details
Future<Flashcard> createCard(...) async {
  // Validate
  if (title.isEmpty) {
    throw ValidationException('Title cannot be empty');
  }
  
  // Check duplicates
  if (await isDuplicateUrl(youtubeUrl)) {
    throw DuplicateCardException(youtubeId);
  }
  
  // Save
  await _cardRepository.save(card);
  return card;
}
```

### Error Handling in Providers

```dart
// Providers catch exceptions and show user-friendly messages
Future<void> createCard(...) async {
  try {
    _isLoading = true;
    notifyListeners();
    
    await _cardService.createCard(...);
    
    _isLoading = false;
    notifyListeners();
    
    // Show success message
    _showSuccess('Card created successfully');
    
  } on DuplicateCardException catch (e) {
    _error = 'This song is already in your library';
    _isLoading = false;
    notifyListeners();
    
  } on ValidationException catch (e) {
    _error = e.message;
    _isLoading = false;
    notifyListeners();
    
  } catch (e) {
    _error = 'Failed to create card. Please try again.';
    _isLoading = false;
    notifyListeners();
    
    // Log technical error
    debugPrint('Error creating card: $e');
  }
}
```

---

## Testing Contracts

### Unit Tests (Services)

```dart
void main() {
  group('SrsService', () {
    late SrsService service;
    
    setUp(() {
      service = SrsService();
    });
    
    test('@SRS-001: Again rating resets card to learning', () {
      // Given
      final (interval, easeFactor, repetitions) = (10, 2.5, 5);
      
      // When
      final result = service.calculateNextReview(
        currentInterval: interval,
        currentEaseFactor: easeFactor,
        currentRepetitions: repetitions,
        rating: Rating.again,
      );
      
      // Then
      expect(result.$1, equals(0));        // interval = 0
      expect(result.$3, equals(0));        // repetitions = 0
    });
  });
}
```

### Integration Tests (Repositories + Database)

```dart
void main() {
  group('CardRepository Integration', () {
    late Isar isar;
    late CardRepository repository;
    
    setUp(() async {
      final dir = await getTemporaryDirectory();
      isar = await Isar.open([FlashcardSchema], directory: dir.path);
      repository = CardRepositoryImpl(isar);
    });
    
    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });
    
    test('fetchDueCards returns only cards with past nextReviewDate', () async {
      // Given: 2 cards, 1 due, 1 future
      await repository.saveAll([
        Flashcard()..nextReviewDate = DateTime.now().subtract(Duration(days: 1)),
        Flashcard()..nextReviewDate = DateTime.now().add(Duration(days: 1)),
      ]);
      
      // When
      final dueCards = await repository.fetchDueCards();
      
      // Then
      expect(dueCards.length, equals(1));
      expect(dueCards.first.isDue, isTrue);
    });
  });
}
```

### E2E Tests (Full User Flows)

```dart
void main() {
  testWidgets('Complete review session flow', (tester) async {
    await tester.pumpWidget(const BeatRecallApp());
    
    // Given: User is on dashboard with 3 due cards
    expect(find.text('3'), findsOneWidget);  // Due cards count
    
    // When: User taps "Start Review"
    await tester.tap(find.text('Start Review'));
    await tester.pumpAndSettle();
    
    // Then: Review session screen shows first card
    expect(find.byType(FlashcardPlayerWidget), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);  // Progress
    
    // When: User rates card as "Good"
    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();
    
    // Then: Next card is shown
    expect(find.text('2 / 3'), findsOneWidget);
  });
}
```

---

## Key Principles

1. **Dependency Inversion:** Services depend on repository interfaces, not implementations
2. **Single Responsibility:** Each service/repository has one clear purpose
3. **Separation of Concerns:** UI logic in providers, business logic in services, data access in repositories
4. **Testability:** Pure functions where possible, mockable dependencies
5. **Immutability:** Use const constructors, final fields, return new instances
6. **Error Transparency:** Services throw specific exceptions, providers catch and show user-friendly messages
7. **Stateless Services:** Services don't hold state (except caching), providers manage UI state
8. **Interface Segregation:** Repository interfaces expose only needed methods

---

## Related Documentation

- **Architecture Overview:** `docs/engineering/architecture/architecture.md`
- **Testing Strategy:** `docs/engineering/testing/testing_strategy.md`
- **GitHub Copilot Instructions:** `.github/copilot-instructions.md`
- **SRS Requirements:** `docs/product/requirements/core/SRS.md`
- **Glossary:** `docs/product/GLOSSARY.md`
