---
name: create-pr
description: |
    Create a GitHub Pull Request or GitLab Merge Request from the current branch.
    Use this skill whenever the user wants to create a PR, MR, pull request, or merge request, or says things like "open a PR", "submit for review", "create MR", or "send this for review".
    Also trigger when the user asks to prepare a PR description or draft a merge request.
---

# PR / MR Creation

Create a Pull Request (GitHub) or Merge Request (GitLab) from the current branch by analyzing the branch diff and generating a structured title and description.

## Workflow

### Phase 1: Detect Platform

Determine whether the repository uses GitHub or GitLab by inspecting the remote URL.

```bash
git remote get-url origin
```

If the URL contains `github.com`, use the `gh` CLI.
If it contains `gitlab`, use the `glab` CLI.
If neither pattern matches, ask the user which platform to use.

### Phase 2: Determine Base Branch

Identify the target branch for the PR/MR.

```bash
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null
```

If this fails, fall back to checking whether `main` or `master` exists on the remote.
If still ambiguous, ask the user.

### Phase 3: Verify Remote Branch

Confirm that the current branch has been pushed to the remote.

```bash
git ls-remote --heads origin $(git branch --show-current)
```

Verify the branch has commits ahead of the base branch.
If there are no new commits, inform the user and stop.

### Phase 4: Analyze Changes

Gather the commit history and diff against the base branch.

```bash
git log --oneline <base>..HEAD
git diff <base>...HEAD --stat
git diff <base>...HEAD
```

For large diffs, read `--stat` first and selectively inspect the most significant files rather than loading the entire diff at once.

### Phase 5: Generate Title and Description

#### Title

Format: `<type>: <description>`

The title appears in changelogs and release notes, so write it from the user's perspective.
Describe what changes for the user, not the internal implementation detail.
Use conventional commit types (`feat`, `fix`, `refactor`, `build`, `ci`, `chore`, `docs`, `perf`, `style`, `test`).
Keep it under 70 characters.

**Example:**

```text
feat: allow filtering search results by date range
```

Not:

```text
feat: add DateRangeFilter component to SearchPage
```

#### Description

Use the following template structure.

##### Summary

provides a concise statement of what this PR/MR changes.
One or two sentences at most.

##### Details

explains the background and reasoning behind the change.
Why was this change needed? Why was this approach chosen over alternatives? Write in free-form prose rather than bullet lists.

##### Confirmation

lists the verification steps a reviewer should perform to confirm correctness.

##### Limitation

describes known limitations, edge cases not covered, or follow-up work that remains.
If none exist, state "No known limitations."

### Phase 6: User Confirmation

Present all of the following to the user before proceeding:

- Platform (GitHub or GitLab)
- Base branch
- Whether draft mode is enabled
- Title
- Full description body

Do not proceed until the user explicitly confirms.
The user may request modifications to the title, description, base branch, or draft setting.

### Phase 7: Create PR/MR

For GitHub:

```bash
gh pr create --base <base> --title "<title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

For GitLab:

```bash
glab mr create --remove-source-branch --target-branch <base> --title "<title>" --description "$(cat <<'EOF'
<body>
EOF
)"
```

Add `--draft` to the command if draft mode was requested.

Report the resulting PR/MR URL to the user.
