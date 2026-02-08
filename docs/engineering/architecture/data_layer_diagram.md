# Data Layer Architecture Diagram

## Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                           │
│                     (Pure Dart)                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────┐        ┌───────────────────────┐  │
│  │  Flashcard          │        │ FlashcardFactory      │  │
│  │  (Entity)           │        │                       │  │
│  ├─────────────────────┤        ├───────────────────────┤  │
│  │ + uuid: String      │◄───────│ + create()            │  │
│  │ + youtubeId: String │        │ + createDueCard()     │  │
│  │ + title: String     │        │ + createFutureCard()  │  │
│  │ + artist: String    │        └───────────────────────┘  │
│  │ + intervalDays: int │                                   │
│  │ + easeFactor: double│                                   │
│  │ + repetitions: int  │                                   │
│  │ + nextReviewDate    │                                   │
│  └─────────────────────┘                                   │
│           ▲                                                 │
│           │                                                 │
│  ┌────────┴────────────┐                                   │
│  │ CardRepository      │ (Interface)                       │
│  │                     │                                   │
│  ├─────────────────────┤                                   │
│  │ + findByUuid()      │                                   │
│  │ + save()            │                                   │
│  │ + deleteByUuid()    │                                   │
│  │ + fetchDueCards()   │                                   │
│  │ + fetchAllCards()   │                                   │
│  └─────────────────────┘                                   │
│           ▲                                                 │
└───────────┼─────────────────────────────────────────────────┘
            │
============│=================================================
            │
┌───────────┼─────────────────────────────────────────────────┐
│           │                DATA LAYER                       │
│           │              (Isar Implementation)              │
├───────────┴─────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────┐                                   │
│  │ IsarCardRepository  │ (Implementation)                  │
│  │                     │                                   │
│  ├─────────────────────┤                                   │
│  │ - _isar: Isar       │                                   │
│  │ - _mapper: Mapper   │                                   │
│  ├─────────────────────┤                                   │
│  │ + findByUuid()      │───┐                               │
│  │ + save()            │   │  Uses Mapper                  │
│  │ + deleteByUuid()    │   │                               │
│  └─────────────────────┘   │                               │
│           │                 │                               │
│           │                 ▼                               │
│           │    ┌────────────────────┐                      │
│           │    │ FlashcardMapper    │                      │
│           │    │                    │                      │
│           │    ├────────────────────┤                      │
│           │    │ + toDomain()       │                      │
│           │    │ + toData()         │                      │
│           │    │ + toDomainList()   │                      │
│           │    │ + toDataList()     │                      │
│           │    └────────────────────┘                      │
│           │                 │                               │
│           ▼                 ▼                               │
│  ┌─────────────────────────────────────┐                   │
│  │     IsarFlashcard                   │                   │
│  │     (@collection)                   │                   │
│  ├─────────────────────────────────────┤                   │
│  │ + id: Id (autoIncrement)            │ ◄─── Isar DB     │
│  │ + uuid: String @Index(unique)       │                   │
│  │ + youtubeId: String @Index()        │                   │
│  │ + title: String                     │                   │
│  │ + artist: String                    │                   │
│  │ + intervalDays: int                 │                   │
│  │ + easeFactor: double               │                   │
│  │ + repetitions: int                  │                   │
│  │ + nextReviewDate: DateTime @Index() │                   │
│  └─────────────────────────────────────┘                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow: Save Operation

```
1. Service/UI creates Flashcard with UUID
   ┌─────────────────────────────┐
   │ FlashcardFactory.create()   │
   │ → UUID auto-generated       │
   └──────────────┬──────────────┘
                  │
                  ▼
   ┌─────────────────────────────┐
   │ Flashcard with uuid         │
   │ (domain entity)             │
   └──────────────┬──────────────┘
                  │
2. Repository save()              │
                  ▼
   ┌─────────────────────────────────────┐
   │ IsarCardRepository.save()           │
   │ → Check if uuid exists in DB        │
   │ → Get existing Isar ID (if update)  │
   └──────────────┬──────────────────────┘
                  │
3. Map to data entity             │
                  ▼
   ┌─────────────────────────────────────┐
   │ FlashcardMapper.toData()            │
   │ → Preserve Isar ID if update        │
   │ → Or use autoIncrement if new       │
   └──────────────┬──────────────────────┘
                  │
4. Persist        │
                  ▼
   ┌─────────────────────────────────────┐
   │ isar.isarFlashcards.put()           │
   │ → Isar updates/inserts based on ID  │
   └─────────────────────────────────────┘
```

## Data Flow: Find Operation

```
1. Caller requests by UUID
   ┌─────────────────────────────┐
   │ repository.findByUuid(uuid) │
   └──────────────┬──────────────┘
                  │
2. Repository queries Isar       │
                  ▼
   ┌─────────────────────────────────────┐
   │ isar.isarFlashcards                 │
   │   .filter()                         │
   │   .uuidEqualTo(uuid)                │
   │   .findFirst()                      │
   └──────────────┬──────────────────────┘
                  │
3. Map to domain  │ (IsarFlashcard?)
                  ▼
   ┌─────────────────────────────────────┐
   │ FlashcardMapper.toDomain()          │
   │ → Discard Isar ID                   │
   │ → Keep UUID                         │
   └──────────────┬──────────────────────┘
                  │
4. Return domain entity           │
                  ▼
   ┌─────────────────────────────┐
   │ Flashcard? (domain entity)  │
   └─────────────────────────────┘
```

## Index Strategy

```
IsarFlashcard Indexes:

┌────────────────┬──────────┬─────────────────────────────┐
│ Field          │ Index    │ Purpose                     │
├────────────────┼──────────┼─────────────────────────────┤
│ uuid           │ unique   │ Primary lookup from domain  │
│ youtubeId      │ standard │ Duplicate detection         │
│ nextReviewDate │ standard │ Due card queries            │
└────────────────┴──────────┴─────────────────────────────┘

Query Performance:
- findByUuid(): O(log n) via unique index
- existsByYoutubeId(): O(log n) via index
- fetchDueCards(): O(k) via sorted index (k = due count)
```

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
