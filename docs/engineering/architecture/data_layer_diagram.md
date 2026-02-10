# Data Layer Architecture Diagram

## Component Overview

# Data Layer Architecture Diagram

## Component Overview

```mermaid
classDiagram
    namespace DomainLayer {
        class Flashcard {
            <<Entity>>
            +String uuid
            +String youtubeId
            +String title
            +String artist
            +String? album
            +int? year
            +String? genre
            +int? youtubeViewCount
            +int intervalMinutes
            +double easeFactor
            +int repetitions
            +DateTime nextReviewDate
            +int startAtSecond
            +DateTime createdAt
            +DateTime updatedAt
        }
        
        class FlashcardFactory {
            <<Factory>>
            +create() Flashcard
            +createDueCard() Flashcard
            +createFutureCard() Flashcard
        }
        
        class CardRepository {
            <<Interface>>
            +findByUuid(String) Flashcard?
            +save(Flashcard) Future~void~
            +deleteByUuid(String) Future~void~
            +fetchDueCards() Future~List~Flashcard~~
            +fetchAllCards() Future~List~Flashcard~~
        }
    }
    
    namespace DataLayer {
        class IsarCardRepository {
            <<Implementation>>
            -Isar _isar
            -FlashcardMapper _mapper
            +findByUuid(String) Flashcard?
            +save(Flashcard) Future~void~
            +deleteByUuid(String) Future~void~
        }
        
        class FlashcardMapper {
            <<Mapper>>
            +toDomain(IsarFlashcard) Flashcard
            +toData(Flashcard, Id?) IsarFlashcard
            +toDomainList(List) List~Flashcard~
            +toDataList(List) List~IsarFlashcard~
        }
        
        class IsarFlashcard {
            <<@collection>>
            +Id id
            +String uuid
            +String youtubeId
            +String title
            +String artist
            +String? album
            +int? year
            +String? genre
            +int? youtubeViewCount
            +int intervalMinutes
            +double easeFactor
            +int repetitions
            +DateTime nextReviewDate
            +int startAtSecond
            +DateTime createdAt
            +DateTime updatedAt
        }
    }
    
    FlashcardFactory --> Flashcard : creates
    CardRepository --> Flashcard : uses
    IsarCardRepository ..|> CardRepository : implements
    IsarCardRepository --> FlashcardMapper : uses
    IsarCardRepository --> IsarFlashcard : persists
    FlashcardMapper --> Flashcard : converts to
    FlashcardMapper --> IsarFlashcard : converts to
    
    note for Flashcard "Pure Dart\nNo database coupling"
    note for IsarFlashcard "uuid: @Index(unique)\nyoutubeId: @Index()\nnextReviewDate: @Index()"
```
## Data Flow: Save Operation

```mermaid
sequenceDiagram
    participant UI as Service/UI
    participant Factory as FlashcardFactory
    participant Domain as Flashcard (domain)
    participant Repo as IsarCardRepository
    participant Mapper as FlashcardMapper
    participant Data as IsarFlashcard (data)
    participant DB as Isar Database
    
    UI->>Factory: create()
    Factory->>Factory: Generate UUID
    Factory-->>UI: Flashcard with UUID
    Note over Domain: Pure Dart entity<br/>with stable UUID
    
    UI->>Repo: save(flashcard)
    Repo->>DB: Check if UUID exists
    DB-->>Repo: Existing Isar ID or null
    
    Repo->>Mapper: toData(flashcard, isarId?)
    Note over Mapper: Preserve Isar ID if update<br/>Or use autoIncrement if new
    Mapper-->>Repo: IsarFlashcard
    
    Repo->>DB: isar.isarFlashcards.put(isarFlashcard)
    Note over DB: Isar updates/inserts<br/>based on ID
    DB-->>Repo: Success
    Repo-->>UI: Complete
```
## Data Flow: Find Operation

```mermaid
sequenceDiagram
    participant UI as Caller (Service/UI)
    participant Repo as IsarCardRepository
    participant DB as Isar Database
    participant Mapper as FlashcardMapper
    participant Domain as Flashcard (domain)
    
    UI->>Repo: findByUuid(uuid)
    
    Repo->>DB: isar.isarFlashcards<br/>.filter()<br/>.uuidEqualTo(uuid)<br/>.findFirst()
    Note over DB: O(log n) lookup<br/>via unique index
    DB-->>Repo: IsarFlashcard? or null
    
    alt IsarFlashcard found
        Repo->>Mapper: toDomain(isarFlashcard)
        Note over Mapper: Discard Isar ID<br/>Keep UUID
        Mapper-->>Repo: Flashcard
        Repo-->>UI: Flashcard?
    else Not found
        Repo-->>UI: null
    end
```
## Index Strategy

### IsarFlashcard Indexes

| Field | Index Type | Purpose |
|-------|-----------|----------|
| `uuid` | **unique** | Primary lookup from domain layer |
| `youtubeId` | standard | Duplicate detection |
| `nextReviewDate` | standard | Due card queries (sorted) |

### Query Performance

- **findByUuid()**: O(log n) via unique index
- **existsByYoutubeId()**: O(log n) via index
- **fetchDueCards()**: O(k) via sorted index (k = due count)

## Benefits of This Architecture

### ✅ Domain Independence
Domain has no Isar imports/annotations - pure Dart entities

### ✅ Testability
Domain logic testable without database - use factory for test data

### ✅ Flexibility
Can swap Isar for SQLite/Hive without domain layer changes

### ✅ Stability
UUID references remain valid across database implementations

### ✅ Performance
Still benefits from Isar's auto-increment ID internally for optimal queries


## Benefits of This Architecture

```
┌──────────────────────────────────────────────────────────┐
│ ✅ Domain Independence                                   │
│    Domain has no Isar imports/annotations                │
├──────────────────────────────────────────────────────────┤
│ ✅ Testability                                           │
│    Domain logic testable without database                │
├──────────────────────────────────────────────────────────┤
│ ✅ Flexibility                                           │
│    Can swap Isar for SQLite/Hive without domain changes  │
├──────────────────────────────────────────────────────────┤
│ ✅ Stability                                             │
│    UUID references remain valid across DB implementations │
├──────────────────────────────────────────────────────────┤
│ ✅ Performance                                           │
│    Still benefits from Isar's auto-increment ID internally│
└──────────────────────────────────────────────────────────┘
```
