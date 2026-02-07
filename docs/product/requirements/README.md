# Functional Requirements - Index

## Document Information
- **Version:** 1.0
- **Last Updated:** 2026-02-07
- **Status:** Draft

---

## 📋 Specification Process

We use a **two-stage approach** for requirements:

1. **Draft Specification (current)** - Quick feature definition for planning
2. **Detailed Specification** - Granular function-level tracking for implementation

**Learn More:**
- [README_SPECIFICATION_PROCESS.md](README_SPECIFICATION_PROCESS.md) - When and how to use each stage
- [TEMPLATE_DETAILED_SPEC.md](TEMPLATE_DETAILED_SPEC.md) - Template for detailed specs

---

## Documents

### 1. [Core Functional Requirements](core/README.md)
**Purpose:** MVP features and core product behavior

**Contents:**
- **[SRS](core/SRS.md)** - Spaced repetition system (SM-2 algorithm)
- **[FLASHSYS](core/FLASHSYS.md)** - Flashcard experience with YouTube player
- **[CARDMGMT](core/CARDMGMT.md)** - Card management (CSV import, manual creation, editing)
- **[DUEQUEUE](core/DUEQUEUE.md)** - Due queue and review sessions

Each feature is documented in a separate file with stable identifiers (e.g., `SRS-001`, `FLASHSYS-002`) for easier maintenance and test referencing.

---

### 2. [Phase 2 Features](02_phase2.md)
**Purpose:** Enhanced learning and automation

**Contents:**
- Audio trimming
- Fuzzy matching
- Auto-metadata retrieval
- Playlist import

---

### 3. [Additional Features](03_additional.md)
**Purpose:** Dashboard and settings

**Contents:**
- Dashboard overview
- Application settings and data management

---

### 4. [Future Considerations](04_future.md)
**Purpose:** Ideas for later phases

**Contents:**
- Potential feature backlog
- Longer-term opportunities

---

### 5. [Cross-Cutting Requirements](05_cross_cutting.md)
**Purpose:** Performance, reliability, usability, and compatibility constraints

---

## How to Use
1. Start with **Core** for MVP scope.
2. Use **Phase 2** and **Additional** when planning enhancements.
3. Keep **Future Considerations** as a backlog.
4. Apply **Cross-Cutting Requirements** to all features.
