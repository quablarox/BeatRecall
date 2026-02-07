# Testing Strategy - BeatRecall

## Document Information
- **Version:** 1.0
- **Last Updated:** 2026-02-07
- **Status:** Draft

---

## 1. Testing Overview

### 1.1 Testing Pyramid

```
                    ╱╲
                   ╱  ╲
                  ╱ E2E ╲          ~10% - End-to-End Tests
                 ╱──────╲
                ╱        ╲
               ╱Integration╲       ~20% - Integration Tests
              ╱────────────╲
             ╱              ╲
            ╱   Unit Tests   ╲    ~70% - Unit Tests
           ╱──────────────────╲
```

### 1.2 Testing Goals
- **Coverage Target:** Minimum 70% overall, 90% for business logic
- **Quality:** All critical paths tested
- **Speed:** Unit tests run in < 10 seconds
- **Reliability:** Tests should be deterministic and repeatable
- **Maintainability:** Tests should be easy to understand and update

---

## 2. Unit Testing

### 2.1 What to Test
- **Services:** SRS algorithm, YouTube URL parsing
- **Use Cases:** Business logic and validation
- **Utilities:** Helper functions and extensions
- **Models:** Data transformations and validations

### 2.2 Unit Test Structure

**Example: SRS Service Test**
```dart
// test/services/srs_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:beat_recall/services/srs_service.dart';

void main() {
  group('SRSService', () {
    late SRSService srsService;
    
    setUp(() {
      srsService = SRSService();
    });
    
    group('calculateNextReview', () {
      test('should increase interval on Easy rating', () {
        // Arrange
        final currentInterval = 1;
        final currentEaseFactor = 2.5;
        final currentRepetitions = 0;
        
        // Act
        final result = srsService.calculateNextReview(
          currentInterval: currentInterval,
          currentEaseFactor: currentEaseFactor,
          currentRepetitions: currentRepetitions,
          rating: Rating.easy,
        );
        
        // Assert
        expect(result.nextInterval, greaterThan(currentInterval));
        expect(result.nextEaseFactor, greaterThanOrEqualTo(currentEaseFactor));
      });
      
      test('should reset interval on Again rating', () {
        // Arrange
        final currentInterval = 7;
        
        // Act
        final result = srsService.calculateNextReview(
          currentInterval: currentInterval,
          currentEaseFactor: 2.5,
          currentRepetitions: 3,
          rating: Rating.again,
        );
        
        // Assert
        expect(result.nextInterval, equals(1));
        expect(result.nextRepetitions, equals(0));
      });
      
      test('should not reduce ease factor below 1.3', () {
        // Arrange & Act
        var easeFactor = 1.5;
        for (int i = 0; i < 10; i++) {
          final result = srsService.calculateNextReview(
            currentInterval: 1,
            currentEaseFactor: easeFactor,
            currentRepetitions: 0,
            rating: Rating.again,
          );
          easeFactor = result.nextEaseFactor;
        }
        
        // Assert
        expect(easeFactor, greaterThanOrEqualTo(1.3));
      });
    });
  });
}
```

### 2.3 Mocking Dependencies

**Example: Use Case Test with Mock Repository**
```dart
// test/domain/use_cases/review_card_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([CardRepository, SRSService])
void main() {
  group('ReviewCardUseCase', () {
    late ReviewCardUseCase useCase;
    late MockCardRepository mockRepository;
    late MockSRSService mockSRSService;
    
    setUp(() {
      mockRepository = MockCardRepository();
      mockSRSService = MockSRSService();
      useCase = ReviewCardUseCase(mockRepository, mockSRSService);
    });
    
    test('should update card with new SRS data', () async {
      // Arrange
      final card = SongCard(
        id: '1',
        youtubeId: 'abc123',
        title: 'Test Song',
        artist: 'Test Artist',
        nextReview: DateTime.now(),
      );
      
      when(mockRepository.getCardById('1'))
          .thenAnswer((_) async => card);
      
      when(mockSRSService.calculateNextReview(
        currentInterval: any(named: 'currentInterval'),
        currentEaseFactor: any(named: 'currentEaseFactor'),
        currentRepetitions: any(named: 'currentRepetitions'),
        rating: any(named: 'rating'),
      )).thenReturn(ReviewResult(
        nextInterval: 3,
        nextEaseFactor: 2.6,
        nextRepetitions: 1,
        nextReviewDate: DateTime.now().add(Duration(days: 3)),
      ));
      
      // Act
      await useCase.execute('1', Rating.good);
      
      // Assert
      verify(mockRepository.updateCard(any)).called(1);
    });
  });
}
```

