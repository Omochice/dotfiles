---
name: review-pr
description: Triage PR review comments for validity and implement approved fixes systematically
---

# PR Comment Review & Implementation

Systematically review GitHub PR comments, evaluate their validity, and implement approved fixes.

## Workflow

### Phase 1: Fetch PR Comments

Fetch review comments from the current branch's PR with the `gh` CLI.

1. Identify the PR for the current branch.

   ```sh
   gh pr view --json number,url
   ```

1. Collect the inline review comments.

   ```sh
   gh api repos/{owner}/{repo}/pulls/{number}/comments
   ```

1. Collect the review-level and general PR comments.

   ```sh
   gh api repos/{owner}/{repo}/pulls/{number}/reviews
   gh pr view {number} --json comments
   ```

### Phase 2: Triage Comments

For each comment, evaluate using these criteria:

#### Validity Criteria

1. **Scope Check**
    - Is this feedback about changes in the current PR?
    - Skip if commenting on unrelated code

1. **Knowledge Currency**
    - Is the feedback based on current best practices?
    - Check if libraries/APIs mentioned are up-to-date
    - Verify against official documentation if needed

1. **Performance Analysis**
    - Would the suggested change impact performance?
    - If original is more performant, note this

1. **Codebase Consistency**
    - Does the suggestion align with existing patterns?
    - Check naming conventions, file structure, coding style

#### Triage Output Format

For each comment, present:

- **Comment**: Original feedback text
- **Author**: Who wrote it
- **File/Line**: Location of the comment
- **Assessment**: Valid | Questionable | Out of Scope
- **Reasoning**: Why this assessment
- **Proposed Action**: Implement | Discuss with reviewer | Skip
- **Implementation Plan**: If implementing, how
- **Reply Draft**: For Discuss and Skip, the exact reply body to be posted

### Phase 3: User Confirmation

Present a summary table. Every comment gets a reply, so the reply body for
non-implemented items MUST be visible here before it is posted publicly.

| #   | Comment Summary | Assessment   | Action    | Reply Draft                   |
| --- | --------------- | ------------ | --------- | ----------------------------- |
| 1   | ...             | Valid        | Implement | (commit hash, decided later)  |
| 2   | ...             | Questionable | Discuss   | `[Claude Code] ...`           |
| 3   | ...             | Out of Scope | Skip      | `[Claude Code] not fixing: …` |

Ask user to:

- Approve the plan as-is
- Modify specific items
- Add clarifications

**Do not proceed until user confirms.**

### Phase 4: Implementation

For each approved item:

1. Add to TodoWrite with specific task
1. Mark as in_progress
1. Implement the change
1. Stage only relevant files (never `git add .`)
1. Commit with message format:

   ```text
   refactor: <description>

   <brief explanation of change>
   ```

   Commit type SHOULD be determine by user effect.
1. Reply to the comment as described in "Replying to Comments". The reply body MUST be exactly `[Claude Code] fixed in {commit hash}` with no other text.
1. Mark todo as completed
1. Move to next item

### Phase 5: Respond to Non-Implemented Comments

Comments triaged as Discuss or Skip receive a reply too, so the reviewer learns
the outcome instead of seeing silence. Post these after Phase 4 finishes, as a
single batch, using the reply bodies approved in Phase 3.

- **Discuss with reviewer**: `[Claude Code] {question that asks for the reviewer's input}`
- **Skip**: `[Claude Code] not fixing: {reason}`

Unlike the fixed reply, these carry the reason as their payload, so text beyond
the prefix is REQUIRED. A reply MUST NOT be reworded from what Phase 3 approved.

### Replying to Comments

The destination depends on where the comment came from, not on its triage
outcome. Only inline review comments have a reply thread; the other two sources
are answered with a new PR comment that quotes the original, because there is no
threading to identify what is being answered.

| Source                                            | Reply destination                                                                          |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Inline review comment (`/pulls/{n}/comments`)     | `gh api -X POST /repos/{owner}/{repo}/pulls/{n}/comments/{comment_id}/replies -f body=...` |
| Review body (`/pulls/{n}/reviews`)                | `gh pr comment {number} --body ...`                                                        |
| General PR comment (`gh pr view --json comments`) | `gh pr comment {number} --body ...`                                                        |

The replies endpoint accepts only inline review comment ids. Passing a review id
or an issue comment id to it fails, so the id MUST be taken from the same
response that produced the comment.

Every reply body MUST start with the `[Claude Code]` prefix, which marks the
reply as authored through Claude Code.

### Important Guidelines

- Every collected comment MUST end with exactly one reply, whether it was implemented or not.
- Each issue group MUST be fully resolved (implement, commit, reply) before moving to the next group. Do not process multiple groups in parallel.
- One commit per issue/comment
- Never batch multiple fixes in one commit
- Use conventional commit format
- Reference the original comment in commit body
- Run tests after each fix if applicable
- If implementation reveals issues, pause and discuss
