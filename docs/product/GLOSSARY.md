# Glossary - BeatRecall

**Version:** 1.0  
**Last Updated:** 2026-02-07  
**Status:** Draft

---

## Purpose

This glossary defines the **Ubiquitous Language** used throughout BeatRecall documentation and code. All team members (Product, Engineering, QA) should use these terms consistently.

---

## Domain Terms

### Flashcard
A learning unit consisting of a question (YouTube audio/video clip) and an answer (song title + artist). Each flashcard tracks its own learning progress through the spaced repetition system.

**Related Terms:** Review, Due Card

---

### Spaced Repetition System (SRS)
An evidence-based learning technique that schedules reviews at increasing intervals to optimize long-term retention. BeatRecall uses the SuperMemo-2 (SM-2) algorithm.

**Abbreviation:** SRS  
**Related Terms:** SM-2 Algorithm, Interval, Review Scheduling

---

### SM-2 Algorithm
The SuperMemo-2 algorithm for calculating optimal review intervals based on user performance. Developed by Piotr Woźniak in 1987.

**Related Terms:** Ease Factor, Interval, Repetition

---

### Review Session
A continuous period where users work through due cards, rating their recall performance for each card.

**Related Terms:** Session Summary, Progress Tracking

---

### Due Card
A flashcard whose `nextReviewDate` has passed and is ready for review.

**Related Terms:** Review Queue, Overdue Card

---

### Card Status
The learning state of a flashcard:
- **New:** Never reviewed (repetitions = 0)
- **Learning:** In initial learning phase (repetitions < 3)
- **Review:** In long-term review phase (repetitions ≥ 3)

**Related Terms:** Repetition, Learning Phase

---

### Rating
User's self-assessment of recall performance for a reviewed card:
- **Again (0):** Failed to recall; card resets to learning mode
- **Hard (1):** Recalled with difficulty; shorter interval
- **Good (3):** Recalled correctly; standard interval
- **Easy (4):** Recalled easily; longer interval

**Synonyms:** Answer Quality, Performance Rating  
**Related Terms:** Interval Calculation, Ease Factor

---

### Ease Factor
A multiplier (1.3 to 4.0) that adjusts review intervals based on card difficulty. Cards that are easier to remember have higher ease factors, resulting in longer intervals.

**Default Value:** 2.5  
**Related Terms:** SM-2 Algorithm, Interval

---

### Interval
The number of days between reviews. Intervals increase with successful reviews and reset with failed reviews.

**Unit:** Days  
**Related Terms:** Next Review Date, Scheduling

---

### Next Review Date
The scheduled date and time when a card becomes due for review.

**Type:** DateTime  
**Related Terms:** Due Card, Scheduling

---

### Repetition
The count of consecutive successful reviews (rated "Good" or "Easy") for a card. Resets to 0 after an "Again" rating.

**Related Terms:** Card Status, Learning Phase

---

### Review Log
Historical record of all reviews for a card, including timestamp, rating, interval, and ease factor changes.

**Related Terms:** Performance Tracking, Statistics

---

### Review Queue
The ordered list of cards currently due for review, sorted by due date (oldest first).

**Synonyms:** Due Queue  
**Related Terms:** Due Card, Review Session

---

### YouTube ID
The unique 11-character identifier for a YouTube video, extracted from the full YouTube URL.

**Example:** `dQw4w9WgXcQ` (from `https://www.youtube.com/watch?v=dQw4w9WgXcQ`)  
**Related Terms:** YouTube URL, Video

---

### Start Timestamp
The position (in seconds) where YouTube playback should begin for a flashcard. Used to skip intros or navigate to the relevant part of a video.

**Unit:** Seconds  
**Default:** 0  
**Related Terms:** YouTube Player, Audio Trimming

---

### Learning Phase
The initial stage where a new card is reviewed more frequently (shorter intervals) until it reaches 3 consecutive successful reviews.

**Duration:** Typically first 3 repetitions  
**Related Terms:** Card Status, New Card

---

### Session Summary
A recap displayed at the end of a review session showing total cards reviewed, rating breakdown, time spent, and success rate.

**Related Terms:** Review Session, Progress Tracking

---

### CSV Import
The process of bulk loading flashcards from a Comma-Separated Values (CSV) file containing YouTube URLs, titles, artists, and optional start timestamps.

**File Format:** CSV with header row  
**Related Terms:** Bulk Import, Card Management

---

### Card Library
The complete collection of all flashcards created by the user, including new, learning, and review cards.

**Synonyms:** Collection, Deck (future: multiple decks)  
**Related Terms:** Card Management, Search and Filter

---

### Overdue Card
A card whose `nextReviewDate` is in the past. Overdue cards are prioritized in the review queue to maintain learning effectiveness.

**Related Terms:** Due Card, Review Queue

---

### Success Rate
The percentage of reviews rated as "Good" or "Easy" versus total reviews in a session or for a specific card.

**Calculation:** (Good + Easy) / Total Reviews × 100%  
**Related Terms:** Performance Tracking, Statistics

---

## Technical Terms

### YouTube URL
The full web address of a YouTube video, in formats:
- `https://www.youtube.com/watch?v=VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- `VIDEO_ID` (direct ID)

**Related Terms:** YouTube ID, Video

---

### Validation
The process of checking data integrity before saving (e.g., verifying YouTube URL format, required fields, duplicate detection).

**Related Terms:** Error Handling, Data Integrity

---

### Duplicate Detection
Checking if a card with the same YouTube ID already exists before creating or importing a new card.

**Related Terms:** CSV Import, Validation

---

## Usage Guidelines

1. **Consistency:** Use these exact terms in code, documentation, and communication
2. **Code Naming:** Variable and class names should reflect these terms (e.g., `easeFactor`, `reviewSession`, not `easynessFactor` or `studySession`)
3. **Documentation:** Reference this glossary when terms need clarification
4. **Evolution:** Update this glossary when new domain concepts are introduced

---

## Related Documents

- [Core Requirements](requirements/core/README.md) - Features using these terms
- [User Stories](user_stories/user_stories.md) - User-facing terminology
- [Architecture](../engineering/architecture/architecture.md) - Implementation of domain model
