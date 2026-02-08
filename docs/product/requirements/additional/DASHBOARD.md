# DASHBOARD - Dashboard Overview

**Feature ID:** `DASHBOARD`  
**Version:** 1.0  
**Last Updated:** 2026-02-07  
**Status:** Detailed Spec

## Table of Contents
- [Feature Overview](#feature-overview)
- [Requirements](#requirements)
  - [DASHBOARD-001: Statistics Overview](#dashboard-001-statistics-overview)
- [User Flow](#user-flow)
- [Future Enhancements](#future-enhancements)
- [Test References](#test-references)
- [Related Documents](#related-documents)

---

## Feature Overview

The Dashboard provides users with an at-a-glance view of their learning progress, upcoming reviews, and library statistics. It serves as the main entry point of the application and motivates users through visual feedback on their performance and consistency.

**Key Benefits:**
- Immediate visibility of pending work (due cards)
- Motivation through progress tracking and streaks
- Quick access to start review sessions
- Clear understanding of library size and learning effectiveness

**Scope:**
- **In scope:** 
  - Display key statistics (due cards, library size, success rate, streak)
  - Quick action button to start review session
  - Visual indicators (charts, progress bars, badges)
  - Real-time data updates
- **Out of scope:** 
  - Detailed analytics dashboard (Phase 2)
  - Historical charts beyond 7-day success rate
  - Social features (leaderboards, sharing)
  - Customizable dashboard widgets

---

## Requirements

### DASHBOARD-001: Overview Display

**Priority:** High  
**Status:** Not Started

**Description:**  
Display key learning statistics and metrics on the main screen to give users immediate insight into their progress and pending work. The dashboard combines motivational elements (streak counter) with actionable information (due cards count).

**Acceptance Criteria:**
- Count of due cards today is prominently displayed
- Total cards in library is visible
- Success rate for last 7 days is shown as percentage
- Review streak counter displays consecutive days
- Quick access button to start review session
- All statistics update in real-time when data changes
- Dashboard loads within 500ms on app launch
- Graceful handling when no cards exist yet
- Visual indicators use color coding (red for overdue, green for success)

**Dependencies:**
- Requires `DUEQUEUE-001` for due cards count
- Requires `SRS-003` for success rate calculation
- Requires local storage for streak tracking

**Technical Notes:**
- Use reactive state management (Provider) for real-time updates
- Cache statistics to avoid repeated database queries
- Calculate statistics asynchronously to prevent UI blocking

---

#### Functions (Detailed Spec)

##### DASHBOARD-001-F01: Fetch Due Cards Count

**Status:** 🔴 Not Started

**Description:**  
Query the database to count flashcards whose `nextReviewDate` is less than or equal to the current datetime. This count is the primary actionable metric on the dashboard.

**Implementation Details:**
- Query Isar database with filter: `nextReviewDate <= DateTime.now()`
- Return count only (no need to fetch full card objects)
- Cache result for 60 seconds to avoid repeated queries
- Invalidate cache when user completes a review session

**Input:**
- None (uses current system datetime)

**Output:**
- `int dueCardsCount`: Number of cards due for review (0 or more)

**Error Handling:**
- Database connection error: Return 0 and log error
- Query timeout: Return last cached value if available, otherwise 0

**Test Coverage:**
```gherkin
@DASHBOARD-001-F01
Scenario: Display due cards count when cards are overdue
  Given I have 5 cards in my library
  And 3 cards have nextReviewDate of yesterday
  When the dashboard loads
  Then I should see "3 cards due"

@DASHBOARD-001-F01
Scenario: Show zero when no cards are due
  Given I have 10 cards in my library
  And all cards have nextReviewDate in the future
  When the dashboard loads
  Then I should see "0 cards due"
  And I should see a message "All caught up! 🎉"
```

**Assigned To:** TBD  
**Estimated Effort:** 2 story points

---

##### DASHBOARD-001-F02: Fetch Total Cards Count

**Status:** 🔴 Not Started

**Description:**  
Count the total number of flashcards in the user's library, regardless of their review status. This provides context for the user's collection size.

**Implementation Details:**
- Query Isar database: `isar.flashcards.count()`
- Cache result until card is added/deleted
- Update count immediately after import operations

**Input:**
- None

**Output:**
- `int totalCards`: Total number of cards in library (0 or more)

**Error Handling:**
- Database error: Return 0 and show generic error message
- Empty library: Return 0 (valid state for new users)

**Test Coverage:**
```gherkin
@DASHBOARD-001-F02
Scenario: Display total cards in library
  Given I have 25 cards in my library
  When the dashboard loads
  Then I should see "25 cards total"

@DASHBOARD-001-F02
Scenario: Show zero for new user with no cards
  Given I have 0 cards in my library
  When the dashboard loads
  Then I should see "0 cards total"
  And I should see a prompt "Add your first card!"
```

**Assigned To:** TBD  
**Estimated Effort:** 1 story point

---

##### DASHBOARD-001-F03: Calculate Success Rate (Last 7 Days)

**Status:** 🔴 Not Started

**Description:**  
Calculate the percentage of reviews rated as "Good" (3) or "Easy" (4) in the last 7 days. This metric shows learning effectiveness and motivates users.

**Implementation Details:**
- Query review logs from last 7 days: `timestamp >= DateTime.now().subtract(Duration(days: 7))`
- Count reviews where `response == 3 || response == 4` (success)
- Divide by total reviews and multiply by 100 for percentage
- Round to nearest integer
- Handle case where no reviews exist in period

**Input:**
- None (uses current date minus 7 days)

**Output:**
- `int successRatePercentage`: Success rate as integer 0-100
- `int totalReviewsLast7Days`: Total reviews in period (for context)

**Error Handling:**
- No reviews in period: Show "N/A" or "No reviews yet"
- Division by zero: Return 0% with message "Start reviewing to see stats"

**Test Coverage:**
```gherkin
@DASHBOARD-001-F03
Scenario: Calculate success rate with mixed reviews
  Given I completed 20 reviews in the last 7 days
  And 5 were rated "Again"
  And 3 were rated "Hard"
  And 8 were rated "Good"
  And 4 were rated "Easy"
  When the dashboard displays success rate
  Then I should see "60%" (12 successes / 20 total)

@DASHBOARD-001-F03
Scenario: Show N/A when no reviews in last 7 days
  Given I have not reviewed any cards in the last 7 days
  When the dashboard loads
  Then I should see "Success Rate: N/A"
  And I should see "Start reviewing to track progress"
```

**Assigned To:** TBD  
**Estimated Effort:** 3 story points

---

##### DASHBOARD-001-F04: Track Review Streak

**Status:** 🔴 Not Started

**Description:**  
Calculate the number of consecutive days the user has completed at least one review. Streaks reset if a day is skipped. This gamification element encourages daily usage.

**Implementation Details:**
- Query review logs ordered by date descending
- Iterate backwards from today, checking each day for at least 1 review
- Stop counting when a day with 0 reviews is found
- Store streak count in local preferences for quick access
- Update streak after each review session

**Input:**
- None (checks from current date backwards)

**Output:**
- `int streakDays`: Number of consecutive days with reviews (0 or more)

**Error Handling:**
- No reviews ever: Return 0 (valid for new users)
- Missing data for a date: Treat as 0 reviews for that day

**Test Coverage:**
```gherkin
@DASHBOARD-001-F04
Scenario: Display current streak for consistent user
  Given I reviewed cards on the following days:
    | Date       | Reviews |
    | 2026-02-07 | 5       |
    | 2026-02-06 | 3       |
    | 2026-02-05 | 8       |
    | 2026-02-04 | 2       |
    | 2026-02-03 | 0       |
    | 2026-02-02 | 4       |
  When the dashboard loads on 2026-02-07
  Then I should see "4 day streak 🔥"

@DASHBOARD-001-F04
Scenario: Streak resets after missing a day
  Given I had a 10-day streak
  And I did not review cards yesterday
  When the dashboard loads
  Then I should see "0 day streak"
  And I should see encouragement "Start a new streak today!"

@DASHBOARD-001-F04
Scenario: Today's reviews count toward streak
  Given I reviewed 3 cards today
  And I reviewed cards yesterday
  When the dashboard loads
  Then the streak should include today
```

**Assigned To:** TBD  
**Estimated Effort:** 5 story points

---

##### DASHBOARD-001-F05: Render Dashboard UI

**Status:** 🔴 Not Started

**Description:**  
Display all statistics in an intuitive, visually appealing layout. Use cards, icons, and color coding to make information scannable at a glance.

**Implementation Details:**
- Use Material Design Card widgets for each statistic
- Color coding:
  - Red/Warning: Overdue cards (> 10 due)
  - Green/Success: High success rate (> 80%)
  - Orange: Moderate due cards (1-10)
  - Gray: No data yet
- Include icons for each metric:
  - Due cards: Calendar icon
  - Total cards: Library/Book icon
  - Success rate: Trophy/Star icon
  - Streak: Fire/Flame icon
- Prominent "Start Review" button (primary color, elevated)
- Responsive grid layout (2x2 on mobile, 4x1 on tablet)

**Input:**
- `int dueCardsCount` (from F01)
- `int totalCards` (from F02)
- `int successRatePercentage` (from F03)
- `int totalReviewsLast7Days` (from F03)
- `int streakDays` (from F04)

**Output:**
- Rendered dashboard Widget

**Error Handling:**
- Handle null values gracefully (show loading skeleton)
- Show friendly messages for empty states:
  - No cards: "Add your first flashcard to get started"
  - No reviews: "Complete your first review session"

**Test Coverage:**
```gherkin
@DASHBOARD-001-F05
Scenario: Display dashboard with all statistics
  Given due cards count is 12
  And total cards is 50
  And success rate is 75%
  And streak is 7 days
  When the dashboard renders
  Then I should see "12 cards due" with calendar icon
  And I should see "50 cards total" with library icon
  And I should see "75% success rate" with trophy icon
  And I should see "7 day streak 🔥" with flame icon
  And I should see a prominent "Start Review" button

@DASHBOARD-001-F05
Scenario: Display empty state for new user
  Given I have 0 cards in my library
  When the dashboard renders
  Then I should see "Welcome to BeatRecall!"
  And I should see "Add your first flashcard to get started"
  And I should see "Import from CSV" button
  And I should see "Create Manually" button
```

**Assigned To:** TBD  
**Estimated Effort:** 5 story points

---

##### DASHBOARD-001-F06: Handle Start Review Action

**Status:** 🔴 Not Started

**Description:**  
Navigate user to review session when "Start Review" button is tapped. Handle cases where no cards are due.

**Implementation Details:**
- On button tap, navigate to Review Session screen
- If `dueCardsCount == 0`, show dialog:
  - "All caught up! 🎉"
  - "No cards are due for review right now."
  - "Next review: [datetime of next due card]"
  - Button: "Review New Cards" (if new cards exist)
  - Button: "OK"
- Use Navigator.push() for screen transition
- Pass session context (number of due cards) to review screen

**Input:**
- `int dueCardsCount` (from F01)
- User tap on "Start Review" button

**Output:**
- Navigation to Review Session screen OR
- Display "All caught up" dialog

**Error Handling:**
- Database error when checking due cards: Show error dialog and stay on dashboard
- Navigation error: Log error and show generic message

**Test Coverage:**
```gherkin
@DASHBOARD-001-F06
Scenario: Start review session when cards are due
  Given I have 5 cards due
  When I tap the "Start Review" button
  Then I should navigate to the Review Session screen
  And the session should start with the first due card

@DASHBOARD-001-F06
Scenario: Show message when no cards are due
  Given I have 0 cards due
  When I tap the "Start Review" button
  Then I should see a dialog "All caught up! 🎉"
  And I should see "No cards are due for review right now"
  And I should see "Next review: Tomorrow at 9:00 AM"
  And I should see an "OK" button
```

**Assigned To:** TBD  
**Estimated Effort:** 2 story points

---

##### DASHBOARD-001-F07: Real-Time Statistics Updates

**Status:** 🔴 Not Started

**Description:**  
Update dashboard statistics automatically when underlying data changes, without requiring manual refresh. Use reactive state management to observe data changes.

**Implementation Details:**
- Use StreamBuilder or ValueListenableBuilder to observe database changes
- Invalidate cached statistics when:
  - User completes a review session
  - User adds/deletes cards
  - User imports cards
  - App returns to foreground (check if date changed)
- Debounce updates to avoid excessive re-renders (max 1 update per second)

**Input:**
- Database change notifications (Isar watch streams)
- App lifecycle events (foreground/background)

**Output:**
- Updated statistics displayed on dashboard

**Error Handling:**
- Stream error: Continue showing last valid data, log error
- Rebuild failure: Show error state with retry button

**Test Coverage:**
```gherkin
@DASHBOARD-001-F07
Scenario: Update due cards count after completing review
  Given the dashboard shows "10 cards due"
  When I complete a review session of 5 cards
  And I return to the dashboard
  Then the dashboard should show "5 cards due"
  And the success rate should update based on new reviews

@DASHBOARD-001-F07
Scenario: Update total cards after CSV import
  Given the dashboard shows "25 cards total"
  When I import 15 cards from CSV
  And I return to the dashboard
  Then the dashboard should show "40 cards total"

@DASHBOARD-001-F07
Scenario: Update streak when day changes
  Given the dashboard shows "5 day streak"
  And I did not review cards today yet
  When the app opens the next day
  Then the dashboard should show "0 day streak"
  And I should see "Start a new streak today!"
```

**Assigned To:** TBD  
**Estimated Effort:** 3 story points

---

## User Flows

### Primary User Flow: Returning User

```
1. User opens app
   ↓
2. Dashboard loads (DASHBOARD-001-F01 to F05)
   ↓
3. User sees statistics:
   - 12 cards due for review
   - 50 cards in library
   - 75% success rate (last 7 days)
   - 7 day streak 🔥
   ↓
4. User taps "Start Review" button (DASHBOARD-001-F06)
   ↓
5. Navigate to Review Session screen
   ↓
6. [User completes reviews]
   ↓
7. User returns to dashboard
   ↓
8. Statistics update automatically (DASHBOARD-001-F07):
   - Now shows 5 cards due
   - Success rate updated to 78%
   - Streak maintained at 7 days
```

### Alternative Flow: New User (Empty Library)

```
1. User opens app for first time
   ↓
2. Dashboard loads
   ↓
3. Dashboard detects 0 cards (DASHBOARD-001-F02)
   ↓
4. Display empty state (DASHBOARD-001-F05):
   - "Welcome to BeatRecall!"
   - "Add your first flashcard to get started"
   - "Import from CSV" button
   - "Create Manually" button
   ↓
5. User taps "Import from CSV"
   ↓
6. Navigate to CSV Import screen
   ↓
7. [User imports cards]
   ↓
8. Return to dashboard
   ↓
9. Dashboard updates (DASHBOARD-001-F07):
   - Shows new card count
   - Shows "Start Review" button (if cards imported)
```

### Alternative Flow: All Caught Up

```
1. User opens app
   ↓
2. Dashboard loads
   ↓
3. Dashboard shows 0 cards due (DASHBOARD-001-F01)
   ↓
4. User taps "Start Review" button
   ↓
5. Show "All caught up!" dialog (DASHBOARD-001-F06):
   - "No cards are due for review right now"
   - "Next review: Tomorrow at 9:00 AM"
   - "Review New Cards" button (if available)
   - "OK" button
   ↓
6. User taps "OK"
   ↓
7. Stay on dashboard
```

---

## Design Considerations

### UI/UX Mockups
- **Layout:** 2x2 grid on mobile (portrait), 4x1 row on tablet (landscape)
- **Color Palette:**
  - Primary: #2196F3 (Blue) for "Start Review" button
  - Success: #4CAF50 (Green) for positive metrics
  - Warning: #FF9800 (Orange) for moderate alerts
  - Error: #F44336 (Red) for overdue items
  - Accent: #FFC107 (Amber) for streak flame icon
- **Typography:**
  - Metric values: Bold, 32sp
  - Metric labels: Regular, 14sp
  - Empty state: Regular, 16sp
- **Spacing:** 16dp padding between cards, 8dp internal padding

### Accessibility Considerations (WCAG 2.1 Level AA)
- **Color Contrast:** All text meets 4.5:1 ratio against background
- **Screen Reader:** Semantic labels for all statistics
  - "12 cards due for review"
  - "Success rate 75 percent over last 7 days"
  - "Current streak: 7 days"
- **Touch Targets:** Minimum 48x48dp for "Start Review" button
- **Focus Indicators:** Visible focus state for keyboard navigation

### Performance Requirements
- Dashboard load time: < 500ms on average device
- Statistics calculation: < 100ms per metric
- UI render time: < 16ms (60 fps)
- Memory usage: < 50MB for dashboard screen

### Security Considerations
- No sensitive data displayed on dashboard
- Statistics calculated client-side (no API calls)
- No authentication required (single-user app)

---

## Testing Strategy

### Unit Tests
- Test `DASHBOARD-001-F01`: Due cards count calculation
- Test `DASHBOARD-001-F02`: Total cards count
- Test `DASHBOARD-001-F03`: Success rate calculation with various inputs
- Test `DASHBOARD-001-F04`: Streak calculation logic (consecutive days, reset on skip)
- Test edge cases: Empty library, no reviews, single card, single day

**Coverage Target:** 95%

### Integration Tests
- Test dashboard data loading from Isar database
- Test statistics refresh after review session completion
- Test statistics refresh after card import
- Test navigation to Review Session screen

**Coverage Target:** 85%

### E2E Tests
```gherkin
@DASHBOARD @E2E
Feature: Dashboard Overview
  As a user
  I want to see my learning progress at a glance
  So that I can stay motivated and know what to do next

  Scenario: View dashboard with active learning
    Given I have 50 cards in my library
    And 12 cards are due for review
    And I completed 20 reviews in the last 7 days with 75% success rate
    And I have a 7-day review streak
    When I open the app
    Then I should see "12 cards due" with a calendar icon
    And I should see "50 cards total" with a library icon
    And I should see "75% success rate (last 7 days)"
    And I should see "7 day streak 🔥"
    And I should see a "Start Review" button

  Scenario: New user sees empty state
    Given I am a new user with no cards
    When I open the app
    Then I should see "Welcome to BeatRecall!"
    And I should see "Add your first flashcard to get started"
    And I should see "Import from CSV" button
    And I should see "Create Manually" button

  Scenario: Start review session from dashboard
    Given I have 5 cards due
    When I tap "Start Review" on the dashboard
    Then I should be on the Review Session screen
    And I should see the first due card
```

### Manual Testing Checklist
- [ ] Test on iOS 14+ (iPhone 8, iPhone 12, iPhone 14)
- [ ] Test on Android 10+ (Pixel 4, Samsung Galaxy S21)
- [ ] Test with 0, 1, 10, 100, 1000+ cards (performance)
- [ ] Test with slow database operations (loading states)
- [ ] Test with screen reader enabled (VoiceOver, TalkBack)
- [ ] Test in dark mode and light mode
- [ ] Test with different font sizes (accessibility settings)
- [ ] Test landscape orientation on tablets
- [ ] Test with very long streak numbers (999+ days)
- [ ] Test rapid navigation (tap button multiple times quickly)

---

## Implementation Roadmap

### Phase 1: Core Statistics (Week 1)
- [ ] `DASHBOARD-001-F01` - Fetch due cards count
- [ ] `DASHBOARD-001-F02` - Fetch total cards count
- [ ] `DASHBOARD-001-F03` - Calculate success rate
- [ ] Unit tests for Phase 1 (90% coverage)

### Phase 2: Streak & UI (Week 2)
- [ ] `DASHBOARD-001-F04` - Track review streak
- [ ] `DASHBOARD-001-F05` - Render dashboard UI
- [ ] `DASHBOARD-001-F06` - Handle start review action
- [ ] Integration tests for navigation

### Phase 3: Real-Time & Polish (Week 3)
- [ ] `DASHBOARD-001-F07` - Real-time statistics updates
- [ ] Empty state handling
- [ ] Accessibility audit and fixes
- [ ] E2E tests
- [ ] Performance optimization (if needed)

**Total Estimated Effort:** 21 story points / 3 weeks

---

## Metrics & Success Criteria

### Key Performance Indicators (KPIs)
- Dashboard load time: < 500ms (p95)
- Daily active users (DAU) viewing dashboard: > 80% of users
- Tap-through rate on "Start Review" button: > 60%
- User satisfaction with dashboard: > 4.0/5.0 in feedback

### Definition of Done
- [x] All 7 functions implemented and merged
- [ ] Unit test coverage > 95%
- [ ] Integration tests passing
- [ ] E2E tests passing (3 scenarios)
- [ ] Code reviewed and approved by 2 developers
- [ ] Performance benchmarks met (< 500ms load)
- [ ] Accessibility audit passed (WCAG 2.1 AA)
- [ ] UI reviewed by designer
- [ ] Dark mode tested
- [ ] Documentation updated (inline comments, README)
- [ ] Product Owner sign-off

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Slow statistics calculation on large libraries (10k+ cards) | Medium | High | Implement caching, background calculation, pagination |
| Streak calculation bug (incorrect day counting) | Medium | Medium | Comprehensive unit tests, edge case coverage, QA review |
| Real-time updates causing UI flicker | Low | Medium | Debounce updates, use smooth animations |
| Dashboard crashes on database error | Low | High | Robust error handling, fallback to cached data |
| Streak counter demotivates users who miss a day | Low | Medium | Show positive messaging, "longest streak" stat in future |

---

## Future Enhancements

### Beyond Current Scope
- **Customizable Widgets:** Allow users to choose which stats to display (add to backlog)
- **Historical Charts:** Line graph of success rate over time (Phase 2)
- **Milestone Badges:** Achievements for reaching streak milestones (Phase 3)
- **Daily Goal Setting:** Let users set target review count per day (Phase 2)
- **Quick Actions:** Swipe gestures for common tasks (consider for Phase 2)

### Technical Debt
- Consider using a charting library (fl_chart) if graphs are added in Phase 2
- Refactor statistics calculation into separate service class for reusability
- Implement persistent caching layer (shared_preferences or Hive) for faster loads

---

## Change Log

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2026-02-07 | 1.0 | Initial detailed spec created | Team |

---

## Related Documents

- [DUEQUEUE.md](../core/DUEQUEUE.md) - Due cards retrieval logic
- [SRS.md](../core/SRS.md) - Success rate calculation depends on review logs
- [CARDMGMT.md](../core/CARDMGMT.md) - Total cards count comes from card library
- [Glossary](../../GLOSSARY.md) - Domain terminology (Due Card, Success Rate, Review Streak)
- [Architecture](../../../engineering/architecture/architecture.md) - Presentation layer implementation
- [User Stories](../../user_stories/user_stories.md) - Story 4.1 (View My Statistics)

---

## Notes

- **Streak Calculation:** The streak counter is intentionally strict (requires daily reviews) to encourage habit formation. User research may inform whether to relax this (e.g., allow one "skip day" per week).
- **7-Day Window:** Success rate uses a rolling 7-day window to provide recent feedback without being too volatile. This can be adjusted based on user feedback.
- **Empty State:** Special attention needed for new user experience - the empty state is the first impression and should guide users to add content.
- **Color Coding:** Overdue card threshold of 10 is arbitrary; can be made configurable in settings later.
