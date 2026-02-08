# User Stories - BeatRecall

## Document Information
- **Version:** 2.0
- **Last Updated:** 2026-02-07
- **Status:** Draft

## Table of Contents
- [Purpose](#purpose)
- [Epic Organization](#epic-organization)
- **MVP (Phase 1 - Weeks 3-8):**
  - [Epic 1: Card Management](#epic-1-card-management)
  - [Epic 2: Core Learning Experience](#epic-2-core-learning-experience)
  - [Epic 3: Progress Tracking](#epic-3-progress-tracking)
- **Post-MVP (Phase 2 - Weeks 9-14):**
  - [Epic 4: Enhanced Learning Features](#epic-4-enhanced-learning-features)
  - [Epic 5: Settings & Data Management](#epic-5-settings--data-management)
- **Future (Phase 3+):**
  - [Epic 6: Advanced Features](#epic-6-advanced-features)

---

## Purpose

This document describes features from the **user's perspective**, focusing on the value delivered and user needs. For detailed technical specifications and acceptance criteria, refer to the [Functional Requirements](../requirements/README.md).

---

## Epic Organization

Epics are organized by **implementation phase** to align with the [Development Roadmap](../roadmap/roadmap.md):

1. **Epic 1-3:** MVP features (Phase 1, Weeks 3-8)
2. **Epic 4-5:** Enhanced features (Phase 2, Weeks 9-14)
3. **Epic 6:** Future features (Phase 3+)

**Rationale:** Card management comes first because users need cards before they can review them. This matches the technical implementation order defined in the roadmap.

---

## Epic 1: Card Management
**Phase:** MVP (Sprint 2) | **Priority:** High  
**Goal:** Enable users to build and manage their flashcard library

### Story 1.1: Import Cards from CSV
**As a** user with an existing list of songs  
**I want to** import multiple cards from a CSV file  
**So that** I can build my library quickly

**Related Requirements:** [CARDMGMT-001](../requirements/core/CARDMGMT.md#cardmgmt-001-csv-import-)

**Priority:** High | **Story Points:** 5  
**Sprint:** Sprint 2 (Week 3-4)

**Acceptance:**
- Can select CSV file from device
- CSV format validated (youtube_url, start_at_seconds)
- Duplicate detection and handling
- Import summary shows success/failures
- All valid cards added to library

---

### Story 1.2: Add a Song Manually
**As a** user  
**I want to** add a new song to my collection  
**So that** I can practice specific songs not in my CSV file

**Related Requirements:** [CARDMGMT-002](../requirements/core/CARDMGMT.md#cardmgmt-002-manual-card-creation)

**Priority:** High | **Story Points:** 5  
**Sprint:** Sprint 2 (Week 3-4)

**Acceptance:**
- Can enter YouTube URL
- Title and Artist fields available
- Form validation works
- Card saved to database
- Success message displayed

---

### Story 1.3: Browse My Song Library
**As a** user  
**I want to** view all my saved songs in one place  
**So that** I can see my collection and manage it

**Related Requirements:** [CARDMGMT-005](../requirements/core/CARDMGMT.md#cardmgmt-005-card-search-and-filter)

**Priority:** High | **Story Points:** 5  
**Sprint:** Sprint 2 (Week 3-4)

**Acceptance:**
- Library shows all cards in list
- Can search by title or artist
- Can tap card to view details
- Shows card count
- Can navigate to add/edit/delete

---

### Story 1.4: Edit a Song Card
**As a** user  
**I want to** edit the details of an existing card  
**So that** I can correct mistakes or update information

**Related Requirements:** [CARDMGMT-003](../requirements/core/CARDMGMT.md#cardmgmt-003-card-editing)

**Priority:** Medium | **Story Points:** 3  
**Sprint:** Sprint 2 (Week 3-4)

**Acceptance:**
- Can open edit screen from library
- Form pre-filled with current values
- Can update title, artist, YouTube URL
- Changes saved to database
- Success confirmation shown

---

### Story 1.5: Delete a Song Card
**As a** user  
**I want to** remove songs I no longer want to practice  
**So that** my library stays relevant

**Related Requirements:** [CARDMGMT-004](../requirements/core/CARDMGMT.md#cardmgmt-004-card-deletion)

**Priority:** Medium | **Story Points:** 2  
**Sprint:** Sprint 2 (Week 3-4)

**Acceptance:**
- Can delete from library or detail screen
- Confirmation dialog appears
- Card removed from database
- Review history preserved (optional)
- Success message displayed

---

## Epic 2: Core Learning Experience
**Phase:** MVP (Sprint 3-4) | **Priority:** High  
**Goal:** Enable users to review flashcards using the SRS algorithm

### Story 2.1: Listen and Recall
**As a** user in a review session  
**I want to** hear a song and try to recall its title and artist  
**So that** I can test my music knowledge

**Related Requirements:** [FLASHSYS-001](../requirements/core/FLASHSYS.md#flashsys-001-dual-sided-card-interface), [FLASHSYS-002](../requirements/core/FLASHSYS.md#flashsys-002-youtube-media-player)

**Priority:** High | **Story Points:** 8  
**Sprint:** Sprint 3 (Week 5-6)

**Acceptance:**
- YouTube video plays on card front
- Can play/pause video
- Can reveal answer (flip to back)
- Back shows title and artist
- Smooth transition between front/back

---

### Story 2.2: Review Due Cards
**As a** pub quiz enthusiast  
**I want to** review songs that are due for practice  
**So that** I can maintain my music recognition skills

**Related Requirements:** [DUEQUEUE-001](../requirements/core/DUEQUEUE.md#duequeue-001-due-cards-retrieval), [DUEQUEUE-002](../requirements/core/DUEQUEUE.md#duequeue-002-review-session)

**Priority:** High | **Story Points:** 5  
**Sprint:** Sprint 3-4 (Week 5-8)

**Acceptance:**
- Dashboard shows due card count
- Can start review session
- Only due cards appear (nextReviewDate <= now)
- Cards sorted by most overdue first
- Progress indicator shows cards remaining
- Session summary at end

---

### Story 2.3: Rate My Performance
**As a** user reviewing a card  
**I want to** rate how well I remembered the song  
**So that** the app knows when to show it to me again

**Related Requirements:** [SRS-001](../requirements/core/SRS.md#srs-001-sm-2-algorithm-implementation), [SRS-002](../requirements/core/SRS.md#srs-002-review-scheduling), [FLASHSYS-003](../requirements/core/FLASHSYS.md#flashsys-003-answer-rating)

**Priority:** High | **Story Points:** 5  
**Sprint:** Sprint 4 (Week 7-8)

**Acceptance:**
- Four rating buttons: Again, Hard, Good, Easy
- Buttons color-coded and clearly labeled
- Next interval displayed after rating
- Card rescheduled according to SM-2 algorithm
- Review logged in database
- Automatically loads next card

---

## Epic 3: Progress Tracking
**Phase:** MVP (Sprint 4) | **Priority:** Medium  
**Goal:** Show users their learning progress and motivate continued use

### Story 3.1: View My Statistics
**As a** user  
**I want to** see my learning progress and statistics  
**So that** I can stay motivated and track my improvement

**Related Requirements:** [DASHBOARD-001](../requirements/additional/DASHBOARD.md#dashboard-001-overview-display), [SRS-003](../requirements/core/SRS.md#srs-003-performance-tracking)

**Priority:** Medium | **Story Points:** 5  
**Sprint:** Sprint 4 (Week 7-8)

**Acceptance:**
- Dashboard shows key metrics:
  - Due cards count
  - Total cards count
  - Success rate (%)
  - Current streak (days)
- Statistics update in real-time
- Quick "Start Review" button visible
- Visual design motivates learning

---

## Epic 4: Enhanced Learning Features
**Phase:** Post-MVP (Sprint 5-6) | **Priority:** Medium  
**Goal:** Add quality-of-life features to improve learning experience

### Story 4.1: Auto-Fetch Song Details
**As a** user adding a song  
**I want to** have the title and artist filled automatically  
**So that** I save time when creating cards

**Related Requirements:** [FR-2.3.1](../requirements/02_phase2.md#fr-231-youtube-metadata-fetch)

**Priority:** Medium | **Story Points:** 8  
**Sprint:** Sprint 5 (Week 9-10)

**Acceptance:**
- YouTube API integration active
- Metadata fetched on URL paste
- Title auto-filled from metadata
- Artist extracted if available
- Preview before saving
- Error handling for API failures

---

### Story 4.2: Type My Answer (Optional)
**As a** user who wants more challenge  
**I want to** type my answer before revealing the correct one  
**So that** I can test my active recall more rigorously

**Related Requirements:** [FLASHSYS-004](../requirements/core/FLASHSYS.md#flashsys-004-answer-input-optional), [FR-2.2.1](../requirements/02_phase2.md#fr-221-answer-validation)

**Priority:** Low | **Story Points:** 8  
**Sprint:** Sprint 6 (Week 11-12) - Optional

**Acceptance:**
- Optional text input mode
- Can toggle in settings
- Fuzzy matching validates answer
- Visual feedback for correct/incorrect
- Can still flip to see answer
- Works with keyboard on all platforms

---

## Epic 5: Settings & Data Management
**Phase:** Post-MVP (Sprint 7) | **Priority:** Medium  
**Goal:** Give users control over app behavior and data safety

### Story 5.1: Configure App Settings
**As a** user  
**I want to** customize how the app works  
**So that** it fits my learning style and preferences

**Related Requirements:** [FR-3.2.1](../requirements/03_additional.md#fr-321-application-settings)

**Priority:** Medium | **Story Points:** 5  
**Sprint:** Sprint 7 (Week 12-13)

**Acceptance:**
- Settings screen accessible
- Can configure:
  - Theme (light/dark)
  - SRS parameters (optional)
  - Notification preferences
  - Auto-play behavior
- Settings persist across sessions
- Changes applied immediately

---

### Story 5.2: Backup My Data
**As a** user  
**I want to** export and import my card collection  
**So that** I can back up my data or transfer it to another device

**Related Requirements:** [FR-3.2.2](../requirements/03_additional.md#fr-322-data-management)

**Priority:** Low | **Story Points:** 8  
**Sprint:** Sprint 7 (Week 12-13)

**Acceptance:**
- Can export database to file
- Export includes all cards and review history
- Can import from backup file
- Import validates file format
- Duplicate handling during import
- Success/error messages clear

---

## Epic 6: Advanced Features
**Phase:** Future (Sprint 9+) | **Priority:** Low  
**Goal:** Add advanced features based on user feedback and demand

### Story 6.1: Import From Playlist
**As a** user with a large collection  
**I want to** import multiple songs from a YouTube playlist  
**So that** I can build my library quickly

**Related Requirements:** [FR-2.4.1](../requirements/02_phase2.md#fr-241-bulk-import-from-playlist)

**Priority:** Low | **Story Points:** 13  
**Sprint:** Sprint 9-10 (Week 15-17)

**Acceptance:**
- Can paste YouTube playlist URL
- App fetches all videos in playlist
- Preview list before import
- Can select/deselect videos
- Batch import with progress indicator
- Error handling for private/deleted videos

---

### Story 6.2: Enhanced Statistics & Analytics
**As a** user  
**I want to** see detailed analytics of my learning  
**So that** I can understand my progress patterns

**Related Requirements:** Phase 3 feature (not yet specified)

**Priority:** Low | **Story Points:** 8  
**Sprint:** Sprint 11 (Week 18-19)

**Acceptance:**
- Charts showing progress over time
- Review history timeline
- Performance trends
- Most difficult cards
- Most reviewed cards
- Export statistics

---

### Story 6.3: Quick Start Tutorial
**As a** new user  
**I want to** see how the app works  
**So that** I can start using it effectively right away

**Related Requirements:** New feature (UX enhancement)

**Priority:** Low | **Story Points:** 5  
**Sprint:** Sprint 12 (Week 20-21)

**Acceptance:**
- First-time user sees onboarding
- Interactive tutorial for key features
- Can skip or complete tutorial
- Tutorial accessible from settings
- Clear call-to-action at each step

---

### Story 6.4: Handle Network Issues
**As a** user with unstable internet  
**I want to** see clear messages when things go wrong  
**So that** I understand what's happening and what to do

**Related Requirements:** [Non-Functional Requirements](../../engineering/non_functional/non_functional_requirements.md) - Error Handling & Network Resilience

**Priority:** Medium | **Story Points:** 5  
**Sprint:** Sprint 12 (Week 20-21)

**Acceptance:**
- Clear error messages for no connection
- Graceful degradation (cached content works)
- Retry mechanism for failed requests
- Offline indicator visible
- Help text explains limitations

---

### Story 6.5: Smooth Animations
**As a** user  
**I want to** experience smooth and polished animations  
**So that** the app feels professional and enjoyable to use

**Related Requirements:** [Non-Functional Requirements](../../engineering/non_functional/non_functional_requirements.md#12-ui-performance)

**Priority:** Low | **Story Points:** 3  
**Sprint:** Sprint 12 (Week 20-21)

**Acceptance:**
- Card flip animation smooth
- Screen transitions animated
- Button feedback immediate
- 60 FPS maintained
- No jank or stuttering

---

### Story 6.6: Offline Mode
**As a** user who travels frequently  
**I want to** review cards without an internet connection  
**So that** I can practice anywhere

**Related Requirements:** [FR-4.3.1](../requirements/04_future.md#fr-431-offline-mode-with-cached-audio) (Future consideration)

**Priority:** Low | **Story Points:** 13  
**Sprint:** Future (Phase 4+)

**Acceptance:**
- Can cache audio for cards
- Cached cards work offline
- Cache management (size limits)
- Manual download option
- Clear offline/online status
- Review sessions work fully offline

---

### Story 6.7: Share Playlists
**As a** user who enjoys the app  
**I want to** share my card collection with friends  
**So that** they can learn the same songs

**Related Requirements:** [FR-4.2.1](../requirements/04_future.md#fr-421-collaborative-playlists) (Future consideration)

**Priority:** Low | **Story Points:** 8  
**Sprint:** Future (Phase 4+)

**Acceptance:**
- Can export card collection to share format
- Share via link or file
- Friends can import shared collection
- Import validates data
- Credit to original creator visible

---

## How to Use This Document

1. **User Stories** provide the "why" and "what" from a user perspective
2. **Functional Requirements** provide the "how" with detailed acceptance criteria
3. **Roadmap** defines the implementation schedule by sprint
4. When implementing a story, always consult the linked requirements for technical details
5. If a story doesn't have a corresponding requirement, add it to functional requirements first

**Epic Organization:**
- Epics are organized by **implementation phase** to match the roadmap
- This ensures logical build order: Cards → Learning → Tracking → Enhancements
- Sprint assignments guide development priorities

---

## Story Template for New Features

**As a** [type of user]  
**I want to** [action/goal]  
**So that** [benefit/value]

**Related Requirements:** [REQ-ID](../requirements/README.md)

**Priority:** [High/Medium/Low] | **Story Points:** [1-13]  
**Sprint:** Sprint X (Week Y-Z)

**Acceptance:**
- Criterion 1
- Criterion 2
- Criterion 3

---

## Notes on Story Points

- **1-2:** Simple change, < 1 day
- **3-5:** Standard feature, 1-3 days
- **8:** Complex feature, 3-5 days
- **13:** Very complex, 1-2 weeks
- **21+:** Epic should be broken down into smaller stories

---

*Last updated: 2026-02-08 - Reorganized epics to match roadmap implementation order*
**As a** pub quiz enthusiast  
**I want to** review songs that are due for practice  
**So that** I can maintain my music recognition skills

**Related Requirements:** [DUEQUEUE-001](../requirements/core/DUEQUEUE.md#duequeue-001-due-cards-retrieval), [DUEQUEUE-002](../requirements/core/DUEQUEUE.md#duequeue-002-review-session), [DASHBOARD-001](../requirements/additional/DASHBOARD.md#dashboard-001-overview-display)

**Priority:** High | **Story Points:** 5

---

### Story 1.2: Listen and Recall
**As a** user in a review session  
**I want to** hear a song and try to recall its title and artist  
**So that** I can test my music knowledge

**Related Requirements:** [FLASHSYS-001](../requirements/core/FLASHSYS.md#flashsys-001-dual-sided-card-interface), [FLASHSYS-002](../requirements/core/FLASHSYS.md#flashsys-002-youtube-media-player)

**Priority:** High | **Story Points:** 8

---

### Story 1.3: Rate My Performance
**As a** user reviewing a card  
**I want to** rate how well I remembered the song  
**So that** the app knows when to show it to me again

**Related Requirements:** [SRS-001](../requirements/core/SRS.md#srs-001-sm-2-algorithm-implementation), [SRS-002](../requirements/core/SRS.md#srs-002-review-scheduling), [FLASHSYS-003](../requirements/core/FLASHSYS.md#flashsys-003-answer-rating)

**Priority:** High | **Story Points:** 5

---

## Epic 2: Card Management

### Story 2.1: Add a Song Manually
**As a** user  
**I want to** add a new song to my collection  
**So that** I can practice it later

**Related Requirements:** [CARDMGMT-002](../requirements/core/CARDMGMT.md#cardmgmt-002-manual-card-creation)

**Priority:** High | **Story Points:** 5

---

### Story 2.2: Browse My Song Library
**As a** user  
**I want to** view all my saved songs in one place  
**So that** I can see my collection and manage it

**Related Requirements:** [CARDMGMT-005](../requirements/core/CARDMGMT.md#cardmgmt-005-card-search-and-filter)

**Priority:** High | **Story Points:** 5

---

### Story 2.3: Edit a Song Card
**As a** user  
**I want to** edit the details of an existing card  
**So that** I can correct mistakes or update information

**Related Requirements:** [CARDMGMT-003](../requirements/core/CARDMGMT.md#cardmgmt-003-card-editing)

**Priority:** Medium | **Story Points:** 3

---

### Story 2.4: Delete a Song Card
**As a** user  
**I want to** remove songs I no longer want to practice  
**So that** my library stays relevant

**Related Requirements:** [CARDMGMT-004](../requirements/core/CARDMGMT.md#cardmgmt-004-card-deletion)

**Priority:** Medium | **Story Points:** 2

---

### Story 2.5: Import Cards from CSV
**As a** user with an existing list of songs  
**I want to** import multiple cards from a CSV file  
**So that** I can build my library quickly

**Related Requirements:** [CARDMGMT-001](../requirements/core/CARDMGMT.md#cardmgmt-001-csv-import-) (High Priority)

**Priority:** High | **Story Points:** 5

**Note:** CSV import is the primary method for building a card library and has higher priority than manual card creation.

---

## Epic 3: Enhanced Learning Features

### Story 3.1: Type My Answer
**As a** user who wants more challenge  
**I want to** type my answer before revealing the correct one  
**So that** I can test my active recall more rigorously

**Related Requirements:** [FLASHSYS-004](../requirements/core/FLASHSYS.md#flashsys-004-answer-input-optional), [FR-2.2.1](../requirements/02_phase2.md#fr-221-answer-validation)

**Priority:** Low | **Story Points:** 8

---

### Story 3.2: Import From Playlist
**As a** user with a large collection  
**I want to** import multiple songs from a YouTube playlist  
**So that** I can build my library quickly

**Related Requirements:** [FR-2.4.1](../requirements/02_phase2.md#fr-241-bulk-import-from-playlist)

**Priority:** Low | **Story Points:** 13

---

## Epic 4: Information and Settings

### Story 4.1: View My Statistics
**As a** user  
**I want to** see my learning progress and statistics  
**So that** I can stay motivated and track my improvement

**Related Requirements:** [SRS-003](../requirements/core/SRS.md#srs-003-performance-tracking), [DASHBOARD-001](../requirements/additional/DASHBOARD.md#dashboard-001-overview-display)

**Priority:** Medium | **Story Points:** 5

---

### Story 4.2: Configure App Settings
**As a** user  
**I want to** customize how the app works  
**So that** it fits my learning style and preferences

**Related Requirements:** [FR-3.2.1](../requirements/03_additional.md#fr-321-application-settings)

**Priority:** Medium | **Story Points:** 5

---

### Story 4.3: Backup My Data
**As a** user  
**I want to** export and import my card collection  
**So that** I can back up my data or transfer it to another device

**Related Requirements:** [FR-3.2.2](../requirements/03_additional.md#fr-322-data-management)

**Priority:** Low | **Story Points:** 8

---

## Epic 5: User Experience Enhancements

### Story 5.1: Quick Start Tutorial
**As a** new user  
**I want to** see how the app works  
**So that** I can start using it effectively right away

**Related Requirements:** New feature (not yet in functional requirements)

**Priority:** Low | **Story Points:** 5

**Note:** This is a UX enhancement that should be added to functional requirements.

---

### Story 5.2: Handle Network Issues
**As a** user with unstable internet  
**I want to** see clear messages when things go wrong  
**So that** I understand what's happening and what to do

**Related Requirements:** See [Non-Functional Requirements](../../engineering/non_functional/non_functional_requirements.md) - Error Handling & Network Resilience

**Priority:** Medium | **Story Points:** 5

---

### Story 5.3: Smooth Animations
**As a** user  
**I want to** experience smooth and polished animations  
**So that** the app feels professional and enjoyable to use

**Related Requirements:** Non-functional requirement - see [Non-Functional Requirements](../../engineering/non_functional/non_functional_requirements.md#12-ui-performance)

**Priority:** Low | **Story Points:** 3

---

## Epic 6: Advanced Features (Future)

### Story 6.1: Auto-Fetch Song Details
**As a** user adding a song  
**I want to** have the title and artist filled automatically  
**So that** I save time when creating cards

**Related Requirements:** [FR-2.3.1](../requirements/02_phase2.md#fr-231-youtube-metadata-fetch)

**Priority:** Medium | **Story Points:** 8

---

### Story 6.2: Offline Mode
**As a** user who travels frequently  
**I want to** review cards without an internet connection  
**So that** I can practice anywhere

**Related Requirements:** [FR-4.3.1](../requirements/04_future.md#fr-431-offline-mode-with-cached-audio) (Future consideration)

**Priority:** Low | **Story Points:** 13

---

### Story 6.3: Share Playlists
**As a** user who enjoys the app  
**I want to** share my card collection with friends  
**So that** they can learn the same songs

**Related Requirements:** [FR-4.2.1](../requirements/04_future.md#fr-421-collaborative-playlists) (Future consideration)

**Priority:** Low | **Story Points:** 8

---

## How to Use This Document

1. **User Stories** provide the "why" and "what" from a user perspective
2. **Functional Requirements** provide the "how" with detailed acceptance criteria
3. When implementing a story, always consult the linked FR for technical details
4. If a story doesn't have a corresponding FR, it should be added to the functional requirements first

---

## Story Template for New Features

**As a** [type of user]  
**I want to** [action/goal]  
**So that** [benefit/value]

**Related Requirements:** [FR-X.X.X](../requirements/README.md)

**Priority:** [High/Medium/Low] | **Story Points:** [1-13]

---

## Notes on Story Points

- **1-2:** Simple change, < 1 day
- **3-5:** Standard feature, 1-3 days
- **8:** Complex feature, 3-5 days
- **13:** Very complex, 1-2 weeks
- **21+:** Epic should be broken down into smaller stories


