# BeatRecall Documentation

**Version:** 1.0  
**Last Updated:** 2026-02-08  
**Status:** Planning Phase (Week 2)

---

## 📖 Quick Start

- [Getting Started](../GETTING_STARTED.md) - Project setup and first steps
- [Main README](../README.md) - Project vision and overview

---

## 📋 Product Documentation

### Core Documents
- **[Product Glossary](product/GLOSSARY.md)** - Ubiquitous language and terminology
- **[User Stories](product/user_stories/user_stories.md)** - Features from user perspective
- **[Development Roadmap](product/roadmap/roadmap.md)** - Timeline and milestones

### Requirements (Core Features)
- **[Requirements Overview](product/requirements/core/README.md)** - Feature structure and IDs
- [SRS - Spaced Repetition System](product/requirements/core/SRS.md) - SM-2 algorithm (SRS-001 to 003)
- [FLASHSYS - Flashcard System](product/requirements/core/FLASHSYS.md) - Card UI and player (FLASHSYS-001 to 004)
- [CARDMGMT - Card Management](product/requirements/core/CARDMGMT.md) - CSV import and CRUD (CARDMGMT-001 to 005)
- [DUEQUEUE - Due Queue Management](product/requirements/core/DUEQUEUE.md) - Review sessions (DUEQUEUE-001 to 002)

### Requirements (Additional Features)
- [DASHBOARD - Dashboard](product/requirements/additional/DASHBOARD.md) - Statistics overview (DASHBOARD-001)

### Specification Process
- [Specification Process](product/requirements/README_SPECIFICATION_PROCESS.md) - How to write detailed specs
- [Detailed Spec Template](product/requirements/TEMPLATE_DETAILED_SPEC.md) - Template for new features

---

## 🏗️ Engineering Documentation

### Architecture
- **[Architecture Overview](engineering/architecture/architecture.md)** - Layered architecture, principles, priorities
- **[API Contracts](engineering/architecture/api_contracts.md)** - Complete project structure, interfaces, DI setup

### Development Setup
- [Development Setup](engineering/setup/development_setup.md) - Environment configuration

### Testing
- **[Testing Strategy](engineering/testing/testing_strategy.md)** - Unit/Integration/E2E approach

### Non-Functional Requirements
- **[Non-Functional Requirements](engineering/non_functional/non_functional_requirements.md)** - Performance, security, usability, offline-first

---

## 🚀 Quick Start by Role

### 👨‍💻 **Developers**
**Path:** Engineering → Product
1. Read [Engineering Documentation](engineering/README.md) overview
2. Follow [Development Setup](engineering/setup/development_setup.md)
3. Study [Architecture](engineering/architecture/architecture.md)
4. Check [Product Requirements](product/README.md) for features to implement
5. Use [Testing Strategy](engineering/testing/testing_strategy.md) for quality

### 📋 **Product Managers**
**Path:** Product → Engineering (for technical constraints)
1. Start with [Product Documentation](product/README.md)
2. Review [User Stories](product/user_stories/user_stories.md) for backlog
3. Check [Roadmap](product/roadmap/roadmap.md) for planning
4. Reference [Functional Requirements](product/requirements/README.md) for acceptance criteria
5. Understand [Non-Functional Requirements](engineering/non_functional/non_functional_requirements.md) for quality gates

### 🧪 **QA/Testers**
**Path:** Both Product & Engineering
1. Study [Testing Strategy](engineering/testing/testing_strategy.md) for test approach
2. Use [Functional Requirements](product/requirements/README.md) for acceptance criteria
3. Validate [Non-Functional Requirements](engineering/non_functional/non_functional_requirements.md) metrics
4. Reference [User Stories](product/user_stories/user_stories.md) for user scenarios

### 🎨 **Designers**
**Path:** Product first
1. Read [User Stories](product/user_stories/user_stories.md) for user needs
2. Review [Functional Requirements](product/requirements/README.md) for UI specs
3. Check [Non-Functional Requirements](engineering/non_functional/non_functional_requirements.md) for accessibility

