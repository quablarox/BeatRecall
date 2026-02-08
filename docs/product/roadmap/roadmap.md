# Project Roadmap - BeatRecall

## Document Information
- **Version:** 1.0
- **Last Updated:** 2026-02-07
- **Status:** Draft

---

## 1. Project Phases Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Phase 0   │────▶│   Phase 1   │────▶│   Phase 2   │────▶│   Phase 3   │
│  Planning   │     │  Core MVP   │     │  Enhanced   │     │   Future    │
│  (Current)  │     │  (8 weeks)  │     │  (6 weeks)  │     │  Features   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

---

## 2. Phase 0: Planning & Setup (2 Weeks)

### 2.1 Week 1: Requirements & Design
**Status:** ✅ In Progress

**Tasks:**
- [x] Define product vision
- [x] Write functional requirements
- [x] Create user stories
- [x] Design architecture
- [x] Create development setup guide
- [ ] Design UI mockups
- [ ] Define API contracts
- [ ] Set up project repository

**Deliverables:**
- ✅ Requirements documentation
- ✅ User stories
- ✅ Architecture documentation
- ⏳ UI mockups (Figma/Sketch)
- ⏳ Technical design document

### 2.2 Week 2: Development Environment
**Status:** ⏳ Pending

**Tasks:**
- [ ] Set up Flutter project
- [ ] Configure Isar database
- [ ] Set up CI/CD pipeline
- [ ] Configure linting and formatting
- [ ] Set up testing framework
- [ ] Create project structure
- [ ] Initialize Git repository

**Deliverables:**
- [ ] Working Flutter project skeleton
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Development documentation

---

## 3. Phase 1: Core MVP (8 Weeks)

**Goal:** Deliver a functional SRS-based music quiz app with basic features.

### 3.1 Sprint 1: Foundation (2 weeks)
**Focus:** Data layer and basic services

**Features:**
- [ ] **SRS-001:** SM-2 Algorithm Implementation
  - Implement SM-2 algorithm
  - Unit tests for SRS calculations
  - Documentation
- [ ] **Data Model:** Flashcard entity
  - Isar schema definition
  - Model classes
  - Type converters
- [ ] **Database Service:**
  - CRUD operations
  - Query functions
  - Error handling

**Success Criteria:**
- [ ] SRS algorithm passes all test cases
- [ ] Database operations working
- [ ] 90% test coverage for business logic

### 3.2 Sprint 2: Card Management (2 weeks)
**Focus:** Add, edit, delete cards

**Features:**
- [ ] **CARDMGMT-001:** CSV Import ⭐
  - File picker integration
  - CSV parsing and validation
  - Duplicate detection
  - Import summary UI
  - Progress indicator
- [ ] **CARDMGMT-002:** Manual card creation
  - Add Card screen UI
  - Form validation
  - YouTube URL parsing
  - Save to database
- [ ] **CARDMGMT-003:** Card editing
  - Edit Card screen
  - Update operations
- [ ] **CARDMGMT-004:** Card deletion
  - Delete confirmation dialog
  - Cascade delete logic
- [ ] **Library Screen:**
  - List all cards
  - Search functionality
  - Navigation

**Success Criteria:**
- [ ] Can import cards from CSV files (primary method)
- [ ] Can add cards manually with YouTube URLs
- [ ] Can edit existing cards
- [ ] Can delete cards with confirmation
- [ ] Library displays all cards

### 3.3 Sprint 3: Review System (2 weeks)
**Focus:** Quiz loop and flashcard player

**Features:**
- [ ] **FLASHSYS-001:** Dual-sided card interface
  - Flashcard widget
  - Show/hide answer
  - Smooth transitions
- [ ] **FLASHSYS-002:** YouTube player integration
  - Integrate youtube_player_flutter
  - Play/pause controls
  - Error handling
- [ ] **DUEQUEUE-001:** Due queue retrieval
  - Query due cards
  - Sort by due date
  - Queue management
