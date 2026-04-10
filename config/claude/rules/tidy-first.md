# Tidy First

Structural changes and behavioral changes MUST NOT be combined in a single commit.

- A structural change is one that reorganizes code without altering observable behavior (e.g. renaming, extracting, reordering)
- A behavioral change is one that adds or modifies functionality visible to users or tests

## Ordering

When both structural and behavioral changes are needed, structural changes MUST come first.
Tests SHOULD pass both before and after each structural change.

## When to Tidy

- Tidying SHOULD be done when it makes an upcoming behavioral change easier to implement
- Tidying MAY be skipped when the structural change provides no clear benefit to the next behavioral change
