# Fyqen Coding Standards

## Naming

- Files and directories use `snake_case`.
- Classes, enums, extensions, and typedefs use `UpperCamelCase`.
- Variables, methods, and parameters use `lowerCamelCase`.
- Private identifiers begin with `_`.
- Constants use meaningful `lowerCamelCase` names.
- Boolean names should read naturally, such as `isLoading`, `hasError`, and
  `canEdit`.

## File Organization

Prefer one primary public type per file and keep each file focused on one
responsibility. Avoid large miscellaneous utility files and barrel files until
they provide genuine value. Do not create empty architecture folders.

## Imports

Order imports as Dart SDK, Flutter or package, then project imports, with a
blank line between groups. Prefer package imports across features. Use relative
imports only for tightly related files within a feature, and do not mix styles
inconsistently in the same area.

## Widgets

Prefer `StatelessWidget` unless local mutable state is required. Use const
constructors where possible, keep build methods readable, and extract complex
UI into focused widgets. Do not make network or database calls in `build()` or
place business calculations directly in widgets. Avoid deeply nested anonymous
widget trees.

## Theme Usage

Do not hard-code shared colors in feature widgets. Use
`Theme.of(context).colorScheme` for semantic Material colors and `AppColors`
for Fyqen-specific semantic tokens. Use `AppSpacing`, `AppRadius`, and
`AppDurations`; new visual tokens belong in the centralized design system.
Avoid one-off magic numbers when a shared token is appropriate, and do not add
premium-theme values to feature files. Maintain contrast and readable text
scaling. Theme switching requires architectural review and must not be added
casually.

## Forms and Feedback

Reuse `AppTextField` and `AppButton` instead of recreating shared input or
button styling in feature pages. Do not hard-code repeated validation messages
or expose raw exceptions directly in UI. Shared buttons must not perform async
operations; future submission controls are disabled while an operation loads.
Keep confirmation dialogs free of business logic and use `AppSnackBar` for
brief user feedback. Future feature code must check mounted state before using
`BuildContext` after asynchronous gaps. Add validation to `AppValidators` only
when it is genuinely generic.

## Navigation

Primary navigation metadata must be centralized, and destination order must
remain consistent between metadata and page lists. Feature widgets must not
manipulate global navigation state directly. Use local widget state for simple
presentation-only navigation when appropriate, and do not introduce a routing
package without architectural review. Avoid navigation side effects in
`build()`, use stable keys for major navigation widgets when tests benefit, and
do not add nested navigators or duplicate primary navigation bars casually.

## State and Business Logic

Keep business rules outside widgets. Do not use mutable global state or static
service locators. Do not introduce a state-management package without a
dedicated architectural decision. Future features must model loading, success,
empty, and error states explicitly.

## External SDK Boundaries

Initialize external SDKs only at the framework/bootstrap boundary. Generated SDK
configuration must not be imported into Domain or Application code, and
presentation code must not call SDK plugins directly. SDK-backed infrastructure
must implement application-owned abstractions.

## Null Safety and Types

Avoid `dynamic`; prefer `Object?` for unknown values. Do not use `!` unless it
is logically guaranteed and documented. Avoid unnecessary `late`, prefer
immutable data where practical, and use `final` for variables that are not
reassigned.

## Functions and Async Code

Keep functions small and descriptive. Avoid Boolean positional parameters and
prefer named parameters when they improve clarity. Validate inputs at system
boundaries and return controlled results or throw defined application
exceptions where appropriate.

Await futures intentionally, handle errors explicitly, check widget lifecycle
or context validity after asynchronous gaps, and do not block the UI isolate
with heavy processing.

## Error Handling

Never use empty catch blocks or expose raw backend errors directly to users.
Do not log secrets. Preserve useful diagnostic context safely and convert
infrastructure failures into controlled application-level failures.

## Comments and Documentation

Explain why rather than what. Avoid comments that repeat obvious code. Document
non-obvious public APIs and business rules, and update comments when behavior
changes.

## Testing

Every business rule needs unit tests. Important widgets need widget tests, and
critical user flows will later receive integration tests. Tests must be
deterministic, avoid arbitrary delays, and test behavior rather than private
implementation details.

## Security

Never commit secrets or hard-code API keys and passwords. Sensitive
configuration will use an approved environment strategy introduced later.
Authorization must be validated in backend security rules, not only in the
client. Treat all user financial data as sensitive.

## Git Responsibility

Codex edits source files. The user performs Git and CLI operations in normal
PowerShell, without credentials, token-bearing URLs, or personal information in
project files.
