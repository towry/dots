---
description: "Sync user feedback and ideas into Kiro specs"
agent: kiro
model: "github-copilot/gpt-5"
---

# User Input
$ARGUMENTS

You MUST consider the user input before proceeding (if not empty).

# Goal
Synchronize the user's feedback, questions, and ideas into the living Kiro spec with clear traceability and minimal, precise edits.

# Process
1. Classify the input
   - Question
   - New requirement
   - Design adjustment
   - Manual test feedback / Bug
   - Clarification
   - Out-of-scope

2. Impact analysis
   - Identify affected REQs, design sections, tasks, and tests.
   - Note risks, dependencies, and constraints.

3. Apply updates to specs
   - New requirement
     - Create REQ-<next-number> in requirements.md with:
       - Title
       - Description
       - Rationale
       - Acceptance Criteria
       - Traceability Links (tasks, tests)
   - Design adjustment
     - Update relevant sections in design.md.
     - Append ADR entry to decision-log.md: ADR-YYYYMMDD-<nn> with Context, Decision, Consequences, Alternatives.
   - Manual test feedback / Bug
     - Add BUG-<next-number> to tasks.md (or bugs.md if present) with:
       - Repro Steps, Expected vs Actual, Environment, Severity/Priority
     - Link to affected REQ and planned fix task(s).
     - Add/adjust test cases in tests.md.
   - Question / Clarification
     - Update requirements.md acceptance criteria or glossary.
     - Optionally add a brief Q&A note for future reference.
   - Out-of-scope
     - Record in a Backlog section with rationale and potential timing.

4. Maintain traceability
   - Ensure REQ -> tasks -> tests links are present and updated.
   - Reference ADRs and changelog entries where relevant.

5. Summarize changes
   - Prepare a concise "Spec Changes" summary suitable for changelog.md.
   - List "Next Actions" as concrete, assignable tasks.
   - List "Open Questions" if any remain.

# Output
Produce the following sections:
- Spec Changes
- Updated Artifacts (file paths and exact sections to edit)
- Next Actions
- Open Questions

# Constraints
- Keep edits minimal but precise; prefer modifying specific sections over rewriting files.
- Preserve existing IDs; use next sequential numbers for REQ-, BUG-, ADR-.
- Write clear, testable acceptance criteria.
