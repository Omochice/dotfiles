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
Everything in it has to stay true for as long as the decision holds, so anything that changes on a shorter cycle belongs somewhere else.

## Writing

- The title names the decision, not the problem ("Node.js TypeScript Type Stripping Migration", not "Build is slow").
- Context states the force that made doing nothing unacceptable as it actually happened in this project, not as a hypothetical.
  The forces the decision has to satisfy belong here too, instead of in a section of their own.
  Failing output or the exact constraint may be quoted where it makes the force tangible.
- Every premise is checked against the code or a primary source before it is written.
  A premise that cannot be checked is asked about, never guessed, because future readers will trust it.
- Decision states what we will do and why, at a granularity that leaves the implementation free.
  Ask whether replacing the chosen mechanism with another would force this ADR to be rewritten.
  If it would, that detail belongs in a specification, a code comment, or the PR description.
  A short example that shows the policy may stay; function names, constants, type definitions, and config values do not.
- Split a multi-part Decision into numbered subsections, each with its own `#### Rationale` explaining why this alternative won, never what the code does.
- Decision ends with `### Not Decided Here`, which names what this ADR leaves open and where that will be decided.
- Consequences need real negatives, because every decision costs something, and each is paired with a mitigation.
- A mitigation is described by the behavior that contains the cost (e.g. "startup fails when a migration is pending"), never by a test file or a function name, because those change more often than the decision.
- Write plain prose without RFC 2119 keywords (MUST, SHOULD, MAY), because an ADR is a record, not a specification.
- Write in English unless existing ADRs use another language.

## What stays out

- Migration plans, progress, checklists, and task tables, because they go stale once the work is done.
  A constraint that holds for the whole migration may stay, such as "both formats must be readable during the migration".
- Ticket, issue, and PR numbers or links in the body; external references go under References.
- References by line number, which shift with every edit.
- Dates other than the `Date:` line.

## References between ADRs

- Link related ADRs relatively (`[3. Use PostgreSQL](0003-use-postgresql.md)`).
- Refer to a part of another ADR by its number and title, such as `ADR-3, Decision 2 (Connection pooling)`.
- Supersedes and amends links in the Status section are written by `adrs`, never by hand.

## Status

- The status is one of `Accepted`, `Deprecated`, or `Superseded`.
- `Proposed` is not used, because an ADR is written once the decision is made, and a `Proposed` status left behind after merge misleads readers.
- `Rejected` is not used, because a rejected option is recorded under Alternatives Considered in the ADR that rejected it.
- The Status section holds only the status value and the link lines; reasons belong in Context.

## Changing an existing ADR

- The body of an existing ADR (Context, Decision, Consequences) is immutable once written.
  Later understanding goes into a new ADR, never edited into the old one.
- The only section that may change is Status, which is lifecycle metadata, not part of the record.
- Never delete or renumber ADR files.

## Tests that guard a decision

- A test that checks a decision's guarantee lives in a file named after the ADR (`NNNN-slug`), in the directory where the repository keeps its end-to-end tests.
  The ADR itself never names the test, so the test can move without the immutable body going stale.
- The test runs in the CI job that suits what it checks, which is not necessarily the end-to-end job.
- The test checks only the guarantee the ADR records; detailed behavior stays in the ordinary tests.
- The test is deleted when its ADR becomes `Deprecated` or `Superseded`.
