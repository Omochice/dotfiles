---
name: take-git
description: |-
    Operate the local repository with no long-lived local branches:
    stay on a detached HEAD at the remote default branch, and create a local branch only while working on a change.
disable-model-invocation: true
---

# take-git

Keep the local repository free of local branches so that the remote is the only place branches live.
Direct commits to the default branch, work on an unintended branch, and stale bases during conflict resolution all come from local branches that drift from the remote; holding none removes their cause.

## Resolve the default branch

The default branch is not always `main`, so resolve it from the remote before anything else and use it wherever `<default>` appears below.

```sh
git fetch --prune --prune-tags
git symbolic-ref --short refs/remotes/origin/HEAD
```

When `origin/HEAD` is unset, run `git remote set-head origin --auto` and resolve it again.

## Clean up local branches

Move to a detached HEAD at the remote default branch, then delete every local branch including `<default>` itself.

```sh
git switch --detach origin/<default>
git branch --format='%(refname:short)'
git branch -D <branch>
```

`-D` discards commits that exist nowhere else, so check each branch before deleting it.
A branch whose commits are not on its upstream, or which has no upstream, MUST be reported to the user, and it MUST NOT be deleted until the user confirms.
A branch checked out in another worktree cannot be deleted; report it instead of removing the worktree.
Uncommitted changes in the working tree MUST be reported before switching, and they MUST NOT be stashed or discarded without the user's confirmation.

The expected end state is that `git branch` lists only `(HEAD detached at origin/<default>)`.

## Start a change

Always fetch first and branch from `origin/<default>`, never from whatever HEAD happens to be.

```sh
git fetch --prune --prune-tags
git switch --create <branch> origin/<default>
```

Use the `feature/` prefix only when the repository has no naming convention of its own; follow the existing convention otherwise.

## Finish a change

Push the branch and open a GitHub pull request or a GitLab merge request, whichever the `origin` host serves.
Pushing is the user's action, so ask the user to run `git push -u origin <branch>` rather than running it.

Once the pull request or merge request is under review, return to the detached default branch and delete the local branch, as in "Clean up local branches".
The pushed branch on the remote is now the only copy, which is intended.

## Address review comments

Recreate the local branch from the remote branch, fix, ask the user to push, and delete it again.

```sh
git fetch --prune --prune-tags
git switch <branch>
```

`git switch <branch>` creates a local branch tracking `origin/<branch>` when no local branch exists.

## Check out someone else's pull request or merge request

Check it out detached so that reviewing does not create a local branch.

```sh
git fetch --prune --prune-tags
git switch --detach origin/<branch>
```

Checking out by number differs by host, because the two CLIs do not offer the same options.
Tell the host apart by the `origin` URL, or by whether `gh` or `glab` recognizes the repository.

On GitHub, `gh pr checkout --detach` checks out by number without creating a local branch.

```sh
gh pr checkout --detach <number>
```

On GitLab, `glab mr checkout` always creates a local branch and has no detached mode, so it MUST NOT be used here.
Fetch the merge request ref that GitLab publishes instead, which also covers merge requests from forks.

```sh
git fetch origin merge-requests/<iid>/head
git switch --detach FETCH_HEAD
```

<!--
Acknowledgment

This skill is based https://www.takeokunn.org/posts/fleeting/20250518144557-local_git_branch_operation
-->
