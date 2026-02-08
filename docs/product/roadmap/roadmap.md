# Project Roadmap - BeatRecall

## Document Information
- **Version:** 2.0
- **Last Updated:** 2026-02-08
- **Status:** Draft

## Table of Contents
- [1. Project Phases Overview](#1-project-phases-overview)
- [2. Phase 0: Planning & Setup](#2-phase-0-planning--setup-weeks-1-2)
- [3. Phase 1: MVP Implementation](#3-phase-1-mvp-implementation-weeks-3-8)
- [4. Phase 2: Enhancements](#4-phase-2-enhancements-weeks-9-12)
- [5. Phase 3: Future Features](#5-phase-3-future-features-tbd)
- [6. Milestones & Release Strategy](#6-milestones--release-strategy)
- [7. Dependencies & Risks](#7-dependencies--risks)

---

## 1. Project Phases Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Phase 0   │────▶│   Phase 1   │────▶│   Phase 2   │────▶│   Phase 3   │
│  Planning   │     │  Core MVP   │     │  Enhanced   │     │   Future    │
│  (Complete) │     │  (Current)  │     │  (6 weeks)  │     │  Features   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

---

## 2. Phase 0: Planning & Setup (2 Weeks)

### 2.1 Week 1: Requirements & Design
**Status:** ✅ Complete

**Tasks:**
- [x] Define product vision
- [x] Write functional requirements
- [x] Create user stories
- [x] Design architecture
- [x] Create development setup guide
- [x] Define design system (colors, typography, spacing)
- [x] Define core API contracts (base architecture)
- [x] Set up project repository

**Deliverables:**
- ✅ Requirements documentation (core, additional, future)
- ✅ User stories (6 epics defined)
- ✅ Architecture documentation (4-layer architecture, base API contracts)
- ✅ Design system ([design_system.md](../design/design_system.md))
- ✅ Technical design document

**Notes:**
- UI screens specified in user stories - iterative implementation without detailed mockups
- Extended API contracts (YouTube, Validation, Error services) will be created **on-demand during implementation**
- Design system provides foundation for consistent UI development

### 2.2 Week 2: Development Environment
**Status:** ✅ In Progress

**Tasks:**
- [x] Set up Flutter project
- [x] Configure Isar database
- [ ] Set up CI/CD pipeline
- [ ] Configure linting and formatting
- [x] Set up testing framework
- [x] Create project structure
- [x] Initialize Git repository

**Deliverables:**
- [x] Working Flutter project skeleton
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Development documentation

---

## 3. Phase 1: Core MVP (8 Weeks)

**Goal:** Deliver a functional SRS-based music quiz app with basic features.

**User Stories:** See [Epic 1-3](../user_stories/user_stories.md) for user perspective

### 3.1 Sprint 1: Foundation (2 weeks)
**Status:** ✅ Complete  
**Focus:** Data layer and basic services

**Features:**
- [x] **SRS-001:** SM-2 Algorithm Implementation
  - ✅ Implement SM-2 algorithm (26 comprehensive tests)
  - ✅ Unit tests for SRS calculations
  - ✅ Documentation
- [x] **Data Model:** Flashcard entity
  - ✅ Domain entity (pure Dart, UUID-based)
  - ✅ Isar entity (IsarFlashcard)
  - ✅ Mapper (domain ↔ data)
  - ✅ Factory (FlashcardFactory)
- [x] **Database Service:**
  - ✅ Repository interface (UUID-based)
  - ✅ Isar repository implementation
  - ✅ CRUD operations
  - ✅ Query functions (due cards, search, pagination)
  - ✅ Error handling

**Success Criteria:**
- [x] SRS algorithm passes all test cases (26/26 tests passing)
- [x] Database operations working (20 unit tests passing)
- [x] Clean architecture: Domain independent of Isar

**Implementation Notes:**
- UUID-based identification ensures domain stability
- Domain `Flashcard` uses UUID; data `IsarFlashcard` has both UUID and Isar ID
- See `app/lib/data/README.md` for architecture details

### 3.2 Sprint 2: Card Management (2 weeks)
**Status:** 🔄 In Progress (60% complete)  
**Focus:** Add, edit, delete cards  
**User Stories:** [Epic 1: Card Management](../user_stories/user_stories.md#epic-1-card-management) (Stories 1.1-1.5)

**Features:**
- [x] **CARDMGMT-001:** CSV Import ⭐ (Story 1.1) **COMPLETE**
  - ✅ File picker integration (file_picker 8.3.7)
  - ✅ CSV parsing and validation (csv 6.0.0)
  - ✅ Duplicate detection by YouTube ID
  - ✅ Import summary UI with error details
  - ✅ Progress indicator
  - ✅ Error reporting per row
  - ✅ UI Screen implementation
  - ✅ Test fixtures (4 CSV files)
  - ✅ 40 unit + integration tests passing
- [x] **CARDMGMT-005:** Library Screen (Story 1.3) **COMPLETE**
  - ✅ List all cards with CardListItem widget
  - ✅ Search by title/artist (real-time, case-insensitive)
  - ✅ Filter by status (New/Learning/Review)
  - ✅ Filter by due date (Today/Overdue/This Week/All)
  - ✅ Sort options (A-Z, Z-A, Artist, Due Date, Created)
  - ✅ Result count display
  - ✅ Clear filters button
  - ✅ Navigation to CSV import (named routes)
  - ✅ LibraryViewModel with 23 tests
  - ✅ Provider state management
  - ✅ Debug: Reset learning progress button (confirmation dialog)
- [ ] **CARDMGMT-002:** Manual card creation (Story 1.2)
  - Add Card screen UI
  - Form validation
  - YouTube URL parsing
  - Save to database
- [ ] **CARDMGMT-003:** Card editing (Story 1.4)
  - Edit Card screen
  - Update operations
- [ ] **CARDMGMT-004:** Card deletion (Story 1.5)
  - Delete confirmation dialog
  - Cascade delete logic

**Success Criteria:**
- [x] Can import cards from CSV files (primary method) ✅
- [x] Library displays all cards with search and filters ✅
- [ ] Can add cards manually with YouTube URLs
- [ ] Can edit existing cards
- [ ] Can delete cards with confirmation

**Implementation Notes:**
- Provider scope restructured: All providers now above MaterialApp for global access
- Named routes implemented (`/`, `/csv-import`)
- Bug fix: ProviderNotFoundException resolved (4 new tests in provider_scope_test.dart)
- Debug tooling: Reset progress button with confirmation dialog for testing
- Test coverage: 113 tests total (46 SRS + 35 CSV Import + 23 Library + 5 Fixtures + 4 Provider)
- CSV format: `youtube_url,title,artist,start_at_seconds` (album field not supported)
- Git commits: 8ad7890 (card display fixes), d99c56c (test fixes)

### 3.3 Sprint 3: Review System (2 weeks)
**Status:** ✅ Complete  
**Focus:** Quiz loop and flashcard player  
**User Stories:** [Epic 2: Core Learning Experience](../user_stories/user_stories.md#epic-2-core-learning-experience) (Stories 2.1-2.2)

**Features:**
- [x] **FLASHSYS-001:** Dual-sided card interface (Story 2.1) **COMPLETE**
  - ✅ Flashcard widget with flip animation (600ms)
  - ✅ Show/hide answer with tap gesture
  - ✅ Smooth transitions with AnimationController
  - ✅ ValueKey forcing rebuild on card change
- [x] **FLASHSYS-002:** YouTube player integration (Story 2.1) **COMPLETE**
  - ✅ youtube_player_flutter integration (mobile)
  - ✅ Start at specific timestamp support
  - ✅ Play/pause controls
  - ✅ Error handling and fallback UI
  - ✅ Lifecycle management (mounted checks, controller disposal)
- [x] **DUEQUEUE-001:** Due queue retrieval (Story 2.2) **COMPLETE**
  - ✅ fetchDueCards query by nextReviewDate
  - ✅ Sort by due date (oldest first)
  - ✅ Queue management in QuizViewModel
- [x] **Quiz Screen:** (Story 2.2) **COMPLETE**
  - ✅ Display flashcards with due queue
  - ✅ Progress indicator ("Card X of Y")
  - ✅ Navigation through card progression
  - ✅ Loading, error, empty, and session complete states

**Success Criteria:**
- [x] YouTube videos play correctly ✅ (mobile, Windows pending WebView2 fix)
- [x] Due cards are retrieved and displayed ✅
- [x] Can navigate through cards ✅
- [x] Answer reveal works smoothly ✅

**Implementation Notes:**
- Card flip spoiler bug fixed: Separated `_displayedCardIndex` from `_currentIndex` to prevent premature card data updates during animations
- YouTube player lifecycle: Added `mounted` checks before setState to prevent disposed controller errors
- Windows YouTube playback: Error 153 (WebView2 blocking embeds) remains unresolved, deferred
- FlashcardWidget uses ValueKey(card.uuid) to force rebuild vs update on card change

### 3.4 Sprint 4: Rating & Polish (2 weeks)
**Status:** ✅ Complete (100%)  
**Focus:** Complete SRS loop and MVP polish  
**User Stories:** Epic 2 (Story 2.3), [Epic 3: Progress Tracking](../user_stories/user_stories.md#epic-3-progress-tracking) (Story 3.1)

**Features:**
- [x] **FLASHSYS-003:** Answer rating (Story 2.3) **COMPLETE**
  - ✅ Four rating buttons (Again, Hard, Good, Easy)
  - ✅ Color coding (Red, Orange, Green, Blue)
  - ✅ Keyboard shortcuts (1-4 or A/H/G/E)
  - ✅ Next interval display on rating buttons
  - ✅ Tooltips with keyboard hints
- [x] **DUEQUEUE-002:** Review session management (Story 2.2) **COMPLETE**
  - ✅ Session state tracking (QuizViewModel)
  - ✅ Progress calculation (currentIndex/totalCards)
  - ✅ Session summary with rating counts
  - ✅ Session duration tracking
  - ✅ SRS integration (updateSrsFields after rating)
- [x] **DASHBOARD-001:** Dashboard overview display (Story 3.1) **COMPLETE**
  - ✅ DashboardViewModel with repository integration (11 tests)
  - ✅ Due cards count
  - ✅ Total cards count
  - ✅ Reviewed cards count
  - ✅ Success rate calculation
  - ✅ Current streak (max repetitions)
  - ✅ Quick action buttons (Start Review, Library, Import CSV)
  - ✅ Pull-to-refresh functionality
  - ✅ Loading/error/empty states
- [x] **Polish:** **COMPLETE**
  - ✅ Loading states (all screens)
  - ✅ Error messages with retry buttons
  - ✅ Empty states with helpful messages
  - ✅ Session summary screen
  - ✅ App icons (Android/iOS/web/Windows/macOS)
  - ✅ Splash screens (Android/iOS/web with Android 12 support)
  - ✅ Tooltips on all interactive elements
  - ✅ AndroidInAppWebViewController disposal error fixed

**Success Criteria:**
- [x] Complete review loop works end-to-end ✅
- [x] SRS intervals update correctly ✅
- [x] Dashboard shows accurate statistics ✅
- [x] App is polished and ready for testing ✅

**Implementation Notes:**
- Rating loop fully functional: Rate card → Calculate SRS interval → Update database → Advance to next card
- Session statistics tracked: Rating counts, total reviewed, session duration, progress percentage
- Dashboard fully implemented: Stats calculation, quick actions, refresh indicator
- Branding complete: flutter_launcher_icons 0.14.4, flutter_native_splash 2.4.7
- UX improvements: Tooltips throughout, defensive programming for YouTube player disposal

**MVP Release:** 🎯 End of Week 8
- [ ] Internal testing complete
- [x] Documentation updated (README.md, roadmap.md reflect Sprint 4 completion)
- [ ] Release notes prepared
- [ ] Beta release to TestFlight/Play Store Beta

### 3.5 Sprint 4.5: MVP Enhancements (1-2 weeks)
**Status:** ✅ Complete  
**Focus:** Critical UX improvements based on initial testing feedback  
**Priority:** High (addresses user feedback before Phase 2)

**Features:**
- [x] **DUEQUEUE-003:** Continuous session mode
  - ✅ Session runs until all due cards for the day are reviewed
  - ✅ Remove fixed card limit
  - ✅ Dynamic card count display
  - ✅ Cards rated "Again" re-enter session queue when interval=0
  - ✅ Integration with new cards daily limit (SETTINGS-001)
- [x] **FLASHSYS-005:** Enhanced interval display
  - ✅ Show when each card will repeat on rating buttons
  - ✅ Format: "<1m", "3h", "4d", "2w", "3mo"
  - ✅ Display absolute date for intervals >30 days
  - ✅ SrsService.formatInterval() with 13 tests
- [x] **SETTINGS-001:** Daily new cards limit
  - ✅ Settings screen with "New Cards Per Day" configuration
  - ✅ Default: 20 cards/day, range 0-999
  - ✅ Track daily new card count with midnight reset
  - ✅ SettingsService with SharedPreferences persistence
- [x] **SETTINGS-002:** Audio-only mode
  - ✅ Toggle to collapse YouTube video player
  - ✅ Audio continues playing normally
  - ✅ Compact visual indicator when collapsed
  - ✅ Saves bandwidth and battery
- [x] **SETTINGS-003:** Settings screen foundation
  - ✅ Complete settings UI structure
  - ✅ Theme selection (light/dark/system) with live switching
  - ✅ Auto-play behavior toggle
  - ✅ Settings persistence with AppSettings value object

**Success Criteria:**
- [x] Session UX improved: users review all due cards in one session ✅
- [x] Users can control learning pace with new cards limit ✅
- [x] Bandwidth-conscious users can use audio-only mode ✅
- [x] Interval display helps users make better rating decisions ✅
- [x] All settings persist across app restarts ✅
- [x] **Test Coverage:** 191 passing tests (108 services + 25 domain + 58 presentation)

**Implementation Notes:**
- Requirements document SETTINGS.md created with all feature specifications
- QuizViewModel enhanced with SettingsService integration
- FlashcardFront widget updated for audio-only mode with Consumer<SettingsService>
- BeatRecallApp updated for theme switching
- AppSettings value object created for immutable settings model
- All UI text follows proper capitalization (e.g., "Audio-Only Mode", "New Cards Per Day")

---

## 4. Phase 2: Enhanced Features (6 Weeks)

**Goal:** Add quality-of-life features and improvements.

**User Stories:** See [Epic 4-5](../user_stories/user_stories.md#epic-4-enhanced-learning-features) for user perspective

### 4.1 Sprint 5: Auto-Metadata (2 weeks)
**User Stories:** [Epic 4: Enhanced Learning Features](../user_stories/user_stories.md#epic-4-enhanced-learning-features) (Story 4.1)

**Features:**
- [ ] **FR-2.3.1:** YouTube metadata fetch (Story 4.1)
  - YouTube API integration
  - Metadata parsing
  - Auto-fill form fields
  - Error handling
  - Preview before save

### 4.2 Sprint 6: Answer Validation (Optional) (1.5 weeks)
**User Stories:** Epic 4 (Story 4.2)

**Features:**
- [ ] **FR-2.2.1:** Fuzzy matching (Story 4.2)
  - Levenshtein distance algorithm
  - Answer validation
  - Visual feedback
- [ ] **FLASHSYS-004:** Answer input UI (Optional) (Story 4.2)
  - Optional text input mode
  - Toggle in settings
  - Keyboard-friendly

**Note:** This feature is optional and low priority. Can be deferred if time is limited.

### 4.3 Sprint 7: Settings & Data Management (1.5 weeks)
**User Stories:** [Epic 5: Settings & Data Management](../user_stories/user_stories.md#epic-5-settings--data-management) (Stories 5.1-5.2)

**Features:**
- [ ] **FR-3.2.1:** Application settings (Story 5.1)
  - Settings screen
  - SRS parameter configuration
  - Theme selection
  - Preferences storage
- [ ] **FR-3.2.2:** Data management (Story 5.2)
  - Export database
  - Import database
  - Backup/restore

### 4.4 Sprint 8: Polish & Testing (1 week)
**Features:**
- [ ] **Performance optimization**
  - Database query optimization
  - UI performance improvements
  - Memory optimization
- [ ] **Bug fixes and polish**
  - Address beta feedback
  - Edge case handling
  - Error message improvements
- [ ] **Testing and QA**
  - Integration testing
  - User acceptance testing
  - Performance testing

**Phase 2 Release:** 🎯 End of Week 14
- [ ] Beta testing with users
- [ ] Bug fixes from feedback
- [ ] Performance optimization
- [ ] Public release v1.0

---

## 5. Phase 3: Advanced Features (8 Weeks)

**Goal:** Add advanced features based on user feedback.

**User Stories:** See [Epic 6: Advanced Features](../user_stories/user_stories.md#epic-6-advanced-features) for user perspective

### 5.1 Sprint 9-10: Playlist Import (3 weeks)
**User Stories:** Epic 6 (Story 6.1)

**Features:**
- [ ] **FR-2.4.1:** Bulk import from playlist (Story 6.1)
  - Playlist URL input
  - Fetch all videos
  - Preview and selection UI
  - Batch creation
  - Progress indicator

### 5.2 Sprint 11: Statistics & Analytics (2 weeks)
**User Stories:** Epic 6 (Story 6.2)

**Features:**
- [ ] Enhanced statistics dashboard (Story 6.2)
- [ ] Charts and graphs
- [ ] Review history timeline
- [ ] Performance trends
- [ ] Export statistics

### 5.3 Sprint 12: UX Improvements (2 weeks)
**User Stories:** Epic 6 (Stories 6.3-6.5)

**Features:**
- [ ] Onboarding tutorial (Story 6.3)
- [ ] Animations and transitions (Story 6.5)
- [ ] Gesture controls
- [ ] Haptic feedback
- [ ] Accessibility improvements
- [ ] Network error handling (Story 6.4)

### 5.4 Sprint 13: Community Features (1 week)
**User Stories:** Epic 6 (Story 6.7)

**Features:**
- [ ] Share playlists (Story 6.7)
- [ ] Import shared playlists
- [ ] Rate limiting
- [ ] Social sharing

**Phase 3 Release:** 🎯 End of Week 22
- [ ] Feature-complete v1.5
- [ ] Marketing push
- [ ] Community engagement

---

## 6. Phase 4: Future Roadmap (6+ Months)

**User Stories:** Some features from [Epic 6: Advanced Features](../user_stories/user_stories.md#epic-6-advanced-features)

### 6.1 Potential Features
**Priority: High**
- [ ] Offline mode with audio caching (Story 6.6)
- [ ] Cloud sync (Firebase/Supabase)
- [ ] Multi-device support
- [ ] Advanced search and filters

**Priority: Medium**
- [ ] Spotify integration
- [ ] Apple Music integration
- [ ] Custom card types (album covers, lyrics)
- [ ] Collaborative playlists
- [ ] Achievement system

**Priority: Low**
- [ ] Social features (friends, leaderboards)
- [ ] In-app community
- [ ] Live quiz mode
- [ ] Web version
- [ ] Desktop version

### 6.2 Monetization (Optional)
- [ ] Premium features (cloud sync, advanced stats)
- [ ] One-time purchase or subscription model
- [ ] No ads policy maintained

---

## 7. Milestones

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Requirements Complete | Week 2 | ✅ Done |
| Development Setup | Week 2 | ⏳ In Progress |
| MVP Alpha | Week 6 | 📅 Planned |
| MVP Beta | Week 8 | 📅 Planned |
| Phase 2 Beta | Week 14 | 📅 Planned |
| Public Release v1.0 | Week 14 | 📅 Planned |
| Phase 3 Release v1.5 | Week 22 | 📅 Planned |

---

## 8. Resource Planning

### 8.1 Team
**Current:** 1 Developer (MVP)
**Future:** Consider adding:
- UI/UX Designer (Phase 2)
- QA Tester (Phase 2)
- Marketing/Community Manager (Phase 3)

### 8.2 Tools & Services
**Free Tier:**
- GitHub (version control)
- GitHub Actions (CI/CD)
- Firebase (optional, for analytics)

**Paid Services (Future):**
- YouTube API quota increase
- Cloud hosting (Firebase/AWS)
- App Store fees ($99/year iOS, $25 one-time Android)

---

## 9. Risk Management

### 9.1 Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| YouTube API changes | Medium | High | Use official package, monitor updates |
| Isar database issues | Low | High | Have SQLite as backup plan |
| Performance issues | Medium | Medium | Regular performance testing |
| Flutter breaking changes | Low | Medium | Lock Flutter version, controlled upgrades |

### 9.2 Product Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Low user adoption | Medium | High | Beta testing, user feedback |
| YouTube TOS violation | Low | Critical | Follow guidelines strictly |
| App store rejection | Low | Medium | Follow guidelines, prepare appeals |
| Competition | Medium | Medium | Focus on unique SRS features |

---

## 10. Success Metrics

### 10.1 MVP Success Criteria
- [ ] 100+ beta testers sign up
- [ ] < 5 critical bugs reported
- [ ] Average rating 4+ stars
- [ ] 70%+ feature usage (review session)
- [ ] Positive user feedback

### 10.2 Phase 2 Success Criteria
- [ ] 1,000+ downloads in first month
- [ ] 40%+ user retention (week 2)
- [ ] Average 3+ reviews per user per day
- [ ] < 1% crash rate

### 10.3 Long-term Success Criteria
- [ ] 10,000+ active users
- [ ] 60%+ monthly active users
- [ ] Featured on App Store/Play Store
- [ ] Sustainable development model

---

## 11. Release Strategy

### 11.1 MVP (Phase 1)
1. **Internal Alpha:** Weeks 6-7 (developer testing)
2. **Closed Beta:** Week 8 (10-20 testers)
3. **Open Beta:** Week 9-10 (TestFlight/Play Store Beta)
4. **MVP Launch:** Week 10 (soft launch)

### 11.2 Phase 2
1. **Beta Testing:** Week 13-14
2. **Public v1.0:** Week 14 (full launch)
3. **Marketing Push:** Week 14-16

### 11.3 Ongoing
- **Patch releases:** As needed (bug fixes)
- **Minor releases:** Every 4-6 weeks (new features)
- **Major releases:** Every 6-12 months
