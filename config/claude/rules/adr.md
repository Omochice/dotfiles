---
paths:
  - "**/doc/adr/**"
  - "**/docs/adr/**"
---

# Architecture Decision Record

This document defines how the content of an Architecture Decision Record (ADR) is written, whether a skill or a direct request leads to the change.
How an ADR is created or updated belongs to the adr and adr-update skills.

An ADR captures one decision for a future reader who was not there when it was made.
It must be self-contained and honest about trade-offs.

## Writing

- The title names the decision, not the problem ("Node.js TypeScript Type Stripping Migration", not "Build is slow").
- Split a multi-part Decision into numbered subsections, each with its own `#### Rationale` explaining why this alternative won, never what the code does.
- Consequences need real negatives, because every decision costs something, and each is paired with a mitigation.
- Prefer concrete artifacts (before/after code, failing output, exact config) over prose.
- Write plain prose without RFC 2119 keywords (MUST, SHOULD, MAY), because an ADR is a record, not a specification.
- Write in English unless existing ADRs use another language.
- Link related ADRs relatively (`[3. Use PostgreSQL](0003-use-postgresql.md)`).
  Supersedes and amends links in the Status section are written by `adrs`, never by hand.

## Changing an existing ADR

- The body of an existing ADR (Context, Decision, Consequences) is immutable once written.
  Later understanding goes into a new ADR, never edited into the old one.
- The only section that may change is Status, which is lifecycle metadata, not part of the record.
- Never delete or renumber ADR files.
