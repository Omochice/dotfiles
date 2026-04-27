---
name: specified-test
description: |
    Pin the current behavior of legacy code with characterization tests before changing it.
    Use this skill BEFORE refactoring, bug-fixing, or migrating any code that has no tests, where the spec is unclear, or whenever the user mentions "characterization test", "specified test", "want to test the current behavior", , "want safety tests", "approval test", or "snapshot test for legacy code".
    Trigger this skill even when the user only says something like "this function has no tests, let me change X" — pinning the observed behavior first is what makes the upcoming change safe.
    For new features, or for code that already has tests, use the tdd skill instead.
---

# Specified Test (Characterization Test)

Pin the current behavior of existing code in a test before changing it.
The code itself becomes the spec, and each test records what the code does today — including any bugs.
Once the safety net is in place, refactoring, bug-fixing, or migration can proceed with regression detection.

In Michael Feathers' framing, _code without tests is legacy code_: not because it is old, but because no automated check tells you whether a change broke anything.
The job of this skill is to convert legacy code into non-legacy code by adding that check, faithfully and quickly, _without_ trying to fix it on the way.

## Two Mindsets, Two Skills

The mindset is _observation, not design_.
In Feathers' words: "document your system's actual behavior, not check for the behavior you wish your system had."
TDD writes a test for behavior the code _should_ have; this workflow writes a test for behavior the code _already_ has.
Mixing the two is the most common failure mode — an "expected" value invented from reading the source is how silent bugs get promoted to "spec".

Once a system goes into production, the running system becomes its own de facto specification.
Users build workflows on whatever it actually does, including its bugs.
That is precisely why we need to know when we are changing existing behavior, regardless of whether we think the behavior is right.

If the request is to add a brand-new feature or to change code that already has adequate tests, hand off to the tdd skill instead.

## Why we are doing this

State the business reason before starting and keep it visible.
Pinning behavior is not its own reward; it is the safety net for a _specific_ upcoming change (refactor, migration, feature, fix).
A characterization test that no one runs is dead weight; one that exists only because "tests are good" tends to be over-broad and never finished.
If the user cannot name the next change, ask. If the answer is "we just want more tests", narrow scope ruthlessly or recommend skipping.

Approach the work with curiosity, not dread.
"What does this code actually do when X?" is a question with an observable answer; "is this code correct?" is a question that needs a spec we may not have.
The first question is the one this skill answers.

## Phase 1: Choose the Scope

Identify the smallest piece of code worth pinning for the upcoming change:

- one function, one method, one class, or one entry point of an API
- the surface callers actually depend on, not every private helper

Record the scope and the reason in `.momomo/ai/specified-test-target.md`:

```markdown
# Target: <module#function>

## Why pin this

- Upcoming change: <what the user plans to do>
- Risk: <what could silently regress>

## Inputs / Outputs / Side effects

- Inputs: <args, env, globals>
- Outputs: <return value, exceptions>
- Side effects: <I/O, DB, logs, mutated state>
```

Confirm the scope with the user before moving on.
A scope that is too large produces fragile tests; a scope that is too small leaves blind spots near the change.

## Phase 2: Establish a Test Harness

Get the target running from a test, with no assertions yet.
This is the _seam_ (Feathers, _Working Effectively with Legacy Code_) — the place where the behavior can be observed without altering it.

Tactics, in order of preference:

1. Call the target as-is, supplying real inputs.
2. Inject fakes only for hard dependencies (clock, network, randomness, external services). Prefer interfaces the production code already exposes.
3. As a last resort, introduce a structural seam (extract a parameter, parameterize a constructor).
   Keep this change in its own commit _before_ any test commit, per the tidy-first rule.

Run the harness and confirm the target executes end-to-end.
If the target cannot be reached without sweeping structural changes, surface that to the user — the right next step may be to narrow the scope or to plan a larger refactor before continuing.

## Phase 3: Pin the Behavior

Use the deliberate-wrong-assertion technique to bypass thinking about expectations entirely:

1. Write an assertion that is _obviously wrong_ for the input.
   Example: `assertEquals("__not_yet_known__", subject.method(input))`.
