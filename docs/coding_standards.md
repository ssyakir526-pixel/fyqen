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
must implement application-owned abstractions. The application composition root
may construct those adapters with injected SDK dependencies, but must not expose
SDK types to feature code.

Never expose Firebase `User` or `UserCredential` outside Infrastructure. Never
log or persist plaintext passwords. Translate Firebase exceptions at the
infrastructure boundary, keep application use cases dependent on
application-owned repository contracts, and leave authentication stream
subscription to explicit future presentation or state ownership.

Authentication widgets must not import `firebase_auth` or access repositories
directly; presentation controllers use application use cases. Stream
subscriptions must be cancelled explicitly, passwords must never be stored in
presentation state or logged, and authentication stream events are the source
of truth for signed-in state. Async completion must not overwrite newer stream
state. ChangeNotifier controllers require explicit widget ownership and
disposal, and user-facing authentication errors must use safe presentation
messages.

Firestore adapters must depend on application-owned identity and repository
contracts. Presentation must not construct ownership paths or supply user IDs,
and Firebase/Firestore exceptions must be translated at the infrastructure
boundary without exposing document paths or user identifiers. Resolve the
current Firebase UID for each repository operation; never cache it across
authentication changes. Portfolio domain entities must not hold Firebase
ownership IDs. Complete aggregate saves must replace the stored document rather
than leave stale nested data. Never use public Firestore test rules or log user
IDs, credentials, tokens, or full Portfolio payloads. Firestore tests must not
access the real Firebase project.

Production Firebase composition must be explicit. Firebase-independent tests
must inject a root with fake or in-memory dependencies, and widgets must never
choose repositories. Authentication state must not mutate dependency graphs.
App construction must not trigger Portfolio persistence; registration must not
create Portfolio documents and sign-out must not delete them. In-memory
repositories are test/development dependencies, not silent production
fallbacks. Firebase plugin instances must not be accessed by
Firebase-independent widget tests.

Portfolio presentation controllers depend on use cases only and must not store
UIDs or access repositories directly. Authenticated Portfolio state must be
disposed when its shell is removed. Missing cloud aggregates may be initialized
once through explicit use cases, but registration and sign-out must not create
or delete them. Dashboard values must derive from Domain models. Save failures
must retain the last loaded Portfolio, controller completions must not notify
after disposal, and widget rebuilds must not trigger duplicate loads. Map
persistence failures to safe presentation text; do not add automatic retry,
synchronization, or migration without an explicit architecture decision.

Asset forms must validate input before Domain construction. Asset edits preserve
ID and `createdAt`, while updating `updatedAt` through the injected clock
boundary. Use Domain exact decimal value objects for financial input. Widgets
must not access PortfolioRepository or Firestore. Add, edit, and delete
submissions must be single-flight; forms close only after success and retain
input on failure. Asset deletion requires confirmation. Do not seed sample
financial data or add market-price fetching without explicit architecture.

Liability forms must validate required Domain input before constructing a
Liability. Edits preserve Liability ID and `createdAt`, preserve optional
values that the form does not edit, and update `updatedAt` through the injected
project clock.
Financial input uses the Domain exact numeric representation; widgets do not
calculate authoritative liability totals or access PortfolioRepository or
Firestore. Add, edit, and delete actions must be single-flight, forms close
only after successful persistence, and failed persistence retains both input
and the existing Portfolio state. Liability deletion requires confirmation.
Do not seed sample liabilities or introduce debt advice, automatic interest,
repayment calculations, or currency conversion without explicit architecture.
Use distinct stable keys for page-level and empty-state actions.

Financial Independence targets belong to the Portfolio aggregate and use the
exact positive decimal Domain value object. Target forms validate before Domain
construction and must retain entered values on failed persistence. Dashboard
progress is presentation derivation from the shared Portfolio snapshot; do not
duplicate it in widgets, convert currencies, add projections, or give financial
advice. Missing persisted target fields must remain backward-compatible as an
unconfigured target.

Financial Freedom Levels are Dashboard-only derived presentation state.
These levels
update only by deriving again from the current Portfolio snapshot when
comparable net worth or the FI target changes; never add artificial points.
They
must use the centralized exact financial summary inputs, remain in the 1–100
range, and must never be persisted, manually edited, or represented as XP.
Boundary decisions must not depend on rounded display strings or binary
floating-point rounding. Mixed-currency values leave Level unavailable; do not
add currency conversion or Achievement behavior to the Level system.

Financial Freedom Journey state is derived presentation state composed from
the existing Dashboard and Level summaries. Keep the ten stage definitions in
one immutable mapping and derive completed, current, and upcoming status only
from the current Level. Never persist or manually complete Journey stages, add
XP or artificial points, or recalculate Level boundaries. Missing targets
reuse the existing target form; mixed currencies remain unavailable without
conversion, advice, or projections.

Challenge rules are typed, immutable Journey presentation code. Evaluate the
centralized immutable Challenge context from existing Dashboard, Level, and
Journey summaries rather than recalculating financial values or parsing display
strings. Keep the eight application-defined definitions in one unmodifiable,
priority-ordered catalog. Challenge status must be active, completed, or
unavailable; it is reversible and must never be persisted or manually changed.
Select the first active Challenge deterministically, use an unavailable item
only for an explanation when no active item exists, and show no recommendation
when all items are complete. Do not add expression parsing, JSON rules, remote
rules, user-created rules, controllers, repositories, caches, DTOs, Firestore
fields, history, claimed states, rewards, XP, points, notifications, due dates,
AI-generated directions, currency conversion, or financial advice. Reuse
PortfolioSession loading and failure ownership, and keep daily streaks
unimplemented.

Achievement rules are typed, immutable Presentation code that evaluates only
the centralized Achievement evaluation context. Keep the fixed catalog ordered
and application-defined; do not add expression strings, JSON interpreters,
remote rules, user-created rules, controllers, repositories, or persistence.
Achievement status is revocable and must never retain historical unlock state,
timestamps, XP, points, rewards, or streak behavior. Count rules
remain evaluable without financial comparison, while unavailable financial
summaries must yield an unavailable Achievement rather than a false zero.

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
