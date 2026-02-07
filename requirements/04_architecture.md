# Architecture Documentation - BeatRecall

## Document Information
- **Version:** 1.0
- **Last Updated:** 2026-02-07
- **Status:** Draft

---

## 1. Architecture Overview

BeatRecall follows a **Layered Architecture** pattern with clear separation of concerns. This architecture promotes:
- **Maintainability:** Clear boundaries between layers
- **Testability:** Each layer can be tested independently
- **Scalability:** Easy to add new features
- **Flexibility:** Can swap implementations without affecting other layers

### 1.1 Architecture Diagram

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
- **Entities:** Core business objects (SongCard entity)
- **Use Cases:** Specific business operations
- **Repository Interfaces:** Abstract data access

**Example Structure:**
```
lib/domain/
├── entities/
│   └── song_card.dart
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
class SongCard {
  final String id;
  final String youtubeId;
  final String title;
  final String artist;
  
  // SRS data
  final int interval;
  final double easeFactor;
  final int repetitions;
  final DateTime nextReview;
  
  // Configuration
  final int startAtSecond;
  
  const SongCard({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.artist,
    this.interval = 0,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    required this.nextReview,
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

  Future<SongCard> execute(String cardId, Rating rating) async {
    final card = await repository.getCardById(cardId);
    
    final result = srsService.calculateNextReview(
      currentInterval: card.interval,
      currentEaseFactor: card.easeFactor,
      currentRepetitions: card.repetitions,
      rating: rating,
    );
    
    final updatedCard = card.copyWith(
      interval: result.nextInterval,
      easeFactor: result.nextEaseFactor,
      repetitions: result.nextRepetitions,
      nextReview: result.nextReviewDate,
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
│   └── song_card_model.dart
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
class SongCardModel {
  Id id = Isar.autoIncrement;
  
  late String youtubeId;
  late String title;
  late String artist;
  
  late int interval;
  late double easeFactor;
  late int repetitions;
  late DateTime nextReview;
  
  late int startAtSecond;
}
```

**Repository Implementation:**
```dart
class CardRepositoryImpl implements CardRepository {
  final IsarDataSource localDataSource;
  
  CardRepositoryImpl(this.localDataSource);

  @override
  Future<List<SongCard>> getDueCards() async {
    final models = await localDataSource.getDueCards();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addCard(SongCard card) async {
    final model = SongCardModel.fromEntity(card);
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
4. Use case validates and creates SongCard entity
5. Repository saves to database
6. Provider updates UI with success message

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
  
  List<SongCard> _dueCards = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  
  QuizProvider(this.reviewCardUseCase, this.getDueCardsUseCase);

  List<SongCard> get dueCards => _dueCards;
  SongCard? get currentCard => _currentIndex < _dueCards.length 
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

**Advantages:**
- Compile-time safety
- Better testability
- More scalable for large apps

**Example:**
```dart
final dueCardsProvider = FutureProvider<List<SongCard>>((ref) async {
  final useCase = ref.read(getDueCardsUseCaseProvider);
  return await useCase.execute();
});

final quizStateProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(ref.read);
});
```

---

## 5. Dependency Injection

### 5.1 Manual DI (Simple Approach)

```dart
// lib/core/di/injection.dart
class Injection {
  static late Isar isar;
  
  static Future<void> init() async {
    // Initialize database
    isar = await Isar.open([SongCardModelSchema]);
    
    // Initialize services
    final srsService = SRSService();
    final youtubeService = YouTubeService();
    
    // Initialize data sources
    final localDataSource = IsarDataSource(isar);
    
    // Initialize repositories
    final cardRepository = CardRepositoryImpl(localDataSource);
    
    // Initialize use cases
    final reviewCardUseCase = ReviewCardUseCase(cardRepository, srsService);
    
    // Register in service locator (optional)
    // ...
  }
}
```

### 5.2 Using get_it (Recommended)

```dart
final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  getIt.registerLazySingleton<SRSService>(() => SRSService());
  getIt.registerLazySingleton<YouTubeService>(() => YouTubeService());
  
  // Data sources
  getIt.registerLazySingleton<IsarDataSource>(() => IsarDataSource(isar));
  
  // Repositories
  getIt.registerLazySingleton<CardRepository>(
    () => CardRepositoryImpl(getIt<IsarDataSource>())
  );
  
  // Use cases
  getIt.registerFactory<ReviewCardUseCase>(
    () => ReviewCardUseCase(getIt<CardRepository>(), getIt<SRSService>())
  );
}
```

---

## 6. Error Handling

### 6.1 Error Types

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
```

### 6.2 Result Pattern (Optional)

```dart
class Result<T> {
  final T? data;
  final Failure? failure;
  
  const Result.success(this.data) : failure = null;
  const Result.failure(this.failure) : data = null;
  
  bool get isSuccess => data != null;
  bool get isFailure => failure != null;
}
```

---

## 7. Testing Strategy

### 7.1 Unit Tests
- Test services independently (SRS algorithm)
- Test use cases with mocked dependencies
- Test utilities and helpers

### 7.2 Widget Tests
- Test individual widgets
- Test widget interactions
- Test state changes

### 7.3 Integration Tests
- Test complete user flows
- Test database operations
- Test YouTube integration

**Test Structure:**
```
test/
├── services/
│   ├── srs_service_test.dart
│   └── youtube_service_test.dart
├── domain/
│   └── use_cases/
│       └── review_card_use_case_test.dart
├── data/
│   └── repositories/
│       └── card_repository_impl_test.dart
└── presentation/
    └── providers/
        └── quiz_provider_test.dart
```

---

## 8. Performance Considerations

### 8.1 Database Optimization
- Use indexes on `nextReview` field for due cards query
- Batch operations when possible
- Use lazy loading for large lists

### 8.2 UI Performance
- Use `const` constructors where possible
- Implement pagination for large lists
- Dispose controllers and streams properly
- Use `RepaintBoundary` for complex widgets

### 8.3 Memory Management
- Properly dispose YouTube player
- Clean up listeners in providers
- Use weak references for caches

---

## 9. Security Considerations

### 9.1 Data Protection
- No sensitive user data is stored
- YouTube API key should be secured (if used)
- Validate all user inputs

### 9.2 API Security
- Use HTTPS for all network requests
- Implement rate limiting for YouTube API
- Handle API errors gracefully

---

## 10. Future Architecture Improvements

### 10.1 Offline Sync
- Implement sync mechanism when internet available
- Queue operations when offline
- Handle conflict resolution

### 10.2 Cloud Backup
- Add repository for cloud storage (Firebase, etc.)
- Implement data synchronization
- Handle authentication

### 10.3 Multi-platform Support
- Web support with different storage layer
- Desktop support
- Responsive design considerations

---

## 11. Architecture Decision Records (ADR)

### ADR-001: Use Isar instead of SQLite
**Status:** Accepted  
**Reason:** Better performance, no SQL knowledge required, type-safe queries

### ADR-002: Use Provider for MVP, consider Riverpod later
**Status:** Accepted  
**Reason:** Simpler learning curve for MVP, can migrate to Riverpod in Phase 2

### ADR-003: Layered Architecture
**Status:** Accepted  
**Reason:** Clear separation of concerns, better testability, easier maintenance

---

## 12. References

- **Clean Architecture:** Robert C. Martin
- **Flutter Architecture Samples:** https://github.com/brianegan/flutter_architecture_samples
- **Isar Documentation:** https://isar.dev/
- **Provider Documentation:** https://pub.dev/packages/provider