2. Run the test. It fails, and the failure message reveals the actual output.
3. Replace the wrong value with the actual output. Re-run; the test now passes.
4. Name the test for what it pins.
   A practical pattern is to start with a placeholder name like `x` while you are still observing, then rename once the behavior is clear (Feathers' original suggestion).
   Final names should signal that the test records current behavior, not desired behavior — for example `characterizes_emptyInput_returnsNull` or `currentBehavior_negativeAmount_throws`.

Letting the test framework report the actual value is the point of this technique.
Reading the code and writing the "expected" output by hand reintroduces the very risk this skill exists to avoid.

When the actual output looks wrong, _do not fix it in this phase, and do not start hunting for more bugs_.
Whether something is a bug depends on context the test cannot see — production users may have built workflows around the very behavior you would "fix".
Pin it as-is, leave a FIXME that captures the suspicion, and address it later as a separate change:

```text
// FIXME(specified-test): negative amount returns 0 instead of raising. Verify intent.
```

Bug discovery is explicitly _not_ a goal.
Once you start auditing the legacy code for defects, the work has no end and no business value beyond the original change.
If a FIXME list grows past a handful of items, that is a signal to widen scope deliberately with the user, not to keep digging silently.

Commit each pinned behavior on its own:

```text
test: characterize <target> for <input shape>
```

## Phase 4: Expand Coverage Until Confident

Work outside-in. The first test should observe the coarsest user-visible behavior — display text, HTTP status, top-level return value — even if it pins almost nothing on its own.
A coarse net catches more accidental regressions per unit of effort than a fine one and lets the team feel progress quickly.
Only after the outer net is in place is it worth descending into branches and edge cases.

Extend coverage along the axes the upcoming change is likely to touch:

- typical inputs (the happy path the team relies on)
- boundaries (empty, zero, max, just-over-max)
- error cases (invalid input, missing dependency, concurrent access)
- branches a coverage tool reports as uncovered _and_ the planned change touches

Stop when the next test either fails to add a new assertion path or only confirms what an existing test already pins.
Coverage is a means, not the goal; the goal is that the planned change will trip a test if it regresses.
"Good enough now" beats "complete later" — partial pins committed today protect more than perfect pins never finished.

For bulky outputs (JSON payloads, rendered HTML, generated files), consider an approval / snapshot tool such as `insta`, `vitest`'s snapshot mode, or `ApprovalTests`.
The principle is unchanged: the _current_ output is the expected value, and the human only inspects the diff when it changes.

## Phase 5: Hand Off to the Real Change

Once the safety net is in place:

1. Tell the user the safety net is ready and summarize what it pins, _including what it deliberately leaves out_ so the boundary of the net is clear.
2. Confirm the tests run on the same trigger as the rest of the suite (CI, pre-commit, whatever the project uses).
   A characterization test that no one runs catches no regressions.
3. Hand control back to the workflow that motivated the pinning — refactoring, bug fix, or migration. The tdd skill applies cleanly from here on, because tests now exist.
4. Each suspect FIXME from Phase 3 becomes its own change after the motivating work lands: write a failing test that documents the desired behavior, fix the code, remove the FIXME. Keeping these separate keeps each diff focused on one intent.

## Anti-patterns to Avoid

### Writing the expected value from reading the code

Easy to copy a bug into the test and call it the spec.
Always let the test framework report the actual value first.

### Auditing for bugs while pinning

The job is to record, not to evaluate.
Suspect behaviors become FIXMEs; they do not become a parallel investigation that delays the safety net.

### Pinning private internals

Tests coupled to private helpers break during refactoring even when external behavior is preserved.
Pin observable outputs and side effects.

### Bundling the bug fix with the pin

Recording and changing serve different purposes; mixing them defeats the safety net.

### Chasing completeness

"Cover every branch before we touch the code" is how this practice loses to deadlines.
Stop at "the planned change will be caught if it regresses".

### Treating characterization tests as throwaway scaffolding

These are part of the suite now.
Tighten them periodically — narrow loose assertions, rename tests as understanding grows, fold in newly-discovered branches — but do not delete them as cleanup.
Replace the assertions only when the underlying behavior is intentionally changed.

## Guardrails

- Structural seam changes (Phase 2 step 3) are committed before any test commit, per tidy-first.
- Do not delete or "clean up" a failing characterization test because the assertion looks ugly.
  The ugliness is an artifact of legacy state; rewrite the test only when the underlying behavior is intentionally changed.
- The end-of-skill summary to the user must state both what is pinned and what is intentionally not pinned, so the user knows the boundary of the safety net.
- Do not start this workflow without an upcoming change in mind. "We should add tests someday" is not a scope; it is an open-ended task that the team will not finish.
