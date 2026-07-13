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

Keep the body short.
A reviewer should grasp the change in a few seconds, and the diff already carries the line-level detail, so favor brevity over completeness.
Most PRs/MRs need only a few sentences in total.

Follow these formatting rules so the body renders correctly as Markdown:

- Do not hard-wrap.
  Never break a single sentence across multiple lines to fit a column width.
  Markdown collapses such a break into one space, so the wrapping helps no reader and only fights the renderer.
- Separate each sentence with a blank line so it renders as its own paragraph.
  Consecutive lines with no blank line between them collapse into a single paragraph, which is rarely what is intended.

Use the following template structure.
Keep every section, and write each one concisely rather than omitting it.

##### Summary

States what this PR/MR changes, in a single sentence.

##### Details

Explains why the change was needed and why this approach was chosen over alternatives, in free-form prose rather than bullet lists.
Keep it to a sentence or two.

##### Confirmation

Records what the author verified locally and the observed outcome, not a checklist for reviewers to run.
Items that were not verified belong in the Limitation section instead.
If no local verification was performed, state "No local verification was performed."

##### Limitation

Describes known limitations, edge cases not covered, or follow-up work that remains.
If none exist, state "No known limitations."

#### Example body

The following shows the intended length and line-break style, with every section kept and each sentence standing as its own paragraph.

```markdown
## Summary

Cache the rendered navigation menu so it is built once per request instead of once per component.

## Details

The menu was rebuilt for every sidebar component, which dominated render time on list pages.

Memoizing per request keeps the data fresh across requests while removing the repeated work.

## Confirmation

Ran the page locally and confirmed the menu renders identically with one build per request.

## Limitation

No known limitations.
```

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

If `includeCoAuthoredBy` or `attribution.pr` has specified, include the trailers.

Report the resulting PR/MR URL to the user.
