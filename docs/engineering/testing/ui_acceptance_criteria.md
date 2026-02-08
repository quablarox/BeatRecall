# UI Acceptance Criteria - Gherkin Scenarios

**Version:** 1.0  
**Last Updated:** 2026-02-08  
**Purpose:** Detailed UI acceptance criteria in Gherkin format for Story 2.1 and 2.2

---

## Story 2.1: Listen and Recall (FLASHSYS-001, FLASHSYS-002)

### FLASHSYS-001: Dual-Sided Card Interface

#### Scenario: Display card front side with YouTube player
```gherkin
Given I am in a review session with due cards
When the first card appears
Then I should see the YouTube player
And I should see a "Show Answer" button
And I should NOT see the title or artist
And the YouTube player should be ready to play
```

#### Scenario: Flip card to reveal answer
```gherkin
Given I am viewing the front side of a flashcard
When I tap the "Show Answer" button
Then the card should flip with a smooth animation
And I should see the song title
And I should see the artist name
And I should see four rating buttons (Again, Hard, Good, Easy)
And the "Show Answer" button should disappear
```

#### Scenario: Flip card using keyboard shortcut (Spacebar)
```gherkin
Given I am viewing the front side of a flashcard
And I am on a platform with keyboard support
When I press the Spacebar key
Then the card should flip to show the answer
```

#### Scenario: Flip card using keyboard shortcut (Enter)
```gherkin
Given I am viewing the front side of a flashcard
And I am on a platform with keyboard support
When I press the Enter key
Then the card should flip to show the answer
```

#### Scenario: Visual card state indicator
```gherkin
Given I am viewing a flashcard
When the card is on the front side
Then there should be a visual indicator showing "front" state
When I flip to the back side
Then the visual indicator should change to show "back" state
```

#### Scenario: Responsive card layout on mobile
```gherkin
Given I am using the app on a mobile device
When I view a flashcard
Then the card should fit within the screen width
And the YouTube player should maintain 16:9 aspect ratio
And all interactive elements should be touch-friendly (min 48dp)
```

#### Scenario: Responsive card layout on desktop
```gherkin
Given I am using the app on a desktop device
When I view a flashcard
Then the card should be centered on screen
And the card should have a maximum width of 600px
And keyboard shortcuts should be displayed as hints
```

---

### FLASHSYS-002: YouTube Media Player

#### Scenario: Auto-play video from custom start time
```gherkin
Given I have a flashcard with start_at_seconds = 30
When the card front side appears
Then the YouTube player should load the video
And the video should start playing from second 30
And I should hear audio immediately
```

#### Scenario: Manual play control
```gherkin
Given the YouTube player has loaded
And auto-play is disabled
When I tap the play button
Then the video should start playing from the configured start time
```

#### Scenario: Pause video playback
```gherkin
Given the YouTube video is currently playing
When I tap the pause button
Then the video should pause
And the pause button should change to a play button
```

#### Scenario: Resume video playback after pause
```gherkin
Given I have paused the video at 45 seconds
When I tap the play button
Then the video should resume from second 45
```

#### Scenario: Video unavailable error handling
```gherkin
Given a flashcard has an invalid or removed YouTube video
When the card front side appears
Then I should see an error message "Video unavailable"
And I should see a "Retry" button
And I should see a "Skip Card" button
And the "Show Answer" button should still be accessible
```

#### Scenario: Network error handling
```gherkin
Given I have no internet connection
When a flashcard front side appears
Then I should see a network error message
And I should see a "Retry" button
And I should see advice to check internet connection
```

#### Scenario: Retry loading video after error
```gherkin
Given the YouTube player showed an error
When I tap the "Retry" button
Then the player should attempt to reload the video
And a loading spinner should appear
```

#### Scenario: Skip card with playback error
```gherkin
Given the YouTube player cannot load a video
When I tap the "Skip Card" button
Then the current card should be marked for later review
And the next card should appear
And I should see a confirmation "Card skipped"
```

#### Scenario: Player controls are accessible
```gherkin
Given I am viewing a flashcard front side
When I look at the YouTube player
Then I should see clearly visible play/pause controls
And the controls should be easy to tap (min 44x44 points)
And the controls should have sufficient contrast
```

#### Scenario: Video respects aspect ratio
```gherkin
Given I am viewing a YouTube video on the flashcard
When the video loads
Then the video should maintain its native aspect ratio
And there should be no distortion or stretching
And black bars should appear if necessary to maintain ratio
```

