# BeatRecall - Quick Start Guide

> **📚 Complete Documentation:** See [docs/README.md](docs/README.md) for full navigation by role

Welcome to BeatRecall! This is a **5-minute quick start** to get you oriented.

---

## 🎯 What is BeatRecall?

Flutter mobile app for **music recognition training** using **Spaced Repetition System (SM-2)** for pub quiz preparation.

**Tech Stack:** Flutter 3.0+ | Dart 3.0+ | Isar DB | YouTube Player | Provider

---

## 📖 1. Understand the Product (2 min)

### Start Here:
1. **[README.md](README.md)** - Product vision and overview
2. **[User Stories](docs/product/user_stories/user_stories.md)** - What users can do
3. **[Roadmap](docs/product/roadmap/roadmap.md)** - Current phase and priorities

### Key Concepts:
- **Flashcards** with YouTube audio/video on front, title/artist on back
- **SM-2 Algorithm** schedules reviews at optimal intervals
- **4 Rating Buttons:** Again (0), Hard (1), Good (3), Easy (4)
- **Offline-first:** All core features work without internet

---

## 🚀 2. Choose Your Path (3 min)

> **📚 Detailed paths:** See [docs/README.md](docs/README.md) for complete role-specific guides

### 👨‍💻 **Developer** → Start Coding

**Quick Path:**
1. [Development Setup](docs/engineering/setup/development_setup.md) - Environment setup
2. [Architecture](docs/engineering/architecture/architecture.md) - Code structure & naming
3. [API Contracts](docs/engineering/architecture/api_contracts.md) - Interfaces & DI
4. [Testing Strategy](docs/engineering/testing/testing_strategy.md) - How to test

**Quick Setup:**
```bash
# 1. Clone repository (when available)
git clone https://github.com/quablarox/BeatRecall.git
cd BeatRecall

# 2. Install Flutter: https://flutter.dev/docs/get-started/install

# 3. Get dependencies
flutter pub get

# 4. Run app
flutter run

# 5. Run tests
flutter test
```

**Key Principles:**
- **SRS Correctness > UI Polish** - Algorithm must be correct
- **Domain Language** - Use exact terms from [GLOSSARY](docs/product/GLOSSARY.md)
- **Test Coverage** - 70% minimum, 90% for business logic
- **Naming** - See [Architecture](docs/engineering/architecture/architecture.md#3-naming-conventions)

---

### 📋 **Product Manager** → Planning

**Quick Path:**
1. [Roadmap](docs/product/roadmap/roadmap.md) - Timeline & milestones
2. [User Stories](docs/product/user_stories/user_stories.md) - Feature backlog
3. [Requirements](docs/product/requirements/core/README.md) - Detailed scope

**Key Info:** MVP in 8 weeks | 20+ user stories | Phase 0 Week 2 (current)

---

### 🎨 **Designer** → UI/UX

**Quick Path:**
1. [User Stories](docs/product/user_stories/user_stories.md) - User needs
2. [Requirements](docs/product/requirements/core/README.md) - UI specs
3. [NFRs](docs/engineering/non_functional/non_functional_requirements.md) - Accessibility

**Key Screens:** Dashboard | Quiz | Library | Add/Edit Card

---

### 🧪 **QA Tester** → Testing

**Quick Path:**
1. [Testing Strategy](docs/engineering/testing/testing_strategy.md) - Approach
2. [Requirements](docs/product/requirements/core/README.md) - Acceptance criteria

**Test Priorities:** SRS algorithm | YouTube playback | Database | Performance

---

## 📂 3. Navigation & Resources

### Complete Documentation
- **[docs/README.md](docs/README.md)** - Central documentation hub with all links

### Key Documents by Category

**Product (WHAT & WHY):**
- [GLOSSARY](docs/product/GLOSSARY.md) - Terminology
- [Requirements](docs/product/requirements/core/README.md) - Features
- [User Stories](docs/product/user_stories/user_stories.md) - User perspective
- [Roadmap](docs/product/roadmap/roadmap.md) - Timeline

**Engineering (HOW):**
- [Architecture](docs/engineering/architecture/architecture.md) - Code structure & naming
- [API Contracts](docs/engineering/architecture/api_contracts.md) - Interfaces
- [Testing](docs/engineering/testing/testing_strategy.md) - Testing approach
- [NFRs](docs/engineering/non_functional/non_functional_requirements.md) - Quality standards

**Development:**
- [Setup Guide](docs/engineering/setup/development_setup.md) - Environment config
- [Copilot Instructions](.github/copilot-instructions.md) - AI coding guidelines
- [Commit Conventions](.github/commit-conventions.md) - Commit format

### External Resources
- [Flutter Docs](https://flutter.dev/docs)
- [Isar Database](https://isar.dev/)
- [YouTube API](https://developers.google.com/youtube/v3)
- [SM-2 Algorithm](https://www.supermemo.com/en/archives1990-2015/english/ol/sm2)

---

## 🎯 4. Current Status

**Phase 0 - Week 2:** Planning & Setup

**Completed:**
- ✅ Requirements & User Stories
- ✅ Architecture & API Contracts
- ✅ Testing Strategy
- ✅ Documentation Hub

**Next Steps:**
- ⏳ UI Mockups
- ⏳ Flutter Project Setup
- ⏳ CI/CD Pipeline

**See:** [Roadmap](docs/product/roadmap/roadmap.md) for details

---

## ✅ Quick Checklist

Before coding:
- [ ] Read [README.md](README.md) - Product vision
- [ ] Check [Roadmap](docs/product/roadmap/roadmap.md) - Current priorities
- [ ] Review [Architecture](docs/engineering/architecture/architecture.md) - Code structure
- [ ] Understand [GLOSSARY](docs/product/GLOSSARY.md) - Domain language

---

## 📞 Need Help?

- **Documentation:** [docs/README.md](docs/README.md) - Complete navigation
- **Technical Questions:** Open GitHub issue
- **Domain Language:** [GLOSSARY](docs/product/GLOSSARY.md)

---

*Last updated: 2026-02-08*
