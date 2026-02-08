# SETTINGS - Application Settings

**Feature ID:** `SETTINGS`  
**Version:** 1.0  
**Last Updated:** 2026-02-08  
**Status:** Draft

## Table of Contents
- [Feature Overview](#feature-overview)
- [Requirements](#requirements)
  - [SETTINGS-001: Daily New Cards Limit](#settings-001-daily-new-cards-limit)
  - [SETTINGS-002: Audio-Only Mode](#settings-002-audio-only-mode)
  - [SETTINGS-003: General Preferences](#settings-003-general-preferences)
- [User Flow](#user-flow)
- [Future Enhancements](#future-enhancements)
- [Related Documents](#related-documents)

---

## Feature Overview

Application Settings allow users to customize their learning experience and control app behavior. Settings persist across sessions and affect how review sessions work, media playback, and overall user experience.

**Key Benefits:**
- Personalized learning pace
- Bandwidth control with audio-only mode
- Flexible app behavior
- Settings persistence

---

## Requirements

### SETTINGS-001: Daily New Cards Limit

**Priority:** High  
**Status:** Not Started

**Description:**  
Allow users to specify the maximum number of new (never-reviewed) cards they want to learn per day. This prevents overwhelming users with too many new cards and allows them to control their learning pace.

**Acceptance Criteria:**
- Settings screen with "New Cards Per Day" configuration
- Input field accepts integers 0-999
- Default value: 20 cards per day
- Setting persists across app restarts
- When starting a review session:
  - Query includes both due cards (review) and new cards
  - Limit new cards to configured daily maximum
  - Prioritize due cards over new cards
  - Track how many new cards have been studied today
  - Reset count at midnight (device timezone)
- Display in dashboard:
  - "X new cards remaining today" (e.g., "15 new cards remaining")
  - "New cards: 0 remaining (limit reached for today)"
- Handle edge cases:
  - Value of 0 = no new cards (review only mode)
  - Empty/invalid input = use default value
  - Daily count resets properly across timezones

**Business Rules:**
- New card: `repetitions == 0` (never studied before)
- Due card: `nextReviewDate <= now` and `repetitions > 0`
- Daily count tracks cards that transition from new to learning state

**Implementation Notes:**
```dart
// Determine what counts as "new" vs "due review"
bool isNewCard(Flashcard card) {
  return card.repetitions == 0;
}

bool isDueForReview(Flashcard card) {
  return card.nextReviewDate.isBefore(DateTime.now()) && 
         card.repetitions > 0;
}

// Get cards for session respecting daily limit
Future<List<Flashcard>> getSessionCards() async {
  final dueCards = await getDueCards();
  final newCardsStudiedToday = await getNewCardsStudiedCount();
  final newCardsLimit = settings.newCardsPerDay;
  final newCardsRemaining = newCardsLimit - newCardsStudiedToday;
  
  if (newCardsRemaining > 0) {
    final newCards = await getNewCards(limit: newCardsRemaining);
    return [...dueCards, ...newCards];
  }
  
  return dueCards;
}
```

**Related User Stories:** [Story 5.1: Configure App Settings](../../user_stories/user_stories.md#story-51-configure-app-settings)

---

### SETTINGS-002: Audio-Only Mode

**Priority:** High  
**Status:** Not Started

**Description:**  
Allow users to collapse the YouTube video player and play audio only. This saves bandwidth, reduces distractions, and extends battery life on mobile devices.

**Acceptance Criteria:**
- Settings screen with "Audio-Only Mode" toggle
- Default state: OFF (video visible)
- When audio-only mode is enabled:
  - YouTube player collapses to minimal UI
  - Video is hidden (black screen or placeholder)
  - Audio continues playing normally
  - Playback controls remain accessible (play/pause)
  - Show compact player bar with:
    - Song title
    - Play/pause button
    - Current timestamp / duration
    - Expand button (option to show video)
- When audio-only mode is disabled:
  - Full YouTube player visible
  - Video plays normally
- Setting persists across sessions
- Can toggle during active session (doesn't interrupt playback)
- Works with custom start timestamps

**Design Notes:**
- Consider showing album art placeholder when video is hidden
- Audio controls should remain easily accessible
- Transition between audio/video modes should be smooth

**Technical Implementation:**
```dart
// Option 1: Hide video container, keep audio
YoutubePlayer(
  controller: _controller,
  showVideoProgressIndicator: true,
  // When audio-only mode enabled:
  aspectRatio: audioOnlyMode ? 0.0 : 16/9,  // Collapse to minimal height
);

// Option 2: Use iframe player's audio-only controls
// Or minimize video container height to show only controls
```

**Related User Stories:** [Story 5.1: Configure App Settings](../../user_stories/user_stories.md#story-51-configure-app-settings)

---

### SETTINGS-003: General Preferences

**Priority:** Medium  
**Status:** Not Started

**Description:**  
Additional application settings for general preferences and behavior customization.

**Acceptance Criteria:**
- **Theme Selection:**
  - Light mode
  - Dark mode
  - System default (follows device setting)
- **Auto-Play Behavior:**
  - Auto-play video when card appears (default: ON)
  - Manual play (user must tap play button)
- **Notification Settings:**
  - Daily reminder for reviews (default: OFF)
  - Reminder time selection (if enabled)
- **App Information:**
  - Version number
  - About page
  - Privacy policy link
  - Terms of service link
- Settings organized in sections:
  - Learning (new cards limit, auto-play)
  - Media (audio-only mode)
  - Appearance (theme)
  - Notifications
  - About

**Future Extensions:**
- SRS parameter customization (advanced users)
- Language selection
- Card sorting preferences
- Export/import settings

---

## User Flow

### Configuring New Cards Limit

```
1. User opens Settings screen
   ↓
2. Navigates to "Learning" section
   ↓
3. Taps "New Cards Per Day" field
   ↓
4. Enters desired number (e.g., 10)
   ↓
5. Taps "Save" or automatic save on field blur
   ↓
6. Confirmation: "Settings saved"
   ↓
7. User returns to Dashboard
   ↓
8. Dashboard shows "10 new cards remaining today"
   ↓
9. User starts review session
   ↓
10. Session includes up to 10 new cards + all due cards
```

### Enabling Audio-Only Mode

```
1. User opens Settings screen
   ↓
2. Navigates to "Media" section
   ↓
3. Toggles "Audio-Only Mode" switch to ON
   ↓
4. Setting saved immediately
   ↓
5. User starts review session
   ↓
6. YouTube player appears collapsed:
   - No video visible
   - Audio plays automatically
   - Compact control bar shown
   ↓
7. User can optionally tap "Expand" to see video temporarily
   ↓
8. Video collapses again when moving to next card
```

---

## Future Enhancements

**Potential Subdivisions (Detailed Spec Phase):**

#### SETTINGS-001: Daily New Cards Limit
- `SETTINGS-001-F01`: Settings UI for new cards configuration
- `SETTINGS-001-F02`: Track daily new card count
- `SETTINGS-001-F03`: Reset counter at midnight
- `SETTINGS-001-F04`: Modify session query to respect limit
- `SETTINGS-001-F05`: Dashboard display of remaining new cards

#### SETTINGS-002: Audio-Only Mode
- `SETTINGS-002-F01`: Settings toggle for audio-only mode
- `SETTINGS-002-F02`: Collapse video player UI
- `SETTINGS-002-F03`: Compact audio control bar
- `SETTINGS-002-F04`: Expand/collapse controls during session
- `SETTINGS-002-F05`: Persist setting across sessions

#### SETTINGS-003: General Preferences
- `SETTINGS-003-F01`: Theme selection (light/dark/system)
- `SETTINGS-003-F02`: Auto-play toggle
- `SETTINGS-003-F03`: Notification preferences
- `SETTINGS-003-F04`: Settings persistence layer
- `SETTINGS-003-F05`: Settings screen UI layout

**Advanced Features (Phase 3+):**
- **Custom SRS Parameters:** Allow users to adjust ease factor, intervals
- **Study Goals:** Set daily/weekly review targets
- **Achievement System:** Badges for streak milestones
- **Study Session Customization:** Choose session length, card mix

---

## Related Documents

**Requirements:**
- [DUEQUEUE - Due Queue Management](DUEQUEUE.md) - Session behavior affected by new cards limit
- [FLASHSYS - Flashcard System](FLASHSYS.md) - Media player affected by audio-only mode
- [SRS - Spaced Repetition System](SRS.md) - Core algorithm settings

**User Stories:**
- [Epic 5: Settings & Data Management](../../user_stories/user_stories.md#epic-5-settings--data-management)
- [Story 5.1: Configure App Settings](../../user_stories/user_stories.md#story-51-configure-app-settings)

**Implementation:**
- Settings stored in SharedPreferences or Isar
- Reactive architecture: settings changes propagate to affected components
- Settings screen uses standard Flutter components

---

## Test References

**Test Coverage Requirements:**
- Unit tests: Settings model, persistence, validation
- Integration tests: Settings affect session behavior, daily reset logic
- UI tests: Settings screen interactions, toggle states

**Example Test Cases:**
```dart
// SETTINGS-001: Daily new cards limit
test('should limit new cards to configured daily maximum', () async {
  // Given: 30 new cards exist, limit set to 10, 5 already studied today
  // When: User starts review session
  // Then: Session includes max 5 new cards (10 - 5 = 5 remaining)
});

test('should reset daily new card count at midnight', () async {
  // Given: 20 new cards studied today, limit = 20
  // When: Clock passes midnight
  // Then: Daily count resets to 0, new cards available again
});

// SETTINGS-002: Audio-only mode
test('should collapse video player when audio-only mode enabled', () async {
  // Given: Audio-only mode = ON
  // When: Card is displayed
  // Then: Video player is hidden, audio plays
});

test('should persist audio-only setting across sessions', () async {
  // Given: User enables audio-only mode
  // When: App is restarted
  // Then: Setting remains enabled
});
```
