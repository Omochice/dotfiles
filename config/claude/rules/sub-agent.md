# sub agent

This document outlines the usage of the sub agent.

Unless the user has explicitly prohibited its use, the sub agent SHOULD be employed for tasks involving code writing and research.

When doing so, the model selected SHOULD correspond to the difficulty of the task.

- `fable`
- `opus`
- `sonnet`
- `haiku`

After the sub agent writes code, the main agent(which is conversing with the user) MUST be the one to execute the `/commit` command.

Alternatively, when having the sub agent write code, a temporary worktree may be created for the sub agent to perform the `/commit`.
In this case, the main agent MUST cherry-pick the changes from that worktree and subsequently discard the branch.
The worktree MUST be created and discarded as described in [worktree](./worktree.md).
