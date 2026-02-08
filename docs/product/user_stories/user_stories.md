# User Stories - BeatRecall

## Document Information
- **Version:** 2.0
- **Last Updated:** 2026-02-07
- **Status:** Draft

---

## Purpose

This document describes features from the **user's perspective**, focusing on the value delivered and user needs. For detailed technical specifications and acceptance criteria, refer to the [Functional Requirements](../requirements/README.md).

---

## Epic 1: Core Learning Experience

### Story 1.1: Review Due Cards
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


