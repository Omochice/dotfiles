# {{ number }}. {{ title }}

Date: {{ date }}

## Status

{{ status }}
{% for link in links %}
{{ link.kind }} [{{ link.target }}. {{ link.target_title }}]({{ link.target_filename }})
{% endfor %}

## Context

<What situation and forces led to this decision. State the problem concretely; include failing output or code where it makes the force tangible.>

## Decision Drivers

- <Driver>: <what this decision must satisfy>

## Alternatives Considered

### Option 1: <Name>

<Concrete illustration of the option, ideally a code or output example.>

#### Pros

- ...

#### Cons

- ...

## Decision

<What we will do, stated in the future or present tense ("We will ...").>

### 1. <Sub-decision>

#### Change from

<before, as code>

#### Change to

<after, as code>

#### Rationale

<why this specific choice, not a restatement of the change>

## Consequences

### Positive

- <Benefit>: <explanation>

### Negative

- <Cost>: <explanation>

### Mitigations

- <How each negative consequence is contained>

## Implementation Notes

<Optional: constraints for whoever implements this, such as what must be tested or what must stay backward compatible.>

## References

- <Optional: links to discussions, issues, related ADRs, prior art>