---

### FLASHSYS-003: Answer Rating (Part of Story 2.1)

#### Scenario: Display four rating buttons on card back
```gherkin
Given I have flipped a card to the back side
When the answer is revealed
Then I should see four rating buttons
And the buttons should be labeled: "Again", "Hard", "Good", "Easy"
And the buttons should be color-coded:
  | Button | Color  |
  | Again  | Red    |
  | Hard   | Orange |
  | Good   | Green  |
  | Easy   | Blue   |
```

#### Scenario: Display next review intervals
```gherkin
Given I am viewing the card back with rating buttons
When I look at each button
Then each button should show its next review interval
And "Again" should show "Soon" or "<10m"
And "Hard" should show interval in days (e.g., "4d")
And "Good" should show interval in days (e.g., "10d")
And "Easy" should show interval in days (e.g., "15d")
```

#### Scenario: Rate card as "Again"
```gherkin
Given I am viewing the back of a flashcard
When I tap the "Again" button
Then I should see a brief visual confirmation
And the next card should appear within 1 second
And the reviewed card should be rescheduled for review soon
```

#### Scenario: Rate card as "Good" with keyboard shortcut
```gherkin
Given I am viewing the back of a flashcard
And I am on a platform with keyboard support
When I press the "3" key
Then the card should be rated as "Good"
And the next card should appear
```

#### Scenario: Touch-friendly button size
```gherkin
Given I am viewing rating buttons on mobile
When I measure the button dimensions
Then each button should be at least 48dp x 48dp
And there should be adequate spacing between buttons (min 8dp)
```

#### Scenario: Button states (normal, pressed, disabled)
```gherkin
Given I am viewing rating buttons
When I interact with a button
Then the button should have visual feedback on press
And the button should show a pressed state
When I have already rated the card
Then all rating buttons should be disabled
And the disabled state should be visually distinct
```

---

## Story 2.2: Review Due Cards (DUEQUEUE-001, DUEQUEUE-002)

### DUEQUEUE-001: Due Cards Retrieval

#### Scenario: Display due cards count on dashboard
```gherkin
Given I have 15 cards due for review
When I open the app to the dashboard
Then I should see "15 cards due"
And the due count should be prominently displayed
And there should be a "Start Review" button
```

#### Scenario: No cards due message
```gherkin
Given I have no cards due for review
When I open the app to the dashboard
Then I should see "All caught up! 🎉"
And I should see when the next card is due
And the message should be encouraging
```

#### Scenario: Display next review time
```gherkin
Given I have no cards currently due
And my next card is due in 3 hours
When I view the dashboard
Then I should see "Next review in 3 hours"
```

---

### DUEQUEUE-002: Review Session

#### Scenario: Start review session with due cards
```gherkin
Given I have 23 cards due for review
When I tap the "Start Review" button
Then a review session should begin
And I should see the first flashcard
And I should see a progress indicator "Card 1 of 23"
And I should see a progress bar showing 0% complete
```

#### Scenario: Progress indicator updates after each card
```gherkin
Given I am in a review session with 10 cards
And I have reviewed 3 cards
When the 4th card appears
Then the progress should show "Card 4 of 10"
And the progress bar should show 30% complete (3/10)
```

#### Scenario: Smooth transition between cards
```gherkin
Given I have just rated a card as "Good"
When the next card loads
Then the transition should be smooth (fade or slide)
And the new card should appear within 500ms
And there should be no jarring jumps or flashes
```

#### Scenario: Display session completion summary
```gherkin
Given I have reviewed all 15 due cards
When I rate the last card
Then I should see a session summary screen
And the summary should show:
  | Metric                | Example Value |
  | Total cards reviewed  | 15           |
  | Again count          | 2            |
  | Hard count           | 3            |
  | Good count           | 8            |
  | Easy count           | 2            |
  | Total time           | 8m 32s       |
And I should see an encouraging message like "Great job! 🎉"
And I should see a "Finish" button
```

#### Scenario: Review more cards option when done
```gherkin
Given I have completed a review session
And more cards are now due
When I view the session summary
Then I should see a "Review More" button
When I tap "Review More"
Then a new review session should start with newly due cards
```

#### Scenario: Pause review session
```gherkin
Given I am in the middle of a review session
And I have reviewed 8 of 20 cards
When I tap the "Pause" button in the app bar
Then I should see a pause confirmation dialog
And the dialog should show "12 cards remaining"
When I tap "Pause Session"
Then I should return to the dashboard
And my session progress should be saved
```

