# Product Documentation - BeatRecall

## 📋 Overview

This directory contains product-focused documentation - **what** we're building and **why**. This is the primary reference for Product Managers, Stakeholders, and anyone interested in understanding the product vision and features.

---

## 📚 Documents

### 1. [Glossary](GLOSSARY.md)
**Purpose:** Ubiquitous Language - domain terms used consistently across all documentation and code

**Contents:**
- Domain terms (Flashcard, SRS, Ease Factor, Interval, Rating, etc.)
- Technical terms (YouTube ID, Validation, Duplicate Detection)
- Card lifecycle terminology (New, Learning, Review)
- Usage guidelines for consistent communication

**Use this when:** You need clarification on terminology or want to ensure consistent language across the team.

---

### 2. [Functional Requirements](requirements/README.md)
**Purpose:** Detailed specification of all app features and functionality

**Contents:**
- Core MVP requirements (SRS, flashcards, card management, CSV import)
- Phase 2 enhancements (audio trimming, fuzzy matching, auto-metadata)
- Additional features (dashboard, settings)
- Future backlog (tags, ChatGPT integration, multiple decks, learning sessions)
- Cross-cutting requirements

**Use this when:** You need to understand what features to implement and their acceptance criteria.

---

### 3. [User Stories](user_stories/user_stories.md)
**Purpose:** User-centered descriptions focusing on **why** users need features and the value delivered

**Contents:**
- Epic 1: Core Learning Experience
- Epic 2: Card Management (including CSV import)
- Epic 3: Enhanced Learning Features
- Epic 4: Information and Settings
- Epic 5: User Experience Enhancements
- Epic 6: Advanced Features (Future)

**Use this when:** You need to understand the user's perspective and needs.

---

### 4. [Project Roadmap](roadmap/roadmap.md)
**Purpose:** Development timeline and milestones

**Contents:**
- Phase 0: Planning & Setup (2 weeks)
- Phase 1: Core MVP (8 weeks)
- Phase 2: Enhanced Features (6 weeks)
- Phase 3: Advanced Features (8 weeks)
- Phase 4: Future Roadmap
- Milestones and success metrics
- Risk management
- Release strategy

**Use this when:** You need to understand project timeline, priorities, and planning.

---

## 🚀 Quick Start

### For Product Managers:
1. Review **Glossary** for domain terminology
2. Review **User Stories** to understand user value
3. Check **Roadmap** for timeline and priorities
4. Reference **Functional Requirements** for detailed scope
5. Use these docs to create sprint backlogs and epics

### For Stakeholders:
1. Check **Glossary** for terminology clarification
2. Read **User Stories** to understand what we're building
3. Review **Roadmap** for release dates
4. Check **Functional Requirements** for feature completeness

---

## 📖 Document Relationships

```
Product Documentation
    │
    ├─→ Glossary ─────defines terms for──→ All documents
    │
    ├─→ User Stories ─────links to──→ Functional Requirements
    │                                         │
    │                                         └─→ Roadmap (timeline)
    │
    └─→ All work together to define WHAT we build
```

---

## ✅ How to Use These Documents

### During Planning:
- Start with **User Stories** to create sprint backlog
- Follow links to **Functional Requirements** for acceptance criteria
- Check **Roadmap** for scheduling and dependencies

### During Stakeholder Reviews:
- Present progress using **User Stories** as reference
- Show completed vs. planned using **Roadmap** milestones
- Discuss scope changes with **Functional Requirements**

---

## 🔗 Related Documentation

For technical implementation details, see [Engineering Documentation](../engineering/README.md).

---

*Last updated: 2026-02-07*  
*Maintained by: BeatRecall Product Team*