---

## � Development Guidelines

### Coding Standards
- **[Copilot Instructions](../.github/copilot-instructions.md)** - AI coding guidelines and principles
- **[Commit Conventions](../.github/commit-conventions.md)** - Commit message format

### Key Principles
- **Single Source of Truth:** Avoid duplication, reference authoritative sources
- **Domain Language:** Use exact terms from [GLOSSARY.md](product/GLOSSARY.md) (Flashcard not Card)
- **SRS Correctness > UI Polish:** Algorithm must be correct above all else
- **Testing:** 70% Unit, 20% Integration, 10% E2E with feature IDs (@SRS-001)

---

## 📂 Documentation Structure

```
docs/
├── README.md (this file)          # Documentation hub
│
├── product/                       # WHAT & WHY
│   ├── GLOSSARY.md                # Domain terminology
│   ├── requirements/
│   │   ├── core/                  # MVP features
│   │   │   ├── SRS.md
│   │   │   ├── FLASHSYS.md
│   │   │   ├── CARDMGMT.md
│   │   │   └── DUEQUEUE.md
│   │   └── additional/            # Post-MVP features
│   │       └── DASHBOARD.md
│   ├── user_stories/
│   │   └── user_stories.md
│   └── roadmap/
│       └── roadmap.md
│
└── engineering/                   # HOW
    ├── architecture/
    │   ├── architecture.md
    │   └── api_contracts.md
    ├── setup/
    │   └── development_setup.md
    ├── testing/
    │   └── testing_strategy.md
    └── non_functional/
        └── non_functional_requirements.md
```

---

## 🔗 External References

- **Flutter Documentation:** https://flutter.dev/docs
- **Isar Database:** https://isar.dev/
- **Provider State Management:** https://pub.dev/packages/provider
- **YouTube Player Flutter:** https://pub.dev/packages/youtube_player_flutter
- **SM-2 Algorithm:** https://www.supermemo.com/en/archives1990-2015/english/ol/sm2

---

## 📝 Living Documents

These documents must be kept in sync when their sources change:

- **README.md** - Update when features, tech stack, or data model change
- **copilot-instructions.md** - Update when new principles or architecture changes
- **roadmap.md** - Update when requirements change or sprints complete
- **user_stories.md** - Update when requirements change or features added/removed

---

## 🚀 Current Phase: Phase 0 (Week 2)

**Status:** Planning & Setup

**Next Steps:**
- Finalize UI mockups
- Set up Flutter project
- Initialize Git repository
- Configure CI/CD pipeline

**Sprint Planning:** See [Roadmap](product/roadmap/roadmap.md)

---

## �📖 Document Relationships

```
docs/
    │
    ├─→ product/                    (WHAT & WHY)
    │   ├── requirements/           ← Linked from user stories
    │   ├── user_stories/           ← Start here for planning
    │   └── roadmap/                ← Timeline & priorities
    │
    └─→ engineering/                (HOW)
        ├── architecture/           ← References product requirements
        ├── setup/                  ← Prerequisite for development
        ├── testing/                ← Validates product requirements
        └── non_functional/         ← Constrains all implementation
```

---

## ✅ How to Use

### During Planning:
- **Product Team:** Review user stories → Functional requirements → Roadmap
- **Engineering Team:** Review architecture constraints and NFRs

### During Development:
- **Developers:** Product requirements → Architecture → Testing strategy
- **QA:** Functional requirements + NFRs → Testing strategy

### During Review:
- Verify user stories fulfilled (product)
- Check acceptance criteria met (requirements)
- Validate quality standards (NFRs + testing)

---

## � Questions or Issues?

- Check the [GLOSSARY](product/GLOSSARY.md) for terminology
- Review [User Stories](product/user_stories/user_stories.md) for context
- Consult [Architecture](engineering/architecture/architecture.md) for technical decisions
- Open an issue on GitHub for bugs or feature requests

---

*Last updated: 2026-02-08*  
*Maintained by: BeatRecall Development Team*
