# {{ number }}. {{ title }}

Date: {{ date }}

## Status

{{ status }}
{% for link in links %}
{{ link.kind }} [{{ link.target }}. {{ link.target_title }}]({{ link.target_filename }})
{% endfor %}

## Context

<What triggered the refinement, typically implementation feedback, and a statement that this ADR exists to keep the design-evolution record of the amended ADR visible.>

## Decision

### 1. <What changed>

#### Original Design

<as originally recorded>

#### Revised Design

<as implemented or now intended>

#### Rationale

<why the revision won, and what the original design missed>

## Consequences

<What becomes easier or harder because of the revision.>
