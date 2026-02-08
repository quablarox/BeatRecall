# DUEQUEUE - Due Queue Management

**Feature ID:** `DUEQUEUE`  
**Version:** 1.0  
**Last Updated:** 2026-02-07  
**Status:** Draft

## Table of Contents
- [Feature Overview](#feature-overview)
- [Requirements](#requirements)
  - [DUEQUEUE-001: Due Cards Retrieval](#duequeue-001-due-cards-retrieval)
  - [DUEQUEUE-002: Review Session](#duequeue-002-review-session)
- [User Flow](#user-flow)
- [Future Enhancements](#future-enhancements)
- [Test References](#test-references)
- [Related Documents](#related-documents)

---

## Feature Overview

Due Queue Management handles the retrieval and presentation of flashcards that are due for review. It orchestrates the review session flow, tracks progress, and provides session summaries to keep users motivated.

**Key Benefits:**
- Efficient queue management
- Progress tracking during sessions
- Smooth session flow
- Motivating completion summaries

---

## Requirements

### DUEQUEUE-001: Due Cards Retrieval

**Priority:** High  
**Status:** Not Started

**Description:**  
Fetch flashcards that are due for review based on their scheduled `nextReviewDate`. Cards are retrieved in priority order to ensure the most overdue cards are reviewed first.

**Acceptance Criteria:**
- Query condition: `nextReviewDate <= currentDateTime`
- Sort by due date (oldest first):
  - Most overdue cards appear first
  - Ties broken by card creation date (older first)
- Support batch loading for performance:
  - Load 10 cards at a time initially
  - Fetch next batch when user approaches end of current batch
  - Avoids loading all due cards at once (performance optimization)
- Update queue after each card review:
  - Remove reviewed card from queue
  - Fetch next card to maintain buffer
- Return empty queue when no cards are due
- Timezone handling:
  - Use device timezone for `currentDateTime`
  - Store `nextReviewDate` in UTC, convert for comparison

**Performance Notes:**
- Optimize database query with index on `nextReviewDate`
- For libraries > 1000 cards, pagination is critical

**Query Example (Isar):**
```dart
final dueCards = await isar.flashcards
  .filter()
  .nextReviewDateLessThan(DateTime.now())
  .sortByNextReviewDate()
  .limit(10)
  .findAll();
```

---

### DUEQUEUE-002: Review Session

**Priority:** High  
**Status:** In Progress

**Description:**  
Manage a continuous review session where users work through all cards due for the day. The session continues dynamically as long as cards are due, rather than limiting to a fixed count. Users can study both due cards (reviews) and new cards (up to daily limit).

**Acceptance Criteria:**
- **Session Scope:**
  - Session includes ALL cards where `nextReviewDate <= now`
  - Plus new cards (up to daily new cards limit from SETTINGS-001)
  - Session continues until no more cards are due today
  - Cards rated "Again" re-enter the session queue if still due today
  - Dynamic card count: "Card X of ~Y" (count may change as Again cards re-enter)
- **Progress Tracking:**
  - Display "Cards reviewed: X" (total reviewed in session)
  - Show "Due cards remaining: Y" (updates dynamically)
  - Progress indicator: percentage of initially due cards completed
  - Optional: Estimated time remaining based on average time per card
- **Navigation:**
  - Automatically load next due card after rating current card
  - Smooth transition between cards (no jarring jumps)
  - If user rates "Again": card is rescheduled and may appear later in same session
- **Session Controls:**
  - "Pause" button to exit session mid-review
  - Resume from where user left off
  - Session state persists across app restarts
  - "Finish Early" option to end session before all cards reviewed
- **Session Completion:**
  - Session ends automatically when no more cards are due
  - Session summary displays:
    - Total cards reviewed
    - Breakdown by rating: Again, Hard, Good, Easy
    - Total time spent in session
    - New cards studied today vs daily limit
    - Encouraging message (e.g., "All caught up! 🎉")
  - "Finish" button to return to dashboard
- **Edge Cases:**
  - No cards due: Show "All caught up!" with next review time
  - Only new cards due but limit reached: Show "Come back tomorrow for new cards"
  - Session interrupted: Auto-save progress
  - Very long sessions (>100 cards): Suggest break after every 25 cards

**Design Notes:**
- Dynamic card count requires careful UX: avoid confusing users when count changes
- "~" prefix on card count indicates approximate (e.g., "Card 5 of ~20")
- Progress indicator should be prominent but not distracting
- Session summary should feel rewarding
- Consider confetti animation on session completion (optional)

**Integration with Settings:**
- Respects SETTINGS-001 (daily new cards limit)
- Query includes: all due cards + new cards up to remaining daily limit
- Session continues until both due cards and new card quota exhausted

---

## User Flows

### Starting a Review Session
```
1. User opens app / taps "Start Review"
   ↓
2. System queries due cards (DUEQUEUE-001)
   ↓
3. If due cards exist:
     → Display first card (FLASHSYS-001)
     → Show progress: "Card 1 of 15"
   If no cards due:
     → Show "All caught up!" message
     → Display next review time
   ↓
4. User reviews card and rates (FLASHSYS-003)
   ↓
5. SRS calculates next interval (SRS-001)
   ↓
6. Card scheduled for next review (SRS-002)
   ↓
7. Next card loaded automatically
   ↓
8. Repeat steps 4-7 until queue is empty
   ↓
9. Session summary displayed (DUEQUEUE-002)
   ↓
10. User taps "Finish" → return to dashboard
```

### Pausing and Resuming
```
1. User is in middle of review session (card 8 of 20)
   ↓
2. User taps "Pause" button or closes app
   ↓
3. Session state saved:
   - Current progress (8/20)
   - Remaining cards in queue
   ↓
4. User returns later and opens app
   ↓
5. System detects incomplete session
   ↓
6. Prompt: "Resume your review session? (12 cards remaining)"
   ↓
7. If user taps "Resume":
     → Continue from card 9
   If user taps "Start Fresh":
     → Query due cards again (may be different)
```

---

## Future Enhancements

**Potential Subdivisions (Detailed Spec Phase):**

#### DUEQUEUE-001: Due Cards Retrieval
- `DUEQUEUE-001-F01`: Query cards with nextReviewDate <= now
- `DUEQUEUE-001-F02`: Sort by due date (oldest first)
- `DUEQUEUE-001-F03`: Implement batch loading (pagination)
- `DUEQUEUE-001-F04`: Handle timezone conversions
- `DUEQUEUE-001-F05`: Update queue after review

#### DUEQUEUE-002: Review Session
- `DUEQUEUE-002-F01`: Initialize session state
- `DUEQUEUE-002-F02`: Display progress indicator
- `DUEQUEUE-002-F03`: Navigate to next card
- `DUEQUEUE-002-F04`: Handle pause/resume
- `DUEQUEUE-002-F05`: Persist session state
- `DUEQUEUE-002-F06`: Generate session summary
- `DUEQUEUE-002-F07`: Display completion screen
- `DUEQUEUE-002-F08`: Handle "Review More" action

**Phase 2+ Enhancements:**
- Custom session length (e.g., "Review 10 cards")
- Session goals and achievements
- Daily streak tracking
- Review history calendar view
- Session scheduling (reminders/notifications)

---

## Test References

**Gherkin Scenario Examples:**

```gherkin
@DUEQUEUE-001
Scenario: Retrieve due cards sorted by due date
  Given I have 5 cards in my library
  And card "Song A" is due 2 days ago
  And card "Song B" is due 1 day ago
  And card "Song C" is due today
  And card "Song D" is due tomorrow
  And card "Song E" is due in 3 days
  When I query the due queue
  Then I should see 3 cards in the queue
  And the order should be "Song A", "Song B", "Song C"

@DUEQUEUE-002
Scenario: Complete a review session and see summary
  Given I have 10 cards due for review
  When I start a review session
  And I rate 3 cards as "Again"
  And I rate 2 cards as "Hard"
  And I rate 5 cards as "Good"
  Then I should see the session summary
  And it should show "10 cards reviewed"
  And it should show "Again: 3, Hard: 2, Good: 5, Easy: 0"
  And it should show a success rate of 50%
  And I should see an encouraging message

@DUEQUEUE-002
Scenario: Pause and resume review session
  Given I am in a review session with 20 cards
  And I have reviewed 8 cards
  When I tap the "Pause" button
  And I close the app
  And I reopen the app 1 hour later
  Then I should see a prompt to "Resume your review session"
  And it should show "12 cards remaining"
  When I tap "Resume"
  Then I should continue from card 9

@DUEQUEUE-001
Scenario: No cards due shows "All caught up" message
  Given I have 10 cards in my library
  And all cards are scheduled for future dates
  When I open the review screen
  Then I should see "All caught up! 🎉"
  And I should see "Next review: Tomorrow at 10:00 AM"
  And I should see a "Review New Cards" button if new cards exist
```

---

## Related Documents

- [SRS.md](SRS.md) - Scheduling logic for nextReviewDate
- [FLASHSYS.md](FLASHSYS.md) - Card display during review session
- [Glossary](../../GLOSSARY.md) - Domain terminology (Due Card, Review Queue, Session Summary, etc.)
- [Architecture](../../../engineering/architecture/architecture.md) - Service layer orchestration
- [User Stories](../../user_stories/user_stories.md) - Story 3.1, 6.1
