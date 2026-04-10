---
name: tdd
description: |
    Apply Test-Driven Development (TDD) workflow for feature implementation and bug fixes.
    Use this skill whenever the user asks to implement a feature, fix a bug, or write code — not only when they explicitly say "TDD".
    Trigger on phrases like "implement this", "add this feature", "fix this bug", "write code for", as well as explicit "TDD" or "test-driven" requests.
---

# Test-Driven Development

Guide development through Kent Beck's TDD cycle: write a failing test, make it pass with minimal code, then improve the design.
Each step produces its own commit because the repository uses squash merge, so granular history aids review without polluting the final merge.

## Phase 1: Build the Test List

Analyze the requested behavior and write a test list to `.momomo/ai/test-list.md`. Each entry describes one observable behavior, not an implementation detail.

```markdown
# Test List: <feature or fix summary>

- [ ] <behavior 1>
- [ ] <behavior 2>
- [ ] <behavior 3>
```

This phase is purely about understanding **what** the system should do.
Do not make implementation design decisions here — those belong in the Refactor phase.

Present the test list to the user and wait for confirmation before proceeding.
The user may add, remove, or reorder items.

## Phase 2: Red — Write a Failing Test

Pick **one** item from the test list and translate it into an executable test.
Run the test suite and confirm the new test fails.
A test that passes immediately means either the behavior already exists or the test is not checking the right thing — investigate before moving on.

After confirming the failure, commit:

```text
test: add failing test for <behavior>
```

## Phase 3: Green — Make It Pass

Write the simplest code that makes the new test pass **and** keeps all existing tests passing.
Resist the urge to write "clean" or "general" code at this stage — that comes next.
The goal is a passing test suite as quickly as possible.

Run the full test suite (excluding long-running tests) to verify.
Then commit:

```text
feat: implement <behavior>
```

Choose the commit type based on user-facing impact: `feat` for new capability, `fix` for a bug fix, and so on.

## Phase 4: Refactor — Improve the Design

With a green test suite as your safety net, improve the code structure: remove duplication, clarify naming, extract or inline functions.
This is where implementation design decisions belong.

Run the test suite after each structural change.
If anything breaks, revert the last change and try a smaller step.

Commit only if changes were made:

```text
refactor: <what was improved>
```

If no refactoring is needed, skip this phase entirely.

## Phase 5: Update and Repeat

Mark the completed item in `.momomo/ai/test-list.md` by changing `- [ ]` to `- [x]`.
Return to Phase 2 with the next item.
Continue until every item is checked off.

## Fixing a Defect

When the task is a bug fix rather than a new feature, follow an additional discipline before Phase 2:

1. Write an API-level failing test that demonstrates the bug from the user's perspective.
2. Write the smallest possible test that isolates the root cause.
3. Proceed with Phase 3 to fix both tests.

This two-level approach ensures the fix addresses the real problem and prevents regression at both the unit and integration levels.

## Writing Good Tests

Kent Beck's "Programmer Test Principles" define what makes a test worth keeping.
Apply these when writing tests in Phase 2.

### Test behavior, not structure

Write tests against externally observable behavior.
Avoid coupling tests to internal implementation details such as private methods, field names, or call order.
A test that breaks when you refactor without changing behavior is a test coupled to structure — rewrite it to assert on outputs and side effects instead.

### Prioritize readability

Tests are read far more often than they are written.
Name each test so that a reader immediately understands what behavior is being verified.
Keep the test body short and its intent obvious.

### Minimize change cost

When a single behavior change forces updates to many tests, the tests are likely duplicating assertions or sharing too much setup.
Extract shared context into helpers, or reduce the number of tests that verify the same behavior from different angles.

### Run deterministically

Tests that depend on wall-clock time, network calls, random values, or shared mutable state produce flaky results.
Use stubs, fakes, or dependency injection to make each test reproducible.

## Guardrails

- Run the full test suite before every commit, not just the new test.
- If a test is difficult to write, that is a signal about the design — consider simplifying the interface rather than writing a complex test.
