# User Stories - BeatRecall

## Document Information
- **Version:** 1.0
- **Last Updated:** 2026-02-07
- **Status:** Draft

---

## Epic 1: Core Learning Experience

### Story 1.1: Review Due Cards
**As a** pub quiz enthusiast  
**I want to** review songs that are due for practice  
**So that** I can maintain my music recognition skills

**Acceptance Criteria:**
- [ ] I can see how many cards are due today on the dashboard
- [ ] I can start a review session with one tap
- [ ] Cards are presented to me one at a time
- [ ] I can see my progress (e.g., "3 of 15")
- [ ] I receive a summary when I complete all due cards

**Priority:** High  
**Story Points:** 5

---

### Story 1.2: Listen and Recall
**As a** user in a review session  
**I want to** hear a song and try to recall its title and artist  
**So that** I can test my music knowledge

**Acceptance Criteria:**
- [ ] A YouTube video/audio plays automatically when a card is shown
- [ ] The song starts at the configured timestamp (or beginning)
- [ ] I can see a "Show Answer" button clearly
- [ ] The title and artist are hidden until I tap "Show Answer"
- [ ] I can replay the audio if needed

**Priority:** High  
**Story Points:** 8

---

### Story 1.3: Rate My Performance
**As a** user reviewing a card  
**I want to** rate how well I remembered the song  
**So that** the app knows when to show it to me again

**Acceptance Criteria:**
- [ ] I see four rating options: Again, Hard, Good, Easy
- [ ] Each button is clearly labeled and color-coded
- [ ] Each button shows the next review interval (e.g., "10 min", "4 days")
- [ ] Tapping a rating immediately saves my response and shows the next card
- [ ] I can use keyboard shortcuts (1-4) for quick rating

**Priority:** High  
**Story Points:** 5

---

## Epic 2: Card Management

### Story 2.1: Add a Song Manually
**As a** user  
**I want to** add a new song to my collection  
**So that** I can practice it later

**Acceptance Criteria:**
- [ ] I can navigate to an "Add Card" screen
- [ ] I can paste or type a YouTube URL
- [ ] I can enter the song title
- [ ] I can enter the artist name
- [ ] The app validates that the URL is a valid YouTube link
- [ ] I receive confirmation when the card is successfully created
- [ ] The new card appears in my library

**Priority:** High  
**Story Points:** 5

---

### Story 2.2: Browse My Song Library
**As a** user  
**I want to** view all my saved songs in one place  
**So that** I can see my collection and manage it

**Acceptance Criteria:**
- [ ] I can navigate to a "Library" screen
- [ ] I see a list of all my cards showing title and artist
- [ ] I can search for cards by title or artist
- [ ] I can see which cards are due soon
- [ ] I can tap a card to view more details

**Priority:** High  
**Story Points:** 5

---

### Story 2.3: Edit a Song Card
**As a** user  
**I want to** edit the details of an existing card  
**So that** I can correct mistakes or update information

**Acceptance Criteria:**
- [ ] I can tap an edit button on any card
- [ ] All card fields are editable (URL, title, artist, start time)
- [ ] Changes are validated before saving
- [ ] I can cancel editing without saving
- [ ] My learning progress (SRS data) is preserved after editing

**Priority:** Medium  
**Story Points:** 3

---

### Story 2.4: Delete a Song Card
**As a** user  
**I want to** remove songs I no longer want to practice  
**So that** my library stays relevant

**Acceptance Criteria:**
- [ ] I can access a delete option for any card
- [ ] I see a confirmation dialog before deletion
- [ ] The card is permanently removed from my library
- [ ] The card no longer appears in review sessions
- [ ] I see a success message after deletion

**Priority:** Medium  
**Story Points:** 2

---

## Epic 3: Enhanced Learning Features

### Story 3.1: Skip Song Intros
**As a** user  
**I want to** set where each song should start playing  
**So that** I don't have to listen to long intros during reviews

**Acceptance Criteria:**
- [ ] I can set a custom start timestamp (in seconds) when creating/editing a card
- [ ] I can preview the playback from the set timestamp
- [ ] The song always starts at this timestamp during reviews
- [ ] If no timestamp is set, the song starts from the beginning

**Priority:** Medium  
**Story Points:** 5

---

### Story 3.2: Type My Answer
**As a** user who wants more challenge  
**I want to** type my answer before revealing the correct one  
**So that** I can test my active recall more rigorously

**Acceptance Criteria:**
- [ ] I see text inputs for title and artist (optional feature toggle)
- [ ] I can type my answer and submit it
- [ ] The app validates my answer with typo tolerance
- [ ] I see visual feedback if my answer is correct or incorrect
- [ ] I can still skip typing and directly reveal the answer

**Priority:** Low  
**Story Points:** 8

---

### Story 3.3: Import From Playlist
**As a** user with a large collection  
**I want to** import multiple songs from a YouTube playlist  
**So that** I can build my library quickly

