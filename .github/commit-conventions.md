# Commit Message Conventions - BeatRecall

> **Note:** This file defines commit message format only. For domain language and feature details, see `docs/product/`

## Format

```
type(scope): subject [FEATURE-ID]

- Bullet point describing change 1
- Bullet point describing change 2
```

---

## Types

`feat` | `fix` | `docs` | `test` | `refactor` | `style` | `chore`

---

## Scopes

`srs` | `flashsys` | `cardmgmt` | `duequeue` | `dashboard` | `requirements` | `architecture` | `testing`

---

## Feature IDs

Include feature ID in brackets: `[FEATURE-ID]`

**Core Features (MVP):**
- **SRS-001 to 003** - Spaced Repetition System
- **FLASHSYS-001 to 004** - Flashcard System
- **CARDMGMT-001 to 005** - Card Management
- **DUEQUEUE-001 to 002** - Due Queue Management
- **DASHBOARD-001** - Dashboard

**Multiple Features:** `[SRS-001, FLASHSYS-001]`  
**No Feature ID:** Infrastructure/tooling commits (chore, style)

---

## Rules

**Subject:**
- Imperative mood ("add", not "added")
- Max 72 characters (including `[FEATURE-ID]`)
- No period at end
- Lowercase after colon

**Body:**
- Bullet points with `- ` prefix
- Explain **WHAT and WHY**, not HOW
- Use domain language from `docs/product/GLOSSARY.md`
- List concrete changes in logical order

---

## Examples

```
feat(cardmgmt): implement CSV import with duplicate detection [CARDMGMT-001]

- Add CsvImportService with file parsing logic
- Validate YouTube URLs and extract video IDs
- Detect duplicates by YouTube ID before import
- Show import summary with success/error/duplicate counts
```

```
fix(flashsys): prevent YouTube player autoplay on card flip [FLASHSYS-002]

- Disable autoplay parameter in YouTubePlayer widget
- Add manual play button on front side
- Preserve playback state across card flips
```

```
docs(requirements): add detailed dashboard specification [DASHBOARD-001]

- Create DASHBOARD.md with 7 functions (21 story points)
- Define metrics calculation logic (success rate, streak)
- Add Gherkin test scenarios for each function
```

```
refactor(architecture): reorganize documentation structure

- Split docs into product/ and engineering/ folders
- Replace numbered IDs with feature-based IDs (SRS-001, etc.)
- Add GLOSSARY.md with ubiquitous language
```

---

## References

- Feature IDs: `docs/product/requirements/core/`
- Domain Language: `docs/product/GLOSSARY.md`
- Conventional Commits: https://www.conventionalcommits.org/
