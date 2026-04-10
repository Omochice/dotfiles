# Simple, Not Easy

Simplicity and ease are distinct qualities.
Simple means one role, one concept, one responsibility.
Easy means familiar or nearby.
When they conflict, prefer simplicity because it enables long-term changeability.

## Avoid Complecting

- Unrelated concerns MUST NOT be interleaved within a single unit; each module, function, or class SHOULD serve one role
- When multiple responsibilities exist in one place, separate them into distinct units rather than adding conditional logic

## Design by Constraint

- Before splitting code into more files, services, or modules, you MUST understand the domain boundary that justifies the separation; distributing complexity does not reduce it
- When splitting code, you MUST identify what state and operations belong to each side of the boundary; moving only a function call without its associated state is not a meaningful separation
- Architectural decisions SHOULD be driven by what to enable and what to forbid, not by pattern adoption
