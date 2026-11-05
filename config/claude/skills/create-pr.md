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

### Phase 5: Verify

Carry out every verification the change calls for that the available environment allows, such as running the changed command or checking the changed behavior by hand.
A verification that was possible but skipped is unfinished work, not something to disclose in the description, so do it instead of writing the PR/MR around it.

Note each verification that cannot be performed and its reason, because the Limitation section reports them.

If a verification reveals a problem, report it to the user and stop.

### Phase 6: Generate Title and Description

#### Title

Format: `<type>: <description>`

The title appears in changelogs and release notes, so write it from the user's perspective.
Describe what changes for the user, not the internal implementation detail.
Use conventional commit types (`feat`, `fix`, `refactor`, `build`, `ci`, `chore`, `docs`, `perf`, `style`, `test`).
Keep it under 70 characters.

Example:

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

Do not add caveats or disclaimers that tell the reviewer nothing they need to act on.
Test counts, passing tests or lints, and anything else CI already guarantees are redundant with the CI result.

##### Summary

States what this PR/MR changes, in a single sentence.

##### Details

Explains why the change was needed and why this approach was chosen over alternatives, in free-form prose rather than bullet lists.
Keep it to a sentence or two.

##### User Impact

Lists what changes for the user once this lands, one bullet per change:
new, changed, or removed behavior, and any migration step they have to take.
If nothing visible to the user changes, state "No user-visible impact."

##### Confirmation

Records what the author verified that CI cannot, such as manually checked behavior, and the observed outcome, not a checklist for reviewers to run.
If there is nothing beyond what CI covers, state "None."

##### Limitation

Describes known limitations of the change itself, edge cases not covered, or follow-up work that remains.
Anything the code structurally cannot guarantee belongs here, such as behavior that depends on external state or a race the design does not prevent.
A verification that could not be performed belongs here together with the reason, such as a required resource being unavailable (hardware, credentials, an external service) or the change targeting an OS other than the one available.
Never list a verification that was possible but skipped.
If none exist, state "No known limitations."

#### Example bodies

The following examples show the intended length and line-break style, with every section kept and each sentence standing as its own paragraph.

The first example has behavior to check by hand and no limitations.

```markdown
## Summary

Cache the rendered navigation menu so it is built once per request instead of once per component.

## Details

The menu was rebuilt for every sidebar component, which dominated render time on list pages.

Memoizing per request keeps the data fresh across requests while removing the repeated work.

## User Impact

- List pages render faster
- The menu itself looks and behaves the same

## Confirmation

Ran the page locally and confirmed the menu renders identically with one build per request.

## Limitation

No known limitations.
```

The second example has nothing to verify beyond CI, and reports a verification that the available OS cannot perform.

```markdown
## Summary

Read the config file from `$XDG_CONFIG_HOME` on Linux instead of a hard-coded `~/.config`.

## Details

Users who set `$XDG_CONFIG_HOME` had their config ignored.

Falling back to `~/.config` only when the variable is unset matches the XDG Base Directory Specification.

## User Impact

- The config file is found under `$XDG_CONFIG_HOME` when the variable is set

## Confirmation

None.

## Limitation

The Linux code path could not be run because only macOS was available.
```

### Phase 7: User Confirmation

Present all of the following to the user before proceeding:

- Platform (GitHub or GitLab)
- Base branch
- Whether draft mode is enabled
- Title
- Full description body

Do not proceed until the user explicitly confirms.
The user may request modifications to the title, description, base branch, or draft setting.

### Phase 8: Create PR/MR

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
