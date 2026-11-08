# {{ number }}. {{ title }}

Date: {{ date }}

## Status

{{ status }}
{% for link in links %}
{{ link.kind }} [{{ link.target }}. {{ link.target_title }}]({{ link.target_filename }})
{% endfor %}

## Context

<The force that made doing nothing unacceptable, as it happened in this project, and what the decision has to satisfy.>

## Alternatives Considered

### Option 1: <Name>

<What the option is, with a short example when it makes the option tangible.>

#### Pros

- <Pro>

#### Cons

- <Con>

## Decision

<What we will do, stated in the future or present tense ("We will ...").>

### 1. <Sub-decision>

<What this part of the decision is, at a granularity that survives a change of implementation.>

#### Rationale

<Why this choice won over the alternatives, not a restatement of the choice.>

### Not Decided Here

- <What this ADR leaves open>: <where it will be decided>

## Consequences

### Positive

- <Benefit>: <explanation>

### Negative

- <Cost>: <explanation>

### Mitigations

- <The behavior that contains each cost>

## References

- <Optional: external discussions, related ADRs, prior art>
