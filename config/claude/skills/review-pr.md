---
name: review-pr
description: Triage review comments on a GitHub PR or GitLab MR for validity and implement approved fixes
---

# PR Comment Review & Implementation

Review the comments on a GitHub pull request or a GitLab merge request, evaluate their validity, implement approved fixes, and reply with the outcome.
"PR" below means either.

The skill runs in rounds of five phases and stops when a round fetches nothing new.
Nothing is posted publicly before the user has seen the exact text in the Phase 3 table.

## Platform

The platform is decided by the host of the `origin` remote, read with `git remote get-url origin`.
GitHub uses the `gh` CLI and GitLab uses the `glab` CLI.

`gh api` expands `{owner}` and `{repo}`, and `glab api` expands `:id`, so those placeholders are written literally.

## Phase 1: Fetch Comments

When the user passes a PR number, use it; otherwise resolve it from the current branch.

### GitHub

GitHub keeps comments in three places, and each is fetched separately.

1. Identify the PR.

   ```sh
   gh pr view --json number,url
   ```

1. Collect the inline review comments.
   `line` is null on an outdated comment and `original_line` locates it; `start_line` marks a range comment; `in_reply_to_id` marks a reply.

   ```sh
   gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate \
     --jq '.[] | {id, user: .user.login, path, line, start_line, original_line, in_reply_to_id, diff_hunk, body}'
   ```

1. Collect the review bodies and the general PR comments.

   ```sh
   gh api repos/{owner}/{repo}/pulls/{number}/reviews --paginate --jq '.[] | {id, user: .user.login, body}'
   gh pr view {number} --json comments
   ```

### GitLab

GitLab keeps every comment in a discussion, so one endpoint returns all of them.

1. Identify the MR.

   ```sh
   glab mr view --output json --jq '{iid, web_url}'
   ```

1. Collect the discussions.
   `system` notes are activity entries and are dropped; `position` is null on a discussion not attached to the diff; the first note is the original comment and later notes are replies.

   ```sh
   glab api projects/:id/merge_requests/{iid}/discussions --paginate \
     --jq '.[] | {id, notes: [.notes[] | select(.system | not) | {id, author: .author.username, body, position: (.position | if . then {new_path, new_line, old_line} else null end)}]} | select(.notes | length > 0)'
   ```

### Exclusions

A comment is one reviewer finding about this PR, and the API objects do not map onto findings one to one.
An object that carries no finding (an empty review body, a bot walkthrough, a deployment or CI notice), an object that repeats a finding already triaged (a bot review body restating its own inline comments), and any reply this skill authored (body starting with `[Claude Code]`) are excluded from triage and receive no reply.

## Phase 2: Triage Comments

For each comment, evaluate the following.

1. **Scope Check**
    - Is this feedback about changes in the current PR?
    - A comment with `line` null is outdated, not out of scope; read `diff_hunk` and the current file, because the point often still holds and only the fix changes shape.
    - A comment on a change already in the branch is Valid with no implementation step, and the reply names the commit that contains the fix.

1. **Factual Verification**
    - A claim that is about to be rejected publicly MUST be checked against the code, the tooling, or the live state, not reasoned about: apply the suggested change and run the linter or tests, query the setting the reviewer asserts, or write the test the claim predicts will fail.

### Assessment Values

A bot reviewer cannot answer a question and is often wrong, so a bot comment is never Questionable and the factual verification above is mandatory for it.

- **Valid**: the point holds and should be acted on.
- **Incorrect**: the point is in scope but factually wrong about the code.
- **Questionable**: the point may hold but needs a human reviewer's input to decide.
- **Out of Scope**: the comment is about code this PR does not change.

### Triage Output Format

For each comment, present the following.

