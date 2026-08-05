# Worktree

This document defines how a git worktree is created, entered, and removed once one is called for.
It does not decide whether to use a worktree; that belongs to the user, or to a workflow that asks for one such as [sub agent](./sub-agent.md).

Two mechanisms exist here and they do not produce the same worktree.
`git-wt` honors the repository's `wt.*` git config, which decides the base directory and which gitignored, untracked, or modified files are carried into a new worktree.
`EnterWorktree` moves the session's working directory, which no shell command can do, because the shell working directory is reset between invocations.
Worktrees MUST therefore be created with `git-wt` and entered with `EnterWorktree`.

## Creating

`git-wt <branch>` creates the worktree and its branch when they do not exist, checks out an existing branch rather than recreating it, and prints the worktree path to stdout in every case.
That printed path MUST be captured, because the next command starts from the original working directory again.

Plain `git worktree` ignores `wt.*` and produces worktrees that differ from the ones the user works in, so it MUST NOT be used.
The `--nocd` flag only suppresses the directory change performed by the interactive shell integration, and is unnecessary when the binary is invoked directly.

## Inspecting

`git-wt --json` lists every worktree of the repository with its path, branch, and head.
This is how to tell whether a worktree already exists, and how to find ones that another mechanism left behind.

## Entering

`EnterWorktree({path})` switches the session into an existing worktree, including one created by `git-wt`; the path only has to appear in `git worktree list`.
This is the only way to make subsequent tool calls run inside the worktree.

`EnterWorktree({name})` SHOULD NOT be used to create one.
It places the worktree under `.claude/worktrees/`, names the branch `worktree-<name>`, and copies none of the files `wt.copy` and `wt.copyignored` would bring across, so the worktree lacks the local-only files the repository is configured to provide.

Its base ref is governed by `worktree.baseRef`, set to `head` here so that unpushed local commits are present.
The `fresh` default would branch from `origin/<default-branch>`, and work built on that base can be cherry-picked back without conflict while silently missing the commits it depended on.

## Removing

A temporary worktree MUST be removed once it is no longer needed.
`git-wt -d <branch>` removes the worktree together with its branch, and refuses when the branch holds unmerged commits.
`git-wt -D <branch>` removes both without that check.
The default branch is protected from deletion in either form unless `--allow-delete-default` is passed.

A worktree entered with `EnterWorktree({path})` is not owned by the session, so `ExitWorktree({action: "remove"})` refuses it.
Leave it with `ExitWorktree({action: "keep"})` and delete it with `git-wt`.

The merged check asks whether the branch's own commits are reachable from the current head.
Squash merge replaces them with a single new commit, and rebase merge and cherry-pick replace them with copies that have different hashes, so the check never passes afterwards however long ago the change landed.
A branch integrated by any of those routes, including the sub agent cherry-pick, MUST be removed with `-D`.

Trying `-d` first and falling back to `-D` is not a safe habit.
When the check fails, `-d` has already deleted the worktree directory and leaves the branch behind, yet still exits with status 0, so an agent that checks exit codes rather than output never learns the branch is still there.
Recovering requires `git-wt -D <branch>` against the now worktree-less branch.

## Subagent isolation

`worktree.baseRef` also applies to `Agent({isolation: "worktree"})`, but nothing else in this document does.
That worktree is removed automatically only if it is left unchanged, so one the subagent actually wrote to survives the agent, and MUST be located with `git-wt --json` and removed once its changes have been taken over.