---

## 3. Widget Testing

### 3.1 What to Test
- **Individual Widgets:** Custom buttons, cards, etc.
- **Widget Interactions:** Taps, scrolls, text input
- **State Changes:** UI updates based on state
- **Navigation:** Screen transitions

### 3.2 Widget Test Example

```dart
// test/presentation/widgets/rating_buttons_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beat_recall/presentation/widgets/rating_buttons.dart';

void main() {
  group('RatingButtons', () {
    testWidgets('should display all four rating buttons', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              onRating: (rating) {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Again'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
    });
    
    testWidgets('should call callback when button is tapped', (tester) async {
      // Arrange
      Rating? selectedRating;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              onRating: (rating) {
                selectedRating = rating;
              },
            ),
          ),
        ),
      );
      
      // Act
      await tester.tap(find.text('Good'));
      await tester.pump();
      
      // Assert
      expect(selectedRating, equals(Rating.good));
    });
  });
}
```

### 3.3 Testing with State Management

```dart
// test/presentation/screens/quiz/quiz_screen_test.dart
testWidgets('should load due cards on init', (tester) async {
  // Arrange
  final mockUseCase = MockGetDueCardsUseCase();
  when(mockUseCase.execute()).thenAnswer((_) async => [testCard]);
  
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => QuizProvider(mockReviewUseCase, mockUseCase),
        child: QuizScreen(),
      ),
    ),
  );
  
  // Act
  await tester.pumpAndSettle();
  
  // Assert
  expect(find.text('Test Song'), findsOneWidget);
  verify(mockUseCase.execute()).called(1);
});
```

---

## 4. Integration Testing

### 4.1 What to Test
- **Complete User Flows:** Add card → Review → Rate
- **Database Operations:** CRUD operations
- **Navigation:** Multi-screen flows
- **External Services:** YouTube integration (mocked)

### 4.2 Integration Test Example

```dart
// integration_test/add_and_review_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:beat_recall/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Add and Review Card Flow', () {
    testWidgets('complete flow from adding to reviewing a card', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to Add Card screen
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Fill in form
      await tester.enterText(
        find.byKey(Key('youtube_url_field')),
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );
      await tester.enterText(
        find.byKey(Key('title_field')),
        'Never Gonna Give You Up',
      );
      await tester.enterText(
        find.byKey(Key('artist_field')),
        'Rick Astley',
      );
      
      // Submit form
      await tester.tap(find.text('Add Card'));
      await tester.pumpAndSettle();
      
      // Verify navigation back to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      
      // Navigate to Library
      await tester.tap(find.byIcon(Icons.library_music));
      await tester.pumpAndSettle();
      
      // Verify card appears in library
      expect(find.text('Never Gonna Give You Up'), findsOneWidget);
      expect(find.text('Rick Astley'), findsOneWidget);
      
      // Start review session
      await tester.tap(find.text('Review Now'));
      await tester.pumpAndSettle();
      
      // Wait for YouTube player to load
      await tester.pump(Duration(seconds: 2));
      
      // Show answer
      await tester.tap(find.text('Show Answer'));
      await tester.pumpAndSettle();
      
      // Rate card
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();
      
      // Verify completion
      expect(find.text('Review Complete'), findsOneWidget);
    });
  });
}
```

---

## 5. Test Data Management

### 5.1 Test Fixtures

