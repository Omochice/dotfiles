# Worktree

This document defines how a git worktree is created, entered, and removed once one is called for.
It does not decide whether to use a worktree; that belongs to the user, or to a workflow that asks for one such as [sub agent](./sub-agent.md).

Worktrees MUST be created and removed with `git-wt`, whose usage `git-wt --help` describes.
Plain `git worktree` ignores the repository's `wt.*` git config, which decides the base directory and which local-only files are carried into a new worktree.

A worktree MUST be entered with `EnterWorktree({path})`, passing the path `git-wt` prints, because the shell working directory is reset between Bash invocations.
`EnterWorktree({name})` SHOULD NOT be used, because it creates its own worktree under `.claude/worktrees/` without honoring `wt.*`.
A worktree entered by path is not owned by the session, so leave it with `ExitWorktree({action: "keep"})` and delete it with `git-wt`.

A branch integrated by squash merge, rebase merge, or cherry-pick, including the sub agent cherry-pick, MUST be removed with `-D`.
Its own commits never become reachable from the integrating branch, so `-d` always keeps it.

A worktree created by `Agent({isolation: "worktree"})` survives the agent once the agent writes to it.
It MUST be located with `git-wt --json` and removed once its changes have been taken over.