- [ ] **Quiz Screen:**
  - Display flashcards
  - Progress indicator
  - Navigation controls

**Success Criteria:**
- [ ] YouTube videos play correctly
- [ ] Due cards are retrieved and displayed
- [ ] Can navigate through cards
- [ ] Answer reveal works smoothly

### 3.4 Sprint 4: Rating & Polish (2 weeks)
**Focus:** Complete SRS loop and MVP polish

**Features:**
- [ ] **FLASHSYS-003:** Answer rating
  - Four rating buttons (Again, Hard, Good, Easy)
  - Color coding
  - Keyboard shortcuts
  - Next interval display
- [ ] **DUEQUEUE-002:** Review session management
  - Session state tracking
  - Progress calculation
  - Session summary
- [ ] **DASHBOARD-001:** Dashboard overview display
  - Due cards count
  - Total cards count
  - Quick action buttons
- [ ] **Polish:**
  - Loading states
  - Error messages
  - Empty states
  - App icon and splash screen

**Success Criteria:**
- [ ] Complete review loop works end-to-end
- [ ] SRS intervals update correctly
- [ ] Dashboard shows accurate statistics
- [ ] App is polished and ready for testing

**MVP Release:** 🎯 End of Week 8
- [ ] Internal testing complete
- [ ] Documentation updated
- [ ] Release notes prepared
- [ ] Beta release to TestFlight/Play Store Beta

---

## 4. Phase 2: Enhanced Features (6 Weeks)

**Goal:** Add quality-of-life features and improvements.

### 4.1 Sprint 5: Auto-Metadata (2 weeks)
**Features:**
- [ ] **FR-2.3.1:** YouTube metadata fetch
  - YouTube API integration
  - Metadata parsing
  - Auto-fill form fields
  - Error handling
  - Preview before save

### 4.2 Sprint 6: Answer Validation (Optional) (1.5 weeks)
**Features:**
- [ ] **FR-2.2.1:** Fuzzy matching
  - Levenshtein distance algorithm
  - Answer validation
  - Visual feedback
- [ ] **FLASHSYS-004:** Answer input UI (Optional)
  - Optional text input mode
  - Toggle in settings
  - Keyboard-friendly

**Note:** This feature is optional and low priority. Can be deferred if time is limited.

### 4.3 Sprint 7: Settings & Data Management (1.5 weeks)
**Features:**
- [ ] **FR-3.2.1:** Application settings
  - Settings screen
  - SRS parameter configuration
  - Theme selection
  - Preferences storage
- [ ] **FR-3.2.2:** Data management
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

### 5.1 Sprint 9-10: Playlist Import (3 weeks)
**Features:**
- [ ] **FR-2.4.1:** Bulk import from playlist
  - Playlist URL input
  - Fetch all videos
  - Preview and selection UI
  - Batch creation
  - Progress indicator

### 5.2 Sprint 11: Statistics & Analytics (2 weeks)
**Features:**
- [ ] Enhanced statistics dashboard
- [ ] Charts and graphs
- [ ] Review history timeline
- [ ] Performance trends
- [ ] Export statistics

### 5.3 Sprint 12: UX Improvements (2 weeks)
**Features:**
- [ ] Onboarding tutorial
- [ ] Animations and transitions
- [ ] Gesture controls
- [ ] Haptic feedback
- [ ] Accessibility improvements

### 5.4 Sprint 13: Community Features (1 week)
**Features:**
- [ ] Share playlists
- [ ] Import shared playlists
- [ ] Rate limiting
- [ ] Social sharing

**Phase 3 Release:** 🎯 End of Week 22
- [ ] Feature-complete v1.5
- [ ] Marketing push
- [ ] Community engagement

---

## 6. Phase 4: Future Roadmap (6+ Months)

### 6.1 Potential Features
**Priority: High**
- [ ] Offline mode with audio caching
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
