# GitHub Copilot Instructions - BeatRecall

## Project Overview

BeatRecall: Flutter mobile app for music recognition training using Spaced Repetition System (SM-2 algorithm).

**Stack:** Flutter 3.0+ | Dart 3.0+ | Isar DB | YouTube Player | Provider

**Phase:** Planning & Setup (Week 2)

---

## Single Source of Truth

**Principle:** Avoid duplicating content from `docs/` in these instructions. Always reference the authoritative source.

**Rules:**
- ✅ **Include:** Stable, general principles (naming conventions, layer rules, core terminology)
- ❌ **Avoid:** Detailed specs, algorithm formulas, feature requirements, user stories
- 📝 **When needed:** Create separate file (e.g., `code-style.md`) and reference it

**Examples:**
- ✅ "Use Flashcard, not Card" (terminology guideline)
- ❌ SM-2 formula details → Reference `docs/product/requirements/core/SRS.md`
- ✅ "4-layer architecture: Presentation → Service → Domain → Data" (general rule)
- ❌ Complete API contracts → Reference `docs/engineering/architecture/api_contracts.md`

**Why:** Changes should be made in one place only. Documentation drift causes inconsistencies.

---

## Living Documents

**Some docs must be updated when their referenced sources change:**

📄 **README.md** - Overview document
- Update when: Core features, tech stack, or data model change
- References: Requirements, architecture, glossary
- Keep in sync with: Feature IDs, terminology, entity names

📄 **GETTING_STARTED.md** - Quick start guide
- Update when: Project structure changes, setup steps change, key links change
- Keep in sync with: docs/README.md navigation, development setup

📄 **copilot-instructions.md** (this file)
- Update when: New core principles, architecture changes, new conventions
- Keep minimal: Only stable, general rules

📄 **docs/product/roadmap/roadmap.md**
- Update when: Requirements change, priorities shift, sprints complete
- Keep in sync with: Feature IDs, user stories, requirements

📄 **docs/product/user_stories/user_stories.md**
- Update when: Requirements change, features added/removed
- Keep in sync with: Requirements links, feature IDs

**When changing a source document, check if these living documents need updates.**

---

## Architecture

**4-Layer Architecture:**  
Presentation → Service → Domain → Data

**Rules:**
- Dependencies flow downward only
- Use interfaces for layer communication
- Dependency injection for testability

**Details:** `docs/engineering/architecture/api_contracts.md`

---

## Domain Language

**Always use terminology from `docs/product/GLOSSARY.md`**

**Key terms (examples):**
- **Flashcard** (NOT Card, SongCard)
- **Ease Factor** (NOT Difficulty)
- **Rating:** Again (0), Hard (1), Good (3), Easy (4)

**Complete definitions:** `docs/product/GLOSSARY.md`

---

## Code Conventions

**Naming:**
- Classes: PascalCase (`Flashcard`, `SrsService`)
- Variables: camelCase with domain language (`nextReviewDate`, `easeFactor`)
- Functions: Verb phrases (`fetchDueCards()`, `calculateNextInterval()`)
- Constants: UPPER_SNAKE_CASE (`DEFAULT_EASE_FACTOR`)
- Files: snake_case.dart, tests: `*_test.dart`

---

## Key Principles

- **SRS Correctness:** Follow SM-2 algorithm exactly → `docs/product/requirements/core/SRS.md`
- **Testing:** Use feature IDs (`@SRS-001`) + Given-When-Then → `docs/engineering/testing/`
- **Architecture:** Respect layer boundaries, use DI → `docs/engineering/architecture/api_contracts.md`
- **Domain Language:** Use exact terms from GLOSSARY → `docs/product/GLOSSARY.md`

---

## Documentation References

**Consult when needed:**
- Requirements: `docs/product/requirements/core/`
- API Contracts: `docs/engineering/architecture/api_contracts.md`
- Glossary: `docs/product/GLOSSARY.md`
- Roadmap: `docs/product/roadmap/roadmap.md`
- Testing: `docs/engineering/testing/testing_strategy.md`

**Commit Messages:** `.github/commit-conventions.md`

---

## Documentation References
**Consult when needed:**
- Requirements: `docs/product/requirements/core/`
- API Contracts: `docs/engineering/architecture/api_contracts.md`
- Glossary: `docs/product/GLOSSARY.md`
- Roadmap: `docs/product/roadmap/roadmap.md`
- Testing: `docs/engineering/testing/testing_strategy.md`

**Commit Messages:** `.github/commit-conventions.md`

---

## Don't Do This ❌

- ❌ Wrong terminology: `SongCard`, `difficulty`, `successStreak`
- ❌ Breaking layer boundaries (UI → Database directly)
- ❌ Magic numbers without constants
- ❌ Unclear names: `n`, `ef`, `List<dynamic>`

---

## Project Context

**See:**
- Platform decisions: `docs/engineering/non_functional/non_functional_requirements.md`
- Development priorities: `docs/engineering/architecture/architecture.md`