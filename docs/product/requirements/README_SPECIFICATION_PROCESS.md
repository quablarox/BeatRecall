# Specification Templates - BeatRecall

**Version:** 1.0  
**Last Updated:** 2026-02-07

---

## Purpose

This document explains the two-stage specification approach used in BeatRecall and when to use each template.

---

## Specification Stages

### Stage 1: Draft Specification (Current)

**Purpose:** Quick feature definition for planning and initial development

**When to Use:**
- During product planning phase
- For feature discovery and scoping
- When creating initial backlog items
- Before detailed implementation planning

**Structure:**
- Feature overview
- Requirements with IDs (e.g., `CARDMGMT-001`)
- Acceptance criteria
- Priority levels
- Basic notes and dependencies

**Benefits:**
- Fast to write and iterate
- Easy to understand for non-technical stakeholders
- Good for high-level planning
- Flexible for changes during discovery

**Current Examples:**
- [SRS.md](core/SRS.md)
- [FLASHSYS.md](core/FLASHSYS.md)
- [CARDMGMT.md](core/CARDMGMT.md)
- [DUEQUEUE.md](core/DUEQUEUE.md)

---

### Stage 2: Detailed Specification

**Purpose:** Granular implementation guide with function-level tracking

**When to Use:**
- Before starting implementation of a feature
- When requirement needs to be broken into tasks
- For complex features requiring coordination
- When tracking progress at function level
- For features that need detailed test coverage planning

**Structure:**
- Everything from Draft, plus:
- **Functions:** Sub-requirements with IDs (e.g., `CARDMGMT-001-F01`)
- **Status tracking:** Per function (Not Started, In Progress, Completed, Blocked)
- **Implementation details:** Technical approach, algorithms, data flow
- **Test coverage:** Gherkin scenarios linked to functions
- **Progress tracking:** Assigned to, effort estimates, completion dates
- **Metrics:** KPIs and success criteria
- **Risk assessment:** Identified risks and mitigation

**Benefits:**
- Granular progress tracking
- Clear assignment of work
- Testability at function level
- Better effort estimation
- Facilitates code reviews (reviewers know what to expect)

**Template:**
- [TEMPLATE_DETAILED_SPEC.md](TEMPLATE_DETAILED_SPEC.md)

---

## Migration Path: Draft → Detailed

When you're ready to implement a feature, follow these steps to create a detailed spec:

### Step 1: Copy the Template
```powershell
Copy-Item "docs\product\requirements\TEMPLATE_DETAILED_SPEC.md" `
          "docs\product\requirements\core\FEATURE_ID_detailed.md"
