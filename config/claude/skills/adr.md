---
name: adr
description: |
    Write a new Architecture Decision Record (ADR) in the t-wada style.
    Use when the user wants to record an architectural, design, tooling, or migration decision — "write an ADR", "ADRを書いて", "record this decision", "document why we chose X" — or to turn a design discussion or finished migration into a decision document.
    Creates new ADRs only; updating or superseding an existing ADR is the adr-update skill's job.
---

# Writing an Architecture Decision Record

An ADR captures one decision for a future reader who was not there when it was made.
It must be self-contained and honest about trade-offs.

## 1. Gather the decision

Make sure the conversation or diff at hand can fill every section of the skeleton below: the triggering force (Context), what was decided (Decision), which alternatives were rejected and why (Considered Options), and what gets worse (Consequences).
Ask the user for anything missing — a fabricated rationale is worse than no ADR, because future readers will trust it.

## 2. Determine location and number

```bash
fd -i 'adr' docs/ 2>/dev/null || ls docs/adr/ 2>/dev/null || ls docs/ 2>/dev/null
```

If ADRs exist, follow their naming, numbering, and directory convention exactly (read a recent one to match style) and take the next number.
Otherwise create `docs/adr-001-<kebab-case-slug>.md`.
Write in English unless existing ADRs use another language.

## 3. Choose the shape

Include `Decision Drivers` and `Considered Options` only when multiple alternatives were genuinely evaluated — the rejected options are the most valuable part, because they prevent the same evaluation from being redone.
When one clear force drove the decision (e.g. a forced migration), skip both sections; empty options are noise.

## 4. Write the ADR

ALWAYS use this skeleton (sections marked _(options form)_ only when alternatives were evaluated):

```markdown
# ADR-NNN: <Decision Title>

## Status

Proposed | Accepted

## Context

<What situation and forces led to this decision. State the problem concretely;
 include failing output, code, or links where they make the force tangible.>

## Decision Drivers *(options form)*

* **<Driver>**: <what this decision must satisfy>

## Considered Options *(options form)*

### Option 1: <Name>

<Concrete illustration of the option, ideally a code or output example.>

**Pros:**
- ...

**Cons:**
- ...

## Decision

<What we will do, stated in the future or present tense ("We will ...").>

### 1. <Sub-decision>

**Change from**: <before, as code>
**Change to**: <after, as code>

**Rationale**: <why this specific choice, not a restatement of the change>

## Consequences

### Positive

1. **<Benefit>**: <explanation>

### Negative

1. **<Cost>**: <explanation>

### Mitigations

- <How each negative consequence is contained>

## Implementation Notes

<Optional: constraints for whoever implements this — what must be tested,
 what must stay backward compatible.>

## References

- <Optional: links to discussions, issues, related ADRs, prior art>
```

Rules:

- The title names the decision, not the problem ("Node.js TypeScript Type Stripping Migration", not "Build is slow").
- `Proposed` before the work happens, `Accepted` once in effect — never any other initial status.
- Split a multi-part Decision into numbered subsections, each with its own before/after and `**Rationale**:` explaining why this alternative won, never what the code does.
- Consequences need real negatives — every decision costs something — each paired with a mitigation.
- Prefer concrete artifacts (before/after code, failing output, exact config) over prose.
- Plain prose; no RFC 2119 keywords (MUST, SHOULD, MAY) — an ADR is a record, not a specification.
- Link related ADRs relatively (`[ADR-003](./adr-003-....md)`).

## 5. Review before presenting

Reread as a reader with no access to this conversation: does the Context alone explain why doing nothing was unacceptable, is every rationale a "why" rather than a "what", and are the negatives honest?
Fix what fails, then present the file path and a one-paragraph summary of the recorded decision.
