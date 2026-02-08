# Data Layer Architecture

## Overview

BeatRecall uses a clean separation between domain and data layers, ensuring the domain model remains independent of database implementation details.

## Architecture

```
Domain Layer (Pure Dart)
    ↓
Repository Interface
    ↓
Data Layer (Isar Implementation)
```

## Components

### 1. Domain Entity: `Flashcard`

**Location:** `lib/domain/entities/flashcard.dart`

- Pure Dart class without database dependencies
- Uses **UUID** as stable identifier across application
- Immutable with `copyWith()` for modifications
- Contains all business logic fields (SRS, playback, metadata)

**Key Principle:** UUID is generated **before** persistence

```dart
final card = FlashcardFactory.create(
  youtubeId: 'abc123',
  title: 'Song Title',
  artist: 'Artist Name',
); // UUID already assigned
```

### 2. Data Entity: `IsarFlashcard`

**Location:** `lib/data/entities/isar_flashcard.dart`

- Isar collection with `@collection` annotation
- Has **two IDs:**
  - `id`: Auto-increment Isar database ID (internal)
  - `uuid`: String UUID (indexed, unique) - matches domain `Flashcard.uuid`
- Used only within data layer

**Indexes:**
- `uuid`: Unique index for primary lookup
- `youtubeId`: Index for duplicate detection
- `nextReviewDate`: Index for due card queries

### 3. Mapper: `FlashcardMapper`

**Location:** `lib/data/mappers/flashcard_mapper.dart`

- Bidirectional conversion between domain and data entities
- `toDomain()`: IsarFlashcard → Flashcard (discards Isar ID)
- `toData()`: Flashcard → IsarFlashcard (preserves Isar ID if updating)
- List operations: `toDomainList()`, `toDataList()`

### 4. Repository Interface: `CardRepository`

**Location:** `lib/domain/repositories/card_repository.dart`

- Abstract interface defining persistence operations
- Uses **UUID** for identification (not int ID)
- Key methods:
  - `findByUuid(String uuid)` - Lookup by UUID
  - `deleteByUuid(String uuid)` - Delete by UUID
  - `save(Flashcard card)` - Insert or update
  - `existsByYoutubeId(String youtubeId)` - Duplicate detection

### 5. Repository Implementation: `IsarCardRepository`

**Location:** `lib/data/repositories/isar_card_repository.dart`

- Implements `CardRepository` using Isar database
- Handles mapping via `FlashcardMapper`
- Internally uses both `uuid` (for domain lookup) and `id` (for Isar operations)
- Automatically preserves Isar ID on updates

**Update Strategy:**
```dart
// On save:
1. Check if UUID exists in database
2. If exists: Reuse Isar ID (update)
3. If not: Let Isar assign new ID (insert)
4. Mapper preserves Isar ID for put()
```

### 6. Factory: `FlashcardFactory`

**Location:** `lib/domain/factories/flashcard_factory.dart`

- Convenience methods for creating domain `Flashcard` instances
- Automatically generates UUIDs
- Provides defaults for SRS fields
- Helper methods: `createDueCard()`, `createFutureCard()`

## Usage Examples

### Creating a New Card

```dart
// Create with auto-generated UUID
final card = FlashcardFactory.create(
  youtubeId: 'dQw4w9WgXcQ',
  title: 'Never Gonna Give You Up',
  artist: 'Rick Astley',
);

// Save (repository will insert)
await repository.save(card);
```

### Updating an Existing Card

```dart
// Fetch by UUID
final card = await repository.findByUuid('some-uuid');

// Modify
final updated = card.copyWith(title: 'New Title');

// Save (repository will update based on UUID)
await repository.save(updated);
```

### Checking for Duplicates

```dart
final exists = await repository.existsByYoutubeId('dQw4w9WgXcQ');
if (exists) {
  // Handle duplicate
}
```

### Fetching Due Cards

```dart
final dueCards = await repository.fetchDueCards(limit: 50);
for (final card in dueCards) {
  // Present for review
}
```

## Testing Strategy

### Unit Tests (No Database)

- **Mapper Tests:** `test/data/mappers/flashcard_mapper_test.dart`
  - Verifies correct domain ↔ data conversion
  - Round-trip conversion tests
  
- **Factory Tests:** `test/domain/factories/flashcard_factory_test.dart`
  - UUID generation
  - Default value application

### Integration Tests (With Database)

For testing repository operations with real Isar:

1. **Option A:** Flutter integration tests (requires device/emulator)
2. **Option B:** Integration test directory with `flutter test integration_test/`
3. **Option C:** Manual testing via app UI

**Note:** Standard `flutter test` for Isar requires native libraries setup. Unit tests of mapper/factory are sufficient for core logic validation.

## Migration from Old System

### Before (Coupled)

```dart
@collection
class Flashcard {
  Id id = Isar.autoIncrement; // Isar-specific
  late String title;
  // ...
}

// Domain directly used Isar entity
```

### After (Decoupled)

```dart
// Domain
class Flashcard {
  final String uuid;  // Stable ID
  final String title;
  // ... pure Dart
}

// Data
@collection
class IsarFlashcard {
  Id id = Isar.autoIncrement;  // DB internal
  late String uuid;             // Maps to domain
  late String title;
}
```

## Benefits

1. **Domain Independence:** Domain layer has no Isar dependency
2. **Testability:** Domain logic testable without database
3. **Flexibility:** Can swap Isar for another DB without changing domain
4. **Stability:** UUID-based references remain valid across implementations
5. **Performance:** Isar ID optimizations still available internally

## File Structure

```
lib/
  domain/
    entities/
      flashcard.dart          # Domain entity (pure Dart)
    factories/
      flashcard_factory.dart  # Creation helpers
    repositories/
      card_repository.dart    # Interface (UUID-based)
  data/
    entities/
      isar_flashcard.dart     # Data entity (Isar)
    mappers/
      flashcard_mapper.dart   # Domain ↔ Data
    repositories/
      isar_card_repository.dart  # Implementation
    database/
      isar_database.dart      # Isar singleton
```

## Related Documentation

- [API Contracts](../../docs/engineering/architecture/api_contracts.md)
- [Architecture Overview](../../docs/engineering/architecture/architecture.md)
- [Glossary](../../docs/product/GLOSSARY.md) - Domain terminology