```dart
// test/fixtures/test_data.dart
class TestData {
  static SongCard createTestCard({
    String id = '1',
    String youtubeId = 'dQw4w9WgXcQ',
    String title = 'Test Song',
    String artist = 'Test Artist',
    int interval = 0,
    double easeFactor = 2.5,
    int repetitions = 0,
    DateTime? nextReview,
    int startAtSecond = 0,
  }) {
    return SongCard(
      id: id,
      youtubeId: youtubeId,
      title: title,
      artist: artist,
      interval: interval,
      easeFactor: easeFactor,
      repetitions: repetitions,
      nextReview: nextReview ?? DateTime.now(),
      startAtSecond: startAtSecond,
    );
  }
  
  static List<SongCard> createTestCards(int count) {
    return List.generate(
      count,
      (i) => createTestCard(
        id: i.toString(),
        title: 'Test Song $i',
      ),
    );
  }
}
```

---

## 6. Test Automation

### 6.1 Continuous Integration

**GitHub Actions Example:**
```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Run unit tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v2
        with:
          files: ./coverage/lcov.info
```

### 6.2 Pre-commit Hooks

```bash
# .git/hooks/pre-commit
#!/bin/bash

echo "Running tests before commit..."
flutter test

if [ $? -ne 0 ]; then
  echo "Tests failed! Commit aborted."
  exit 1
fi

echo "All tests passed!"
```

---

## 7. Performance Testing

### 7.1 Load Testing

```dart
test('should handle 1000 cards efficiently', () async {
  // Arrange
  final cards = TestData.createTestCards(1000);
  await repository.addCards(cards);
  
  // Act
  final stopwatch = Stopwatch()..start();
  final dueCards = await repository.getDueCards();
  stopwatch.stop();
  
  // Assert
  expect(stopwatch.elapsedMilliseconds, lessThan(200));
  expect(dueCards.length, greaterThan(0));
});
```

### 7.2 Memory Testing

```dart
testWidgets('should not leak memory in quiz session', (tester) async {
  // Use memory profiler to check for leaks
  // Monitor memory usage over multiple card reviews
  
  for (int i = 0; i < 100; i++) {
    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();
  }
  
  // Verify memory hasn't grown excessively
});
```

---

## 8. Manual Testing Checklist

### 8.1 Smoke Tests
- [ ] App launches successfully
- [ ] Can add a new card
- [ ] Can review a card
- [ ] Can navigate between screens
- [ ] Database persists data

### 8.2 Exploratory Testing
- [ ] Test with slow network
- [ ] Test with no network
- [ ] Test with invalid YouTube URLs
- [ ] Test with special characters in titles
- [ ] Test with very long titles/artists
- [ ] Test app in background/foreground
- [ ] Test memory usage with many cards

### 8.3 Platform-Specific Testing
- [ ] Android: Back button behavior
- [ ] iOS: Swipe gestures
- [ ] Different screen sizes
- [ ] Dark mode/light mode
- [ ] System font size changes

---

## 9. Test Reporting

### 9.1 Coverage Reports
```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 9.2 Test Results
- Use CI/CD dashboard for automated test results
- Track test execution time trends
- Monitor flaky tests
- Track coverage trends over time

---

## 10. Testing Best Practices

### 10.1 General Guidelines
- **AAA Pattern:** Arrange, Act, Assert
- **One assertion per test:** Focus on single behavior
- **Descriptive names:** Test names should explain what's being tested
- **Independent tests:** Tests should not depend on each other
- **Fast tests:** Unit tests should run in milliseconds

### 10.2 What NOT to Test
- Third-party packages (trust they're tested)
- Flutter framework itself
- Generated code (unless custom logic added)
- Trivial getters/setters

### 10.3 Test Maintenance
- Update tests when requirements change
- Remove obsolete tests
- Refactor duplicate test code
- Keep tests simple and readable

---

## 11. Test Coverage Goals

| Component | Target Coverage |
|-----------|----------------|
| Services | 90%+ |
| Use Cases | 90%+ |
| Repositories | 80%+ |
| Widgets | 70%+ |
| Overall | 70%+ |

---

## 12. Testing Tools

### 12.1 Required Packages
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.3.0
  build_runner: ^2.3.0
  integration_test:
    sdk: flutter
```

### 12.2 Useful Tools
- **Flutter DevTools:** Performance and memory profiling
- **Coverage:** `lcov`, `genhtml`
- **Mocking:** `mockito`, `mocktail`
- **Golden Tests:** Screenshot testing for widgets
