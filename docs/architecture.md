# Fyqen Architecture

## Purpose

Fyqen uses a pragmatic feature-first architecture to support maintainability,
testability, scalability, clear feature ownership, and separation between UI,
business rules, and external services.

## High-Level Structure

- `lib/app` owns application composition, including the root widget and future
  startup, routing, and dependency wiring.
- `lib/core` contains small, app-wide technical building blocks such as shared
  constants, error primitives, validation, and utilities. It must not become a
  dumping ground for feature-specific code.
- `lib/features` contains independently maintainable product features.
- `lib/shared` is reserved for UI or models that are genuinely reused by more
  than one feature.

## Feature-First Structure

When a feature needs the relevant code, it may use this structure:

```text
feature/
|- data/
|- domain/
`- presentation/
```

Folders are created only when real code requires them. Empty layers are not
scaffolding requirements.

## Layer Responsibilities

- **Presentation** contains pages, widgets, and feature-facing state handling.
- **Domain** contains business rules, entities, repository contracts, and use
  cases when the feature complexity warrants them.
- **Data** contains external data sources, models, and repository
  implementations.

## Dependency Direction

```text
Presentation -> Domain <- Data
```

Domain code remains independent of Flutter and Firebase. Presentation does not
perform direct database operations, and data models do not become permanent UI
state when domain entities are appropriate.

## Application Composition

`lib/app` owns the root application widget. It will also own future dependency
wiring, startup/bootstrap logic, and routing configuration when those concerns
have real implementation requirements.

## Firebase Boundary

Firebase will be introduced later through data-layer implementations and
abstractions. Widgets must not call Firebase directly.

## State Management Boundary

A state-management solution is not configured yet. Its selection and
installation require a dedicated architectural decision.

## Error Handling

User-facing messages must be understandable. Internal failures should be
mapped into controlled application exceptions without exposing sensitive
information. Errors must never be silently swallowed.

## Testing Strategy

Fyqen will use unit tests for business rules, widget tests for important UI,
and integration tests for critical user flows. Tests should remain deterministic
and focus on observable behavior.

## Feature Creation Rule

Every future feature must define its purpose, ownership, data flow, validation
rules, error states, loading states, empty states, and tests before its
implementation grows beyond a simple screen.