- **Comment**: Original feedback text
- **Author**: Who wrote it
- **File/Line**: Location of the comment, using `original_line` when `line` is null
- **Assessment**: Valid | Incorrect | Questionable | Out of Scope
- **Reasoning**: Why this assessment, including what was run or checked
- **Proposed Action**: Implement | Implement differently | Discuss with reviewer | Skip
- **Implementation Plan**: If implementing, how
- **Reply Draft**: For every action other than Implement, the exact reply body to be posted

## Phase 3: User Confirmation

Present a summary table.
The table is required even for a single comment.

| #   | Comment Summary | Assessment   | Action                | Destination   | Reply Draft                                        |
| --- | --------------- | ------------ | --------------------- | ------------- | -------------------------------------------------- |
| 1   | ...             | Valid        | Implement             | inline thread | (commit hash, decided later)                       |
| 2   | ...             | Valid        | Implement differently | inline thread | `[Claude Code] addressed differently in {hash}: …` |
| 3   | ...             | Questionable | Discuss               | inline thread | `[Claude Code] …?`                                 |
| 4   | ...             | Incorrect    | Skip                  | PR comment    | `[Claude Code] not fixing: …`                      |

Ask the user to approve the plan as-is, modify specific items, or add clarifications.

**Do not proceed until user confirms.**

## Phase 4: Implementation

For each approved item, in order:

1. Implement the change.
1. Run tests if applicable.
1. Commit, ending the body with the URL of the comment it answers.
   Several comments that describe one change share one commit.
1. If implementation reveals issues, pause and discuss.

The comment URL takes one of these forms.

| Platform | URL                                                                                                                                                                                                                      |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| GitHub   | `https://github.com/{owner}/{repo}/pull/{number}#` followed by `discussion_r{comment_id}` for an inline comment, `pullrequestreview-{review_id}` for a review body, or `issuecomment-{comment_id}` for a general comment |
| GitLab   | `{web_url}#note_{note_id}`                                                                                                                                                                                               |

## Phase 5: Push, Then Reply

A reply may name only a hash that is final on the remote, so replies are posted after the push, in a single batch, using the bodies approved in Phase 3.

1. Ask the user to push with the single word "push".
1. After the user confirms, post every reply.

Every reply starts with `[Claude Code]` and takes the form for its action.

- **Implement**: `[Claude Code] fixed in {commit hash}` with no other text.
- **Implement differently**: `[Claude Code] addressed differently in {commit hash}: {what was done, and why not as suggested}`.
- **Discuss with reviewer**: `[Claude Code] {question that asks for the reviewer's input}`.
- **Skip**: `[Claude Code] not fixing: {reason}`.

A reply MUST NOT be reworded from what Phase 3 approved beyond filling in placeholders.
Bodies are written to a file first and posted from it, because shell quoting strips backticks from an inline body.

### Replying to Comments

The destination depends on where the comment came from, not on its triage outcome.
On GitHub only inline review comments have a thread; the other two sources are answered with a new PR comment that quotes the original.
On GitLab every comment belongs to a discussion and the reply goes into it, addressed by the discussion id, not the note id.

| Platform | Source                                             | Reply destination                                                                                                                   |
| -------- | -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| GitHub   | Inline review comment (`/pulls/{n}/comments`)      | `gh api -X POST repos/{owner}/{repo}/pulls/{n}/comments/{comment_id}/replies -F body=@{file} --jq '{id, in_reply_to_id, html_url}'` |
| GitHub   | Review body or general PR comment                  | `gh pr comment {number} --body-file {file}`                                                                                         |
| GitLab   | Any discussion                                     | `glab api -X POST projects/:id/merge_requests/{iid}/discussions/{discussion_id}/notes -F body=@{file} --jq '{id, body}'`            |

The GitHub replies endpoint accepts only inline review comment ids, so the id MUST be taken from the response that produced the comment.

## Rounds

A push triggers bot reviewers again, so after the replies are posted the skill returns to Phase 1.
The exclusions drop the replies just posted, so anything left is new; if there is any, continue with Phase 2 and number the items after the previous table, otherwise report that and stop.
A fresh invocation on an already-processed PR is the same round.
