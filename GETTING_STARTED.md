# BeatRecall - Development Quick Start

Welcome to BeatRecall development! This guide will help you get started quickly.

## 📂 Project Structure

```
BeatRecall/
├── README.md                          # Product specification (start here!)
├── GETTING_STARTED.md                 # This file - quick start guide
└── docs/                              # All documentation
    ├── README.md                      # Documentation index
    ├── product/                       # WHAT we're building & WHY
    │   ├── requirements/              # Functional requirements (split)
    │   │   ├── README.md
    │   │   ├── core/                  # Core MVP features (feature per file)
    │   │   │   ├── README.md
    │   │   │   ├── SRS.md             # Spaced repetition system
    │   │   │   ├── FLASHSYS.md        # Flashcard interface
    │   │   │   ├── CARDMGMT.md        # Card management
    │   │   │   └── DUEQUEUE.md        # Review queue
    │   │   ├── 02_phase2.md
    │   │   ├── 03_additional.md
    │   │   ├── 04_future.md
    │   │   └── 05_cross_cutting.md
    │   ├── user_stories/
    │   │   └── user_stories.md
    │   └── roadmap/
    │       └── roadmap.md
    └── engineering/                   # HOW we're building it
        ├── architecture/
        │   └── architecture.md
        ├── setup/
        │   └── development_setup.md
        ├── testing/
        │   └── testing_strategy.md
        └── non_functional/
            └── non_functional_requirements.md
```

### 2. Understand What We're Building (3 minutes)
Read the [User Stories](docs/product/user_stories/user_stories.md) to see the features from a user's perspective.

## 📖 For Different Roles

### 👨‍💻 **I'm a Developer - I want to start coding**

**Your Path:**
1. ✅ [Development Setup Guide](docs/engineering/setup/development_setup.md) - Set up your environment
2. ✅ [Architecture Documentation](docs/engineering/architecture/architecture.md) - Understand the code structure
3. ✅ [Functional Requirements](docs/product/requirements/README.md) - Know what to implement
4. ✅ [Testing Strategy](docs/engineering/testing/testing_strategy.md) - Learn how to test
5. ✅ [Roadmap](docs/product/roadmap/roadmap.md) - See current priorities

**Quick Commands:**
```bash
# Clone the repository
git clone https://github.com/quablarox/BeatRecall.git
cd BeatRecall

# Install Flutter (if not already)
# Follow: https://flutter.dev/docs/get-started/install

# Get dependencies (when project is set up)
flutter pub get

# Run the app (when implemented)
flutter run

# Run tests
flutter test
```

---

### 📋 **I'm a Project Manager - I need to plan**

**Your Path:**
1. ✅ [Roadmap](docs/product/roadmap/roadmap.md) - Timeline and milestones
2. ✅ [User Stories](docs/product/user_stories/user_stories.md) - Feature backlog
3. ✅ [Functional Requirements](docs/product/requirements/README.md) - Detailed scope
4. ✅ [Non-Functional Requirements](docs/engineering/non_functional/non_functional_requirements.md) - Quality gates

**Key Information:**
- **MVP Timeline:** 8 weeks
- **Total Features:** 20+ user stories across 6 epics
- **Phase 1 Deliverables:** Core SRS-based quiz app
- **Testing Coverage:** 70% minimum, 90% for business logic

---

### 🎨 **I'm a Designer - I need to create mockups**

**Your Path:**
1. ✅ [User Stories](docs/product/user_stories/user_stories.md) - User needs and journeys
2. ✅ [Functional Requirements](docs/product/requirements/README.md) - UI requirements
3. ✅ [Non-Functional Requirements](docs/engineering/non_functional/non_functional_requirements.md) - Accessibility & usability

**Key Screens to Design:**
1. Dashboard (due cards count, quick actions)
2. Quiz Screen (flashcard player, rating buttons)
3. Library (searchable card list)
4. Add/Edit Card Form
5. Settings

**Design Considerations:**
- Minimalist, clean design
- Color-coded rating buttons
- Touch-friendly (44x44 points minimum)
- Support dark/light themes
- 60 FPS animations

---

### 🧪 **I'm a QA Tester - I need to test**

**Your Path:**
1. ✅ [Testing Strategy](docs/engineering/testing/testing_strategy.md) - Testing approach
2. ✅ [Functional Requirements](docs/product/requirements/README.md) - Acceptance criteria
3. ✅ [User Stories](docs/product/user_stories/user_stories.md) - User scenarios
4. ✅ [Non-Functional Requirements](docs/engineering/non_functional/non_functional_requirements.md) - Performance metrics

**Test Priorities:**
1. Core SRS loop (add → review → rate → reschedule)
2. YouTube video playback
3. Database persistence
4. Performance (< 3s load time, 60 FPS)
5. Error handling (network issues)

---

## 🎯 What to Focus On First

### Phase 0: Setup (Current - Week 2)
- [x] **Requirements Complete** ✅
- [ ] **UI Mockups** - Design key screens
- [ ] **Flutter Project Setup** - Initialize codebase
- [ ] **CI/CD Pipeline** - GitHub Actions

### Phase 1: MVP (Week 3-10)
Priority features to implement:
1. **Sprint 1:** SRS algorithm + database
2. **Sprint 2:** Add/edit/delete cards
3. **Sprint 3:** Quiz screen + YouTube player
4. **Sprint 4:** Rating system + dashboard

## 📊 Key Metrics & Goals

- **MVP Release:** Week 8
- **Code Coverage:** 70% minimum
- **Performance:** < 2s app startup, < 100ms queries
- **Quality:** < 5 critical bugs in beta

## 🔗 Important Links

- **Product Spec:** [README.md](README.md)
- **All Documentation:** [docs/README.md](docs/README.md)
- **Technical Stack:**
  - Framework: Flutter
  - Database: Isar (NoSQL)
  - Media: YouTube Player Flutter
  - State Management: Provider/Riverpod

## 📚 External Resources

- **Flutter Docs:** https://flutter.dev/docs
- **Isar Database:** https://isar.dev/
- **YouTube API:** https://developers.google.com/youtube/v3
- **SM-2 Algorithm:** https://www.supermemo.com/en/archives1990-2015/english/ol/sm2

## 💡 Tips for Success

1. **Start Small:** Focus on MVP features first
2. **Test Early:** Write tests as you code
3. **Document:** Update docs when you change behavior
4. **Ask Questions:** Open GitHub issues if unclear
5. **Follow Standards:** Use Flutter/Dart best practices

## 🤝 Contributing

1. Read the [Architecture](docs/engineering/architecture/architecture.md) to understand code structure
2. Pick a user story from the [backlog](docs/product/user_stories/user_stories.md)
3. Check [Functional Requirements](docs/product/requirements/README.md) for details
4. Write tests following [Testing Strategy](docs/engineering/testing/testing_strategy.md)
5. Submit PR with clear description

## 📞 Need Help?

- **Documentation Issues:** Check [docs/README.md](docs/README.md)
- **Technical Questions:** Open a GitHub issue
- **Setup Problems:** See [Development Setup](docs/engineering/setup/development_setup.md)

## ✅ Checklist: Before You Start Coding

- [ ] I've read the product vision (README.md)
- [ ] I understand the user stories
- [ ] I've set up my development environment
- [ ] I understand the architecture
- [ ] I know how to run tests
- [ ] I've checked the current sprint priorities

---

**Ready to build something awesome? Let's go! 🚀**

*Last updated: 2026-02-07*
