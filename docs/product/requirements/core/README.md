# Core Requirements - BeatRecall

**Version:** 1.0  
**Last Updated:** 2026-02-07  
**Status:** Draft

## Overview

This folder contains the core functional requirements for BeatRecall's MVP. Each feature is documented in a separate file with a unique identifier system for easier maintenance and test referencing.

## Feature Documents

### [SRS.md](SRS.md) - Spaced Repetition System
**Feature ID:** `SRS`  
**Description:** SM-2 algorithm implementation for optimal learning intervals, review scheduling, and performance tracking.

**Requirements:**
- `SRS-001` - SM-2 Algorithm Implementation
- `SRS-002` - Review Scheduling  
- `SRS-003` - Performance Tracking

---

### [FLASHSYS.md](FLASHSYS.md) - Flashcard System
**Feature ID:** `FLASHSYS`  
**Description:** Interactive flashcard interface with YouTube media playback and answer rating.

**Requirements:**
- `FLASHSYS-001` - Dual-Sided Card Interface
- `FLASHSYS-002` - YouTube Media Player
- `FLASHSYS-003` - Answer Rating
- `FLASHSYS-004` - Answer Input (Optional)

---

### [CARDMGMT.md](CARDMGMT.md) - Card Management
**Feature ID:** `CARDMGMT`  
**Description:** Create, edit, delete, search, and import flashcards.

**Requirements:**
- `CARDMGMT-001` - CSV Import ⭐ **High Priority**
- `CARDMGMT-002` - Manual Card Creation
- `CARDMGMT-003` - Card Editing
- `CARDMGMT-004` - Card Deletion
- `CARDMGMT-005` - Card Search and Filter

---

### [DUEQUEUE.md](DUEQUEUE.md) - Due Queue Management
**Feature ID:** `DUEQUEUE`  
**Description:** Manage and navigate through cards that are due for review.

**Requirements:**
- `DUEQUEUE-001` - Due Cards Retrieval
- `DUEQUEUE-002` - Review Session

---

## Numbering Convention

Requirements use a feature-based identifier system:
- **Format:** `<FEATURE_ID>-<NUMBER>`
- **Example:** `FLASHSYS-001`, `CARDMGMT-003`
- **Benefits:** 
  - Stable IDs even when requirements are reordered
  - Clear feature ownership
  - Easy reference from Gherkin tests (e.g., `@FLASHSYS-001`)
  - Supports status tracking per requirement

## Priority Levels

- **High:** Must-have for MVP launch
- **Medium:** Important but can be delayed if needed
- **Low:** Nice-to-have, can be deferred to Phase 2

## Document Evolution

### Current State (Draft)
Each feature document contains:
- Feature overview
- Individual requirements with descriptions
- Acceptance criteria
- Priority levels

### Future State (Detailed Spec)
Each requirement will be further subdivided into:
- **Functions:** Granular units of functionality
- **Function IDs:** e.g., `FLASHSYS-001-F01`, `FLASHSYS-001-F02`
- **Status:** Not Started, In Progress, Completed, Blocked
- **Test References:** Link to Gherkin scenarios

**How to Upgrade:**
See [README_SPECIFICATION_PROCESS.md](../README_SPECIFICATION_PROCESS.md) for the migration guide and use [TEMPLATE_DETAILED_SPEC.md](../TEMPLATE_DETAILED_SPEC.md) as a template.

**Example Future Structure:**
```
FLASHSYS-001: Dual-Sided Card Interface
├── FLASHSYS-001-F01: Render front side with YouTube player [Completed]
├── FLASHSYS-001-F02: Flip animation transition [In Progress]
├── FLASHSYS-001-F03: Render back side with metadata [Not Started]
└── FLASHSYS-001-F04: Keyboard shortcuts [Not Started]
```

---

## Related Documents

- [Glossary](../../GLOSSARY.md) - Ubiquitous Language definitions
- [User Stories](../../user_stories/user_stories.md)
- [Phase 2 Requirements](../02_phase2.md)
- [Future Features](../04_future.md)
- [Architecture](../../../engineering/architecture/architecture.md)
