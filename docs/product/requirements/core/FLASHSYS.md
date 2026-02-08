# FLASHSYS - Flashcard System

**Feature ID:** `FLASHSYS`  
**Version:** 1.0  
**Last Updated:** 2026-02-07  
**Status:** Draft

## Table of Contents
- [Feature Overview](#feature-overview)
- [Requirements](#requirements)
  - [FLASHSYS-001: Dual-Sided Card Interface](#flashsys-001-dual-sided-card-interface)
  - [FLASHSYS-002: YouTube Media Player](#flashsys-002-youtube-media-player)
  - [FLASHSYS-003: Answer Rating](#flashsys-003-answer-rating)
  - [FLASHSYS-004: Answer Input (Optional)](#flashsys-004-answer-input-optional)
- [User Flow](#user-flow)
- [Future Enhancements](#future-enhancements)
- [Test References](#test-references)
- [Related Documents](#related-documents)

---

## Feature Overview

The Flashcard System provides an interactive interface for reviewing music flashcards. Each card has a front side (question) that plays a YouTube audio/video clip and a back side (answer) that reveals the song title and artist. Users rate their recall performance to inform the spaced repetition algorithm.

**Key Benefits:**
- Intuitive dual-sided card interface
- Integrated YouTube media playback
- Quick performance rating
- Keyboard shortcuts for efficiency

---

## Requirements

### FLASHSYS-001: Dual-Sided Card Interface

**Priority:** High  
**Status:** Not Started

**Description:**  
Display flashcard with front (question) and back (answer) sides. The front side presents the learning challenge (audio/video), while the back side reveals the correct answer.

**Acceptance Criteria:**
- Front side plays YouTube audio/video automatically or on user action
- Back side reveals title and artist information
- Smooth transition between sides (flip animation or fade)
- Visual indicator of card state (front/back)
- Support for keyboard shortcuts:
  - `Spacebar`: Flip card
  - `Enter`: Flip card (alternative)
- Card content is responsive to different screen sizes
- Touch-friendly tap area for card flip

**Design Notes:**
- Consider card flip animation (3D rotation effect)
- Front side should have clear "Show Answer" button
- Back side should clearly display metadata

---

### FLASHSYS-002: YouTube Media Player

**Priority:** High  
**Status:** Not Started

**Description:**  
Integrate YouTube player for audio/video playback using the `youtube_player_flutter` package.

**Acceptance Criteria:**
- Play YouTube videos using `youtube_player_flutter` package
- Support custom start timestamp (`start_at_seconds` field)
- Control playback (play, pause, stop)
- Handle network errors gracefully:
  - Display error message if video unavailable
  - Provide retry option
  - Allow user to skip card if playback fails
- Support audio-only mode (optional for bandwidth saving)
- Player controls are accessible and intuitive
- Video respects aspect ratio (typically 16:9)

**Technical Notes:**
- Use `youtube_player_flutter: ^8.0.0` or later
- Extract YouTube video ID from URL
- Handle both `youtube.com` and `youtu.be` URL formats

**Dependencies:**
- Requires internet connectivity
- Requires valid YouTube video ID

---

### FLASHSYS-003: Answer Rating

**Priority:** High  
**Status:** Not Started

**Description:**  
Allow users to rate their recall performance with four options: Again, Hard, Good, Easy. Each rating triggers SM-2 algorithm calculation for next review interval.

**Acceptance Criteria:**
- Four rating buttons displayed on card back:
  - **Again (0):** Did not recall
  - **Hard (1):** Recalled with difficulty
  - **Good (3):** Recalled correctly
  - **Easy (4):** Recalled easily
- Color-coded buttons for easy identification:
  - Again: Red (#F44336)
  - Hard: Orange (#FF9800)
  - Good: Green (#4CAF50)
  - Easy: Blue (#2196F3)
- **Display next review interval for each option:**
  - Show interval below each rating button (e.g., "Soon", "4d", "10d", "15d")
  - Calculate interval using SRS-001 before user rates
  - Format intervals clearly:
    - "<1m" = Less than 1 minute (will re-appear this session)
    - "<1h" = Less than 1 hour
    - "Xh" = Hours (e.g., "3h")
    - "Xd" = Days (e.g., "4d")
    - "Xw" = Weeks (e.g., "2w")
    - "Xmo" = Months (e.g., "3mo")
  - **Display absolute date for longer intervals:** "Jan 15, 2026" for intervals >30 days
  - Interval display helps users make informed rating decisions
- **Keyboard shortcuts for quick rating:**
  - `1` or `A`: Again
  - `2` or `H`: Hard
  - `3` or `G`: Good
  - `4` or `E`: Easy
- Touch-friendly button size (minimum 44x44 points per iOS HIG, 48x48dp per Material Design)
- Immediate feedback after rating (visual confirmation, move to next card)

**Dependencies:**
- Integrates with `SRS-001` for interval calculation
- Updates card via `SRS-002` review scheduling

---

### FLASHSYS-004: Answer Input (Optional)

**Priority:** Low  
**Status:** Not Started

**Description:**  
Allow users to type their answer (title and artist) before revealing the correct answer. This provides active recall practice and can auto-suggest rating.

**Acceptance Criteria:**
- Optional text input fields for title and artist
- Fuzzy matching validation (allow minor typos):
  - Use Levenshtein distance or similar algorithm
  - Case-insensitive matching
  - Accept answers with ≥80% similarity
- Visual feedback on correctness:
  - Green checkmark for correct
  - Red X for incorrect
  - Yellow warning for partial match
- Auto-suggest rating based on match quality:
  - Exact match → suggest "Easy" or "Good"
  - Partial match → suggest "Hard"
  - No match → suggest "Again"
- Can be skipped to directly reveal answer
- User setting to enable/disable answer input mode

**Notes:**
- Deferred to Phase 2 if time constraints exist
- Fuzzy matching enhances user experience (e.g., "Beatles" vs "The Beatles")

---

## User Flow

```
1. Card appears (front side)
   ↓
2. YouTube player loads and plays from startAtSeconds
   ↓
3. User listens and tries to recall title/artist
   ↓
4. User taps card or presses Spacebar to flip
   ↓
5. Card reveals back side (title, artist)
   ↓
6. User rates performance (Again/Hard/Good/Easy)
   ↓
7. System calculates next review interval (SRS-001)
   ↓
8. Card is scheduled for next review (SRS-002)
   ↓
9. Next card appears (repeat)
```

---

## Future Enhancements

**Potential Subdivisions (Detailed Spec Phase):**

#### FLASHSYS-001: Dual-Sided Card Interface
- `FLASHSYS-001-F01`: Render front side UI
- `FLASHSYS-001-F02`: Render back side UI
- `FLASHSYS-001-F03`: Implement card flip animation
- `FLASHSYS-001-F04`: Handle keyboard shortcuts (Spacebar, Enter)
- `FLASHSYS-001-F05`: Responsive layout for different screen sizes

#### FLASHSYS-002: YouTube Media Player
- `FLASHSYS-002-F01`: Initialize YouTube player with video ID
- `FLASHSYS-002-F02`: Start playback from custom timestamp
- `FLASHSYS-002-F03`: Implement play/pause controls
- `FLASHSYS-002-F04`: Handle network errors
- `FLASHSYS-002-F05`: Audio-only mode toggle

#### FLASHSYS-003: Answer Rating
- `FLASHSYS-003-F01`: Render rating buttons with color coding
- `FLASHSYS-003-F02`: Display next interval preview
- `FLASHSYS-003-F03`: Handle keyboard shortcuts (1-4, A/H/G/E)
- `FLASHSYS-003-F04`: Process rating and trigger SRS calculation
- `FLASHSYS-003-F05`: Visual feedback and transition to next card

#### FLASHSYS-004: Answer Input (Optional)
- `FLASHSYS-004-F01`: Render input fields for title and artist
- `FLASHSYS-004-F02`: Implement fuzzy matching algorithm
- `FLASHSYS-004-F03`: Visual feedback on correctness
- `FLASHSYS-004-F04`: Auto-suggest rating based on match
- `FLASHSYS-004-F05`: User setting to enable/disable input mode

---

## Test References

**Gherkin Scenario Examples:**

```gherkin
@FLASHSYS-001
Scenario: Display card front side with YouTube player
  Given a flashcard with YouTube URL and title "Bohemian Rhapsody"
  When I open the card for review
  Then I should see the front side
  And the YouTube player should be visible
  And the title should be hidden

@FLASHSYS-001
Scenario: Flip card to reveal answer
  Given I am viewing the front side of a card
  When I press the Spacebar key
  Then the card should flip to the back side
  And I should see the title "Bohemian Rhapsody"
  And I should see the artist "Queen"

@FLASHSYS-003
Scenario: Rate card as "Good" using keyboard shortcut
  Given I am viewing the back side of a card
  When I press the "3" key
  Then the card should be rated as "Good"
  And the next review interval should be calculated
  And the next card should appear

@FLASHSYS-002
Scenario: Handle YouTube playback error
  Given a flashcard with an invalid YouTube URL
  When I open the card for review
  Then I should see an error message "Video unavailable"
  And I should see a "Retry" button
  And I should see a "Skip Card" button
```

---

## Related Documents

- [SRS.md](SRS.md) - Algorithm for calculating intervals based on ratings
- [DUEQUEUE.md](DUEQUEUE.md) - Managing review session flow
- [Glossary](../../GLOSSARY.md) - Domain terminology (Rating, YouTube ID, Start Timestamp, etc.)
- [Architecture](../../../engineering/architecture/architecture.md) - Presentation layer implementation
- [User Stories](../../user_stories/user_stories.md) - Story 3.1, 3.2
