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

## Primary Navigation

`FyqenShell` owns primary tab selection for Dashboard, Portfolio, Journey,
History, Battle, and Settings. It uses Flutter SDK `NavigationBar` and an
`IndexedStack`, so visited destination pages remain mounted. Local widget state
is appropriate for this presentation-only selection state, and no third-party
routing package is configured.

Future authentication flows, detail screens, deep links, and nested routing
will be designed separately. Feature pages must not create competing primary
navigation, and the shell is not responsible for finance business logic.

## Design System and Theming

Shared theme code belongs in `lib/core/theme`. Feature widgets consume theme
values instead of hard-coding visual styles, and semantic colors are preferred
over widget-specific colors. Dark Purple is the only active theme today.
Future premium accent themes may extend this design system, but theme
persistence and premium entitlement are not implemented. All future themes
must preserve accessible contrast and readable text.

## Reusable UI Foundation

Shared screen composition belongs in `lib/shared/widgets`. `AppPage` provides
the responsive, scrollable page layout; `AppSection` separates major content;
`AppCard` applies the centralized card treatment; `SectionTitle` standardizes
headings; and `EmptyState` communicates unavailable content. Future screens
must compose these building blocks instead of duplicating page padding,
constraints, scrolling, card styling, or empty-state layouts.

## Form and Feedback Foundation

Shared form controls belong in `lib/shared/widgets`, cross-feature visual
feedback helpers belong in `lib/shared/feedback`, and generic input validation
belongs in `lib/core/validation`. Feature-specific validation remains within
its feature. Presentation widgets must not perform business operations: future
feature layers supply loading and error state, confirmation dialogs return user
intent only, and snack bars display supplied messages only. Authentication and
data flows will be designed separately.

## Dashboard Presentation Widgets

`FinancialIndependenceProgressCard` belongs to the Dashboard presentation
layer. It receives already-prepared display values and does not calculate FI
progress or format currency or percentages. Future application and domain
layers will prepare and supply values; Dashboard pages compose the widget but
do not own financial calculation logic.

`JourneyOverviewCard` also belongs to the Dashboard presentation layer. It
receives prepared display values and does not calculate journey stages or
determine next steps. It does not own level, achievement, streak, or challenge
logic; future application and domain layers will prepare and supply journey
data while Dashboard pages compose the widget without owning business logic.

`DashboardQuickAction` is a presentation-layer action definition, and
`QuickActionsCard` renders supplied actions without determining business
availability, navigating, or creating assets or liabilities. Future
presentation and application layers will supply callbacks; Dashboard pages
compose actions without owning financial business logic, and creation flows
will belong to their respective feature modules.

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
