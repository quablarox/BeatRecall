# SRS - Spaced Repetition System

**Feature ID:** `SRS`  
**Version:** 1.0  
**Last Updated:** 2026-02-07  
**Status:** Draft

## Table of Contents
- [Feature Overview](#feature-overview)
- [Requirements](#requirements)
  - [SRS-001: SM-2 Algorithm Implementation](#srs-001-sm-2-algorithm-implementation)
  - [SRS-002: Review Scheduling](#srs-002-review-scheduling)
  - [SRS-003: Performance Tracking](#srs-003-performance-tracking)
- [Future Enhancements](#future-enhancements)
- [Test References](#test-references)
- [Related Documents](#related-documents)

---

## Feature Overview

The Spaced Repetition System (SRS) implements the SuperMemo-2 (SM-2) algorithm to optimize learning intervals based on user performance. This system schedules flashcard reviews at scientifically-proven intervals to maximize long-term retention while minimizing study time.

**Key Benefits:**
- Evidence-based learning intervals
- Adaptive scheduling based on performance
- Long-term retention optimization
- Efficient study time management

---

## Requirements

### SRS-001: SM-2 Algorithm Implementation

**Priority:** High  
**Status:** Not Started

**Description:**  
Implement the SuperMemo-2 (SM-2) algorithm for calculating optimal learning intervals based on user recall performance.

**Acceptance Criteria:**
- System calculates next review date based on user response (Again, Hard, Good, Easy)
- Ease factor starts at 2.5 and adjusts based on performance
- Interval calculation follows granular Anki-like progression:
  - Again (0): Reset to learning mode (interval=0, repetitions=0), penalize ease factor by -0.2 for young cards
  - Hard (1): Shorter interval (1d for new, repeat step for learning, 1.2× for review), ease factor decreased by 0.15
  - Good (3): Granular intervals (1d → 3d → 8d → 20d → ...), ease factor unchanged
  - Easy (4): Longer intervals (4d → 7d → 24d → ...), ease factor increased by 0.15
- Minimum ease factor is 1.3
- Maximum interval cap can be configured (default: 365 days)
- Algorithm implementation is testable in isolation

**Notes:**
- SM-2 algorithm chosen for simplicity and proven effectiveness
- Future consideration: SM-15, FSRS (Free Spaced Repetition Scheduler)

---

### SRS-002: Review Scheduling

**Priority:** High  
**Status:** Not Started

**Description:**  
Schedule and manage card reviews based on SRS calculations. The system maintains a queue of cards due for review and updates scheduling after each review session.

**Acceptance Criteria:**
- Cards are scheduled for review at calculated datetime (`nextReviewDate`)
- System supports review queue management (fetch cards where `nextReviewDate <= currentDateTime`)
- Overdue cards are prioritized (oldest due date first)
- Review history is tracked for each card:
  - Review timestamp
  - User response (Again/Hard/Good/Easy)
  - Interval applied
  - Ease factor after review
- Queue updates immediately after each card review
- Timezone handling is consistent

**Dependencies:**
- Requires `SRS-001` for interval calculation
- Integrates with `DUEQUEUE-001` for queue retrieval

---

### SRS-003: Performance Tracking

**Priority:** Medium  
**Status:** Not Started

**Description:**  
Track user performance over time to provide insights into learning progress and flashcard scheduling (e.g., ease factor and intervals).


**Acceptance Criteria:**
- Store review history for each card:
  - Date and time of review
  - User response (Again/Hard/Good/Easy)
  - Interval before and after review
  - Ease factor after review
- Calculate success rate per card:
  - Success = "Good" or "Easy" response
  - Failure = "Again" or "Hard" response
- Track total reviews completed (overall and per card)
- Support statistics export (CSV format)
- Performance data persists across app sessions

**Notes:**
- Detailed analytics dashboard is deferred to Phase 2
- Basic stats provide foundation for future insights

---

## Future Enhancements

**Potential Subdivisions (Detailed Spec Phase):**

#### SRS-001: SM-2 Algorithm Implementation
- `SRS-001-F01`: Calculate interval for "Again" response
- `SRS-001-F02`: Calculate interval for "Hard" response
- `SRS-001-F03`: Calculate interval for "Good" response
- `SRS-001-F04`: Calculate interval for "Easy" response
- `SRS-001-F05`: Adjust ease factor based on response
- `SRS-001-F06`: Apply minimum ease factor constraint (1.3)
- `SRS-001-F07`: Apply maximum interval cap

#### SRS-002: Review Scheduling
- `SRS-002-F01`: Schedule card for next review date
- `SRS-002-F02`: Update card status (New → Learning → Review)
- `SRS-002-F03`: Log review to history
- `SRS-002-F04`: Handle timezone conversions

#### SRS-003: Performance Tracking
- `SRS-003-F01`: Persist review log entry
- `SRS-003-F02`: Calculate card success rate
- `SRS-003-F03`: Count total reviews
- `SRS-003-F04`: Export statistics to CSV

---

## Test References

**Gherkin Scenario Examples:**

```gherkin
@SRS-001
Scenario: Calculate interval for "Good" response on first review
  Given a new flashcard with ease factor 2.5
  When the user rates the card as "Good"
  Then the next interval should be 1 day
  And the ease factor should remain 2.5

@SRS-001
Scenario: Ease factor decreases after "Hard" response
  Given a card with ease factor 2.5
  When the user rates the card as "Hard"
  Then the ease factor should decrease by 0.15 to 2.35
  And the ease factor should not go below 1.3

@SRS-002
Scenario: Overdue cards appear in review queue
  Given a card with nextReviewDate of 2 days ago
  When I fetch the due queue
  Then the card should appear in the queue
  And it should be prioritized by oldest due date
```

---

## Related Documents

- [FLASHSYS.md](FLASHSYS.md) - User interface for rating cards
- [DUEQUEUE.md](DUEQUEUE.md) - Queue management for due cards
- [Glossary](../../GLOSSARY.md) - Domain terminology (Ease Factor, Interval, Repetition, etc.)
- [Architecture](../../../engineering/architecture/architecture.md) - Domain layer implementation
- [User Stories](../../user_stories/user_stories.md) - Story 1.1, 3.1, 6.1
