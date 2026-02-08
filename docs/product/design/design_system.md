# Design System - BeatRecall

## 📋 Overview

This document defines the core design system for BeatRecall. **UI screens are specified in [User Stories](../user_stories/user_stories.md)** and will be implemented iteratively without detailed mockups.

**Approach:** Agile, iterative UI development based on user stories  
**Last Updated:** 2026-02-08

---

## 🎨 Design System

### Colors
- **Primary:** Spotify Green (#1DB954)
- **Background:** Dark (#121212)
- **Surface:** Gray (#282828)
- **Text:** White (#FFFFFF), Gray (#B3B3B3)
- **Accent:** Purple (#8B5CF6) for secondary actions
- **Status Colors:**
  - Success: Green (#10B981)
  - Warning: Orange (#F59E0B)
  - Error: Red (#EF4444)
  - Info: Blue (#3B82F6)

### Typography
- **Headers:** Roboto Bold, 24-32px
- **Body:** Roboto Regular, 16px
- **Captions:** Roboto Regular, 14px
- **Code/Monospace:** Roboto Mono, 14px

### Spacing
- **Padding:** 16dp (standard), 24dp (large)
- **Card Margin:** 12dp
- **Button Height:** 48dp (minimum touch target)
- **Icon Size:** 24dp (standard), 32dp (large)

### Components
- **Buttons:** Material Design 3 style, 48dp height, rounded corners (8dp)
- **Cards:** Elevated surface, 12dp border radius, subtle shadow
- **Input Fields:** Outlined style, clear error states
- **Navigation:** Bottom navigation bar (mobile), side drawer (tablet)

---

## 📱 Screen References

All UI specifications are defined in user stories:

- **Dashboard:** `@SETTING-001` ([DASHBOARD.md](../requirements/additional/DASHBOARD.md))
- **Quiz/Review:** `@SRS-001`, `@FLASHSYS-001` ([User Stories](../user_stories/user_stories.md#epic-1))
- **Library:** `@CM-002`, `@CM-003` ([User Stories](../user_stories/user_stories.md#epic-2))
- **Add/Edit Card:** `@CM-001`, `@CM-002` ([User Stories](../user_stories/user_stories.md#epic-2))
- **Settings:** `@SETTING-001` ([User Stories](../user_stories/user_stories.md#epic-4))

---

## 🎯 Design Principles

1. **Clarity:** Users must immediately understand card status and due dates
2. **Accessibility:** High contrast, large touch targets (min 44x44dp)
3. **Feedback:** Clear visual feedback for all actions (loading, success, error)
4. **Consistency:** Follow Material Design 3 (Android) / Human Interface Guidelines (iOS)
5. **Iterative:** Build, test, refine based on user feedback

---

## 🔄 Development Workflow

1. **Read user story** → Understand requirements
2. **Implement UI** → Use design system guidelines
3. **Test with users** → Gather feedback
4. **Iterate** → Refine based on learnings

**No detailed mockups required** - user stories + design system are sufficient for iterative development.

---

## 🔗 References

- [User Stories](../user_stories/user_stories.md) - UI requirements and flows
- [Dashboard Requirements](../requirements/additional/DASHBOARD.md)
- [Glossary](../GLOSSARY.md) - Terminology for UI labels
- [Material Design 3](https://m3.material.io/)
- [Flutter Design Patterns](https://flutter.dev/docs/development/ui)

---

*Living document - Update as design decisions are made during implementation*