**Acceptance Criteria:**
- [ ] I can paste a YouTube playlist URL
- [ ] The app fetches all videos from the playlist
- [ ] I see a preview list with checkboxes
- [ ] I can select which songs to import
- [ ] I see a progress indicator during import
- [ ] All selected songs are added to my library

**Priority:** Low  
**Story Points:** 13

---

## Epic 4: Information and Settings

### Story 4.1: View My Statistics
**As a** user  
**I want to** see my learning progress and statistics  
**So that** I can stay motivated and track my improvement

**Acceptance Criteria:**
- [ ] I can see total number of cards in my library
- [ ] I can see how many cards are due today
- [ ] I can see my review success rate
- [ ] I can see my review streak (consecutive days)
- [ ] Statistics are updated in real-time

**Priority:** Medium  
**Story Points:** 5

---

### Story 4.2: Configure App Settings
**As a** user  
**I want to** customize how the app works  
**So that** it fits my learning style and preferences

**Acceptance Criteria:**
- [ ] I can access a Settings screen
- [ ] I can adjust SRS parameters (ease factor, interval multipliers)
- [ ] I can set default playback duration
- [ ] I can toggle audio-only mode
- [ ] I can choose between light and dark theme
- [ ] All settings are saved and applied immediately

**Priority:** Medium  
**Story Points:** 5

---

### Story 4.3: Backup My Data
**As a** user  
**I want to** export and import my card collection  
**So that** I can back up my data or transfer it to another device

**Acceptance Criteria:**
- [ ] I can export my entire database to a file
- [ ] The export file includes all cards and SRS data
- [ ] I can import a database file
- [ ] I see a warning before overwriting existing data
- [ ] The import process validates the file format

**Priority:** Low  
**Story Points:** 8

---

## Epic 5: User Experience Enhancements

### Story 5.1: Quick Start Tutorial
**As a** new user  
**I want to** see how the app works  
**So that** I can start using it effectively right away

**Acceptance Criteria:**
- [ ] A brief tutorial is shown on first launch
- [ ] The tutorial explains the SRS concept
- [ ] The tutorial demonstrates how to add a card
- [ ] The tutorial shows how to review cards
- [ ] I can skip or exit the tutorial at any time

**Priority:** Low  
**Story Points:** 5

---

### Story 5.2: Handle Network Issues
**As a** user with unstable internet  
**I want to** see clear messages when things go wrong  
**So that** I understand what's happening and what to do

**Acceptance Criteria:**
- [ ] I see a helpful error message if YouTube fails to load
- [ ] I can retry loading a video
- [ ] I can skip a card if it won't load
- [ ] The app doesn't crash due to network issues
- [ ] I can continue reviewing cards that are already cached

**Priority:** Medium  
**Story Points:** 5

---

### Story 5.3: Smooth Animations
**As a** user  
**I want to** experience smooth and polished animations  
**So that** the app feels professional and enjoyable to use

**Acceptance Criteria:**
- [ ] Card transitions are smooth (60 FPS)
- [ ] Button presses have visual feedback
- [ ] Screen transitions are fluid
- [ ] Loading states are clearly indicated
- [ ] Animations don't block user interaction

**Priority:** Low  
**Story Points:** 3

---

## Epic 6: Advanced Features (Future)

### Story 6.1: Auto-Fetch Song Details
**As a** user adding a song  
**I want to** have the title and artist filled automatically  
**So that** I save time when creating cards

**Acceptance Criteria:**
- [ ] When I paste a YouTube URL, the app fetches video metadata
- [ ] The title field is pre-filled with the video title
- [ ] The artist name is extracted if possible
- [ ] I can still edit the pre-filled information
- [ ] Metadata fetching happens in the background

**Priority:** Medium  
**Story Points:** 8

---

### Story 6.2: Offline Mode
**As a** user who travels frequently  
**I want to** review cards without an internet connection  
**So that** I can practice anywhere

**Acceptance Criteria:**
- [ ] Songs are cached locally for offline playback
- [ ] I can select which cards to cache
- [ ] I see storage space usage
- [ ] Cached songs play without internet
- [ ] I'm notified if a cached song is no longer available

**Priority:** Low  
**Story Points:** 13

---

### Story 6.3: Share Playlists
**As a** user who enjoys the app  
**I want to** share my card collection with friends  
**So that** they can learn the same songs

**Acceptance Criteria:**
- [ ] I can export a playlist as a shareable file
- [ ] The file contains YouTube links and metadata
- [ ] Others can import my shared playlist
- [ ] Imported playlists don't overwrite existing cards
- [ ] I can see which playlists I've imported from others

**Priority:** Low  
**Story Points:** 8

---

## Story Template for New Features

**As a** [type of user]  
**I want to** [action/goal]  
**So that** [benefit/value]

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**Priority:** [High/Medium/Low]  
**Story Points:** [1-13]

---

## Notes on Story Points

- **1-2:** Simple change, < 1 day
- **3-5:** Standard feature, 1-3 days
- **8:** Complex feature, 3-5 days
- **13:** Very complex, 1-2 weeks
- **21+:** Epic should be broken down into smaller stories
