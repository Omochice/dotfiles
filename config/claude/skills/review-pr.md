---
name: review-pr
description: Triage PR review comments for validity and implement approved fixes systematically
---

# PR Comment Review & Implementation

Systematically review GitHub PR comments, evaluate their validity, and implement approved fixes.

## Workflow

### Phase 1: Fetch PR Comments

Run `/pr-comments` to fetch review comments from the current branch's PR.

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

### Phase 3: User Confirmation

Present a summary table:

| #   | Comment Summary | Assessment   | Action    |
| --- | --------------- | ------------ | --------- |
| 1   | ...             | Valid        | Implement |
| 2   | ...             | Questionable | Discuss   |

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

1. Mark todo as completed
1. Move to next item

### Important Guidelines

- One commit per issue/comment
- Never batch multiple fixes in one commit
- Use conventional commit format
- Reference the original comment in commit body
- Run tests after each fix if applicable
- If implementation reveals issues, pause and discuss