#### Scenario: Resume paused review session
```gherkin
Given I paused a review session earlier
And I have 12 cards remaining
When I open the app
Then I should see a prompt "Resume your review session?"
And the prompt should show "12 cards remaining"
When I tap "Resume"
Then the review session should continue from where I left off
And I should see card 9 of 20
```

#### Scenario: Progress bar visual accuracy
```gherkin
Given I am in a review session with 20 cards
When I complete card 5
Then the progress bar should fill to 25% (5/20)
And the fill color should be visually distinct (e.g., green)
And the empty portion should be a lighter shade
```

#### Scenario: Handle single card due
```gherkin
Given I have only 1 card due for review
When I start a review session
Then the progress should show "Card 1 of 1"
And the progress bar should show 0% initially
When I rate the card
Then the session summary should show immediately
```

#### Scenario: Display estimated time remaining
```gherkin
Given I am in a review session
And my average time per card is 20 seconds
And I have 10 cards remaining
When I view the progress indicator
Then I should see "~3m remaining" (10 * 20s = 200s ≈ 3m)
And the estimate should update after each card
```

#### Scenario: Encouraging completion message
```gherkin
Given I have completed a review session
When I view the session summary
Then I should see an encouraging message
And the message should vary based on performance:
  | Performance     | Message Example                    |
  | All Easy/Good   | "Perfect! You're on fire! 🔥"     |
  | Mixed           | "Great job! Keep it up! 🎉"       |
  | Many Again      | "Good effort! Practice makes perfect! 💪" |
```

#### Scenario: Session summary with confetti animation
```gherkin
Given I have successfully completed a review session
When the session summary appears
Then I should see a brief confetti animation (optional)
And the animation should be celebratory but not distracting
And the animation should complete within 2 seconds
```

#### Scenario: Return to dashboard from session
```gherkin
Given I am viewing the session summary
When I tap the "Finish" button
Then I should return to the dashboard
And the dashboard should show updated statistics
And the due cards count should be 0 (if all reviewed)
```

---

## Cross-Cutting UI Scenarios

### Accessibility

#### Scenario: Screen reader support for card content
```gherkin
Given I am a user with screen reader enabled
When a flashcard appears
Then the screen reader should announce the card state
And it should read "Front side, tap to reveal answer"
When I flip the card
Then it should read "Answer: [Title] by [Artist]"
```

#### Scenario: High contrast mode support
```gherkin
Given I have enabled high contrast mode on my device
When I view flashcards and buttons
Then all colors should meet WCAG AAA contrast ratios
And text should be clearly readable
```

#### Scenario: Font scaling support
```gherkin
Given I have set my device font size to "Large"
When I view flashcard content
Then all text should scale appropriately
And UI elements should not overlap or clip
And buttons should remain touch-friendly
```

---

### Performance

#### Scenario: Card transition performance
```gherkin
Given I am reviewing cards in a session
When I rate a card and move to the next
Then the transition should complete within 500ms
And there should be no visible lag or stuttering
And the YouTube player should preload efficiently
```

#### Scenario: Smooth animations at 60 FPS
```gherkin
Given I am viewing card flip animations
When the animation plays
Then it should run at 60 FPS
And there should be no dropped frames
And the animation should feel fluid and responsive
```

---

### Error States

#### Scenario: Display error state when database is unavailable
```gherkin
Given the database connection has failed
When I try to start a review session
Then I should see an error message "Unable to load cards"
And I should see a "Retry" button
And I should see advice to restart the app
```

#### Scenario: Handle empty due queue gracefully
```gherkin
Given I begin a review session
And due cards query returns empty (race condition)
When the session loads
Then I should see "No cards to review right now"
And I should not see an error or crash
And I should see a "Return to Dashboard" button
```

---

## Notes for Implementation

**Priority Order:**
1. **FLASHSYS-001 & 002** (Card display + YouTube player) - Core functionality
2. **DUEQUEUE-001** (Due cards retrieval) - Needed for any session
3. **FLASHSYS-003** (Rating buttons) - Completes the review loop
4. **DUEQUEUE-002** (Session management) - Polish and UX

**Testing Approach:**
- Widget tests for UI components
- Integration tests for user flows
- Golden tests for visual regression
- Manual testing on iOS and Android

**Design System Reference:**
- Colors: See `docs/product/design/design_system.md`
- Typography: Material Design 3 standard scales
- Spacing: 8dp grid system
- Animations: Material motion guidelines

