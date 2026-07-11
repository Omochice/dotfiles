---
name: adr-update
description: |
    Update an existing Architecture Decision Record (ADR) in the t-wada style: accept a proposed ADR, record a design evolution, or supersede a decision whose premise no longer holds.
    Use when the user wants to change an ADR that already exists — "update the ADR", "ADRを更新して", "mark ADR-003 as accepted", "supersede ADR-002", "the implementation diverged from the ADR" — or after a migration or policy change invalidates a recorded decision.
    Writing an ADR for a brand-new decision is the adr skill's job.
---

# Updating an Architecture Decision Record

An ADR is a historical record.
The body of an existing ADR (Context, Decision, Consequences) is immutable once written — later understanding goes into a new ADR, never edited into the old one.
The only line that may change is Status, which is lifecycle metadata, not part of the record.

## 1. Locate and read the target ADR

```bash
fd -i 'adr' docs/ 2>/dev/null || ls docs/adr/ 2>/dev/null || ls docs/ 2>/dev/null
```

Any new ADR created below follows the existing naming, numbering, and directory convention exactly, with the next sequential number.

## 2. Classify the change

Ask one question: **if a reader followed the old ADR today, would they go wrong?**

- **Not wrong** — only the lifecycle moved → _Case A: lifecycle update_
- **Partially wrong** — the decision stands, specific sub-decisions changed → _Case B: design evolution_
- **Wholly wrong** — the decision should no longer be followed → _Case C: supersession_

If unclear, ask the user; the three cases produce very different edits.

### Case A: Lifecycle update

Change the Status line in place, typically `Proposed` to `Accepted`.
No new ADR, no other edits — knowledge gained during implementation that changes a design choice is Case B, not an edit to Context or Decision.

### Case B: Design evolution

1. Create the new ADR, titled `# ADR-NNN: Design Evolution from ADR-MMM`.
   In `## Context`, state what triggered the refinement (typically implementation feedback), link to the source ADR, and say that this ADR exists to keep the design-evolution record visible.
2. Record each change as a numbered subsection under `## Design Changes from ADR-MMM`, with concrete code where it makes the change tangible:

    ```markdown
    ### 1. <What changed>

    **Original Design (ADR-MMM)**: <as originally recorded>

    **Revised Design**: <as implemented or now intended>

    **Rationale**: <why the revision won — what the original design missed>
    ```

3. Mark the old ADR: keep its Status value and append the back-link, e.g. `Accepted (refined by [ADR-NNN](./adr-NNN-<slug>.md))`.
   Not `Superseded` — the old ADR is still the primary record of the overall decision.

### Case C: Supersession

1. Create the new ADR as a complete, self-contained ADR (the structure the adr skill produces).
   Its `## Context` explains which premise no longer holds and links to the old ADR.
2. Replace the old ADR's Status content with `Superseded by [ADR-NNN](./adr-NNN-<slug>.md)`.
   Never delete the old file.

## Rules for every case

- Every premise change (Case B or C) produces exactly two edits: the new ADR references the old one, and the old ADR's Status links forward.
  The forward link is what saves a reader who lands on the old ADR via search from following a stale decision.
- In the old ADR, touch only the Status line; if the diff shows changes anywhere else, undo them.
- Never delete or renumber ADR files.
- Write new ADRs in English unless existing ADRs use another language, in plain prose without RFC 2119 keywords.
- The project's existing structural conventions win over the templates above when they differ.

## Review before presenting

Check that the old ADR's diff touches only the Status line, the new ADR stands alone for a reader who has never seen the old one, and both link directions resolve as relative paths.
Fix what fails, then present the changed and created file paths with a one-paragraph summary.