```

### Step 2: Fill in Header Information
- Replace `FEATURE_ID` with actual feature ID (e.g., `CARDMGMT`)
- Update version, date, status to "Detailed Spec"
- Copy feature overview from draft version

### Step 3: Break Requirements into Functions
For each requirement (e.g., `CARDMGMT-001`):
1. Identify 3-7 logical functions
2. Create function IDs: `CARDMGMT-001-F01`, `CARDMGMT-001-F02`, etc.
3. Write detailed description for each function
4. Define inputs, outputs, error handling

**Example:**
```
CARDMGMT-001: CSV Import
├── CARDMGMT-001-F01: Open file picker and read CSV file
├── CARDMGMT-001-F02: Parse CSV with header detection
├── CARDMGMT-001-F03: Validate each row
├── CARDMGMT-001-F04: Extract YouTube ID from URL
├── CARDMGMT-001-F05: Check for duplicates
├── CARDMGMT-001-F06: Import valid rows to database
├── CARDMGMT-001-F07: Generate import summary
└── CARDMGMT-001-F08: Display progress indicator
```

### Step 4: Add Status and Assignments
- Set initial status for each function (usually "Not Started")
- Assign to team members or leave unassigned
- Add effort estimates (story points or hours)

### Step 5: Write Test Scenarios
- Link Gherkin scenarios to specific functions
- Cover happy path and error cases
- Use `@FEATURE_ID-XXX-FXX` tags for traceability

### Step 6: Document Implementation Details
- Technical approach for each function
- Libraries/packages to use
- Design patterns to apply
- Performance considerations

### Step 7: Define Success Criteria
- KPIs for the feature
- Performance benchmarks
- Definition of Done checklist

---

## When to Stay in Draft vs. Upgrade to Detailed

### Stay in Draft If:
- Feature is straightforward and small (< 3 days work)
- Team is familiar with similar features
- Low risk of errors or edge cases
- Feature can be implemented as one atomic unit
- Quick iteration is more important than detailed tracking

**Examples:**
- Simple UI changes
- Configuration additions
- Minor bug fixes elevated to requirements

### Upgrade to Detailed If:
- Feature is complex (> 5 days work)
- Multiple developers will work on it
- High risk or critical functionality
- Needs coordination across layers (UI, service, data)
- Customer is waiting for specific delivery date
- Needs granular progress tracking for stakeholders
- Feature has many edge cases or error scenarios

**Examples:**
- CSV Import (CARDMGMT-001) - many validation rules
- SM-2 Algorithm (SRS-001) - complex logic
- Review Session (DUEQUEUE-002) - state management

---

## Best Practices

### DO:
✅ Start with draft specs for all features  
✅ Upgrade to detailed only when needed  
✅ Keep function IDs stable once created  
✅ Update status regularly (daily/weekly)  
✅ Link test scenarios to function IDs  
✅ Archive completed detailed specs for reference  

### DON'T:
❌ Create detailed specs for every requirement upfront  
❌ Change function IDs after tests are written  
❌ Skip the draft stage (too much overhead)  
❌ Create functions that are too granular (< 1 hour work)  
❌ Leave status unchanged for > 1 week  

---

## Function Naming Guidelines

### Good Function Names:
- `SRS-001-F01: Calculate interval for "Again" response`
- `FLASHSYS-002-F03: Handle network errors`
- `CARDMGMT-001-F05: Check for duplicates`

### Poor Function Names:
- ❌ `SRS-001-F01: Implement algorithm` (too vague)
- ❌ `FLASHSYS-002-F03: Fix bug` (not descriptive)
- ❌ `CARDMGMT-001-F05: Validation` (which validation?)

**Guidelines:**
- Use action verbs (Calculate, Handle, Check, Validate, Display)
- Be specific about what the function does
- Keep under 10 words
- Avoid jargon unless defined in glossary

---

## Status Definitions

| Status | Emoji | Meaning | Next Action |
|--------|-------|---------|-------------|
| **Not Started** | 🔴 | Work not begun | Assign and start |
| **In Progress** | 🟡 | Active development | Complete and test |
| **Completed** | 🟢 | Done and tested | Code review, merge |
| **Blocked** | 🔵 | Cannot proceed | Resolve blocker |
| **Deferred** | ⚪ | Postponed | Re-prioritize later |

---

## Example: Draft vs. Detailed

### Draft Version (SRS.md - current):
```markdown
### SRS-001: SM-2 Algorithm Implementation
**Priority:** High
**Status:** Not Started

**Acceptance Criteria:**
- System calculates next review date based on user response
- Ease factor adjusts based on performance
- Interval calculation follows SM-2 formula
```

### Detailed Version (after upgrade):
```markdown
### SRS-001: SM-2 Algorithm Implementation
**Priority:** High
**Status:** In Progress (3/7 functions completed)

#### SRS-001-F01: Calculate interval for "Again" response
**Status:** 🟢 Completed
**Assigned To:** John Doe
**Completed:** 2026-02-08
- Reset to learning mode (1 day interval)
- Reset repetitions to 0

#### SRS-001-F02: Calculate interval for "Hard" response
**Status:** 🟡 In Progress
**Assigned To:** John Doe
**Started:** 2026-02-09
- Shorter interval than standard
- Decrease ease factor by 0.15
- [80% complete - writing tests]

#### SRS-001-F03: Calculate interval for "Good" response
**Status:** 🔴 Not Started
- Standard interval calculation
- Ease factor unchanged

...
```

---

## Related Documents

- [TEMPLATE_DETAILED_SPEC.md](TEMPLATE_DETAILED_SPEC.md) - Full template with all sections
- [Core Requirements](core/README.md) - Current draft specifications
- [Glossary](../GLOSSARY.md) - Domain terminology
- [Architecture](../../engineering/architecture/architecture.md) - Technical implementation

---

## Questions?

If you're unsure whether to create a detailed spec:
1. Ask the team lead or architect
2. Consider effort: > 5 days = probably yes
3. Consider risk: critical feature = probably yes
4. When in doubt, start with draft and upgrade later
