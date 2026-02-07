# Additional Features - BeatRecall

**Version:** 1.0  
**Last Updated:** 2026-02-07  
**Status:** Mixed (Draft & Detailed Spec)

---

## Overview

This folder contains requirements for additional features that enhance the core learning experience but are not essential for MVP functionality. These features improve user experience, motivation, and data management.

---

## Feature Documents

### [DASHBOARD.md](DASHBOARD.md) - Dashboard Overview ⭐ Detailed Spec
**Feature ID:** `DASHBOARD`  
**Status:** Detailed Spec  
**Description:** Main screen displaying learning statistics, due cards count, success rate, and review streak.

**Requirements:**
- `DASHBOARD-001` - Overview Display (7 functions defined)

**Implementation Status:** Ready for development  
**Estimated Effort:** 21 story points / 3 weeks

---

### Settings (Draft - in parent folder)
**File:** [../03_additional.md](../03_additional.md)  
**Status:** Draft specification

**Features:**
- Application Settings (FR-3.2.1)
- Data Management (FR-3.2.2)

**Note:** Settings features remain in draft specification until implementation is prioritized.

---

## Numbering Convention

Additional features use the same feature-based identifier system as core features:
- **Format:** `<FEATURE_ID>-<NUMBER>-<FXX>` (for detailed specs)
- **Example:** `DASHBOARD-001`, `DASHBOARD-001-F01`, `DASHBOARD-001-F02`

---

## Specification States

| Feature | State | Next Action |
|---------|-------|-------------|
| **Dashboard** | ✅ Detailed Spec | Ready for implementation |
| **Settings** | 📝 Draft | Upgrade to detailed when prioritized |
| **Data Management** | 📝 Draft | Upgrade to detailed when prioritized |

---

## Priority Order

1. **DASHBOARD-001** (High Priority) - Main motivational screen
2. **Settings** (Medium Priority) - User customization
3. **Data Management** (Medium Priority) - Backup/restore functionality

---

## Related Documents

- [Glossary](../../GLOSSARY.md) - Domain terminology (Success Rate, Review Streak, Due Card)
- [Core Requirements](../core/README.md) - Foundation features Dashboard depends on
- [User Stories](../../user_stories/user_stories.md) - Story 4.1, 4.2, 4.3
- [Architecture](../../../engineering/architecture/architecture.md) - Technical implementation
