# Shell command

This document defines how commands passed to the Bash tool are written.

## Text processing

`sed` and `awk` MUST NOT be used.
GNU and BSD ship mutually incompatible implementations of both, and a command written against one silently produces different output under the other.
`perl` has a single implementation, so the same command behaves identically wherever it runs.

This applies to every use, not only to editing a file in place.
Reading a line range with `sed -n` depends on the same divergent implementations as rewriting a file with `sed -i`, so it is prohibited on the same grounds.

The equivalents are the following.

```sh
perl -pi -e 's/old/new/g' file        # edit in place
perl -ne 'print if 10 <= $. && $. <= 20' file   # print a line range
perl -lane 'print $F[0]' file         # extract a field
```

When the goal is simply to read or edit a file rather than to transform a stream, the Read and Edit tools SHOULD be preferred over any of these.

This prohibition is also enforced by a PreToolUse hook.
The hook reports the violation only after the call has already failed, so it cannot teach the rule in advance; following the rule beforehand is what avoids the wasted turn.
