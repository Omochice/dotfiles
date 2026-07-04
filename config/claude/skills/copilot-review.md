---
name: copilot-review
description: |-
    Have the local GitHub Copilot CLI (gpt-5.4) review the current diff, then iterate — Claude proposes fixes, the user approves, fixes are applied, and Copilot re-reviews — until Copilot converges on no findings.
    Use when the user wants an external Copilot/gpt-5.4 review loop, a second-opinion review that runs to convergence, or says "copilotにレビューさせて".
---

# Copilot Review Loop

Drive a review-and-fix loop where the local GitHub Copilot CLI is the reviewer and Claude is the implementer.
Copilot reviews the target diff and reports findings.
Claude triages them, proposes fixes, obtains user approval, applies the approved fixes, and asks Copilot to review again.
The loop ends when Copilot reports no remaining findings or a guard stops it.

Copilot provides an independent, external perspective. Claude never lets Copilot edit files; the two roles stay separated.

## Prerequisites

The loop depends on the `copilot` CLI being installed and authenticated.
Confirm it before starting.

```sh
copilot --version
```

The reviewer model is `gpt-5.4`.
It is fixed on purpose.
If a Copilot invocation fails with `Model "gpt-5.4" ... is not available`, stop the loop and report the error to the user.
Do not silently downgrade to another model, because the value of this skill is the specific reviewer.

## Review Scope

The default scope is the current diff:
uncommitted working-tree changes plus the commits on the current branch that are not on the main branch.

Resolve the scope before the first review pass.

```sh
git status --short
git merge-base HEAD main
git diff main...HEAD --stat
git diff --stat
```

If the user passes an argument (a path, a set of files, or a commit range), use that as the scope instead.
State the resolved scope back to the user before the first review pass.

## The Copilot Invocation

Run Copilot non-interactively in read-only reviewer mode.
Copilot may run `git` and read files through `bash` and `view`, but it MUST NOT modify anything, so the file-editing tools are denied and the prompt reinforces the constraint.

```sh
copilot -p "$REVIEW_PROMPT" \
  -s \
  --model gpt-5.4 \
  --allow-all-tools \
  --deny-tool=create \
  --deny-tool=edit \
  --no-color
```

`-s` limits stdout to Copilot's response.
`--allow-all-tools` is required for non-interactive execution.
`--deny-tool=create` and `--deny-tool=edit` remove the tools that write files.

### Review Prompt

Construct `$REVIEW_PROMPT` so Copilot inspects the resolved scope and ends its response with a machine-detectable verdict. Include the scope description and these instructions.

- You are a code reviewer.

    Inspect the changes in the described scope using git and file reads. Do not modify any file.

- Report only actionable findings:

    correctness bugs, security issues, broken behavior, and clear design or maintainability problems.
    For each finding, give the file and line, the problem, and why it matters.
    Do not report style nits already handled by a formatter.

- If, and only if, there are no actionable findings, say so explicitly.

- End your response with exactly one final line, and nothing after it:

    either
    `REVIEW_VERDICT: APPROVED` when there are no actionable findings, or
    `REVIEW_VERDICT: CHANGES_REQUESTED` when there is at least one.

The final `REVIEW_VERDICT:` line is the convergence signal for the loop.

## Loop

Run the loop with an iteration counter and a guard.

1. Run the Copilot review pass over the resolved scope.

1. Read Copilot's response and its final `REVIEW_VERDICT:` line.
    - `APPROVED`: the loop has converged. Report the result and stop.
    - `CHANGES_REQUESTED`: continue to triage.

1. Triage each finding for validity before acting on it.
    - Is the finding about code inside the review scope?
    - Is it correct given the current codebase and dependency versions?
    - Does the suggested direction fit existing patterns in the repository?
    - Classify each as Valid, Questionable, or Out of scope, with reasoning.

1. Present the findings and the proposed fixes to the user as a plan, then ask for approval.

    Do not apply any change until the user approves.
    The user may approve all, approve a subset, reject items, or amend the plan.

1. Apply the approved fixes.

    Follow the repository's commit and change conventions.
    Keep structural and behavioral changes in separate commits, with structural changes first.

1. Increment the iteration counter and return to step 1 to re-review.

### Guards

The loop must terminate even when Copilot keeps finding issues.

- Stop after 5 iterations by default and report the state to the user, who can choose to continue.
- If a review pass returns findings that are materially identical to the previous pass and the user declined to change them, stop and report the impasse rather than looping.
- If the user rejects the entire proposed plan for an iteration, stop the loop and report, rather than re-reviewing an unchanged tree.
- If any Copilot invocation errors (including model unavailability), stop and report the error.

## Reporting

When the loop ends, summarize the outcome for the user.

- The final verdict and how many iterations ran.
- What was changed across the iterations, referencing the commits.
- Any findings that were left unaddressed and why, including items the user declined and any impasse that stopped the loop.
