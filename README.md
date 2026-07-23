# Fyqen

Track Your Journey to Financial Freedom.

## Overview

Fyqen is a Flutter mobile application being built to help people understand
and progress toward financial freedom through a net-worth-focused journey.

## Current Development Status

The architecture foundation and default Dark Purple design system are complete.
The six-destination navigation shell connects Dashboard, Portfolio, Journey,
History, Battle, and Settings. Non-Dashboard destinations remain temporary
placeholders built from the reusable UI foundation, and finance features are
not implemented yet. The Dashboard now provides a presentation-only layout for
future net-worth, financial-independence, journey, and quick-action content;
its business logic is not implemented. Dashboard presentation now includes a
reusable `NetWorthHeroCard`; it receives display content from future feature
layers and performs no calculations. The Dashboard also uses a reusable
`FinancialIndependenceProgressCard` for unavailable and supplied-data
presentation states. FI calculations, formatting, persistence, and backend
integration remain unimplemented. The Dashboard also uses a reusable
`JourneyOverviewCard` for unavailable and supplied-data presentation states;
journey stages, progress, next-direction logic, persistence, and backend
integration remain unimplemented. The Dashboard currently uses its
unavailable state. The Dashboard also uses a reusable `QuickActionsCard` with
presentation-only `DashboardQuickAction` definitions. It currently displays
disabled Add asset and Add liability actions. Navigation, forms, persistence,
and financial operations remain unimplemented; the component only forwards
supplied callbacks.

## Assets Domain Foundation

The Assets feature now has its first domain foundation. `Asset` is an
immutable, persistence-independent entity whose identity is its normalized
asset ID. `AssetQuantity` stores a positive exact decimal quantity as a
canonical string, while `AssetUnitPrice` stores a non-negative exact decimal
price and normalized three-letter currency code. `AssetType` classifies the
financial asset category. Quantity and unit price do not use floating-point
representation, and no total-value calculation exists yet. Persistence,
Firestore mapping, repositories, state management, and asset UI flows remain
unimplemented.

## Liabilities Domain Foundation

The Liabilities feature now has its first domain foundation. `Liability` is an
immutable, persistence-independent entity whose identity is its normalized
liability ID. `LiabilityAmount` stores an exact non-negative decimal amount
with a normalized three-letter currency code, while `LiabilityType` classifies
debt categories. Outstanding balance and original amount must use the same
currency. Optional lender name and due date are supported, and dates are
normalized to UTC. Liability monetary values do not use floating-point
representation. Debt calculations, persistence, Firestore mapping,
repositories, state management, and liability UI flows remain unimplemented.

## Portfolio Domain Foundation

The Portfolio feature now has its first domain foundation. `Portfolio` is an
immutable, persistence-independent aggregate that groups existing `Asset` and
`Liability` entities. Its identity is its normalized portfolio ID, and its ID
and name are validated and trimmed. Asset and Liability collections preserve
insertion order, reject duplicate IDs within their own type, and keep Asset and
Liability ID namespaces independent. Incoming lists are defensively copied and
exposed as unmodifiable collections. Portfolio timestamps are normalized to
UTC. No financial calculation, currency aggregation, persistence, repository,
state management, or Portfolio UI exists yet.

Portfolio also supports explicit immutable snapshot operations: `rename`,
`addAsset`, `replaceAsset`, `removeAsset`, `addLiability`, `replaceLiability`,
and `removeLiability`. Every successful operation returns a new Portfolio while
leaving the original unchanged, preserving its ID and `createdAt`. Callers must
supply `updatedAt`; modification timestamps cannot move backwards, although an
equal timestamp is allowed. Add operations append, replacements preserve list
position, removals preserve remaining order, and duplicate or missing targets
are rejected. Asset and Liability ID namespaces remain independent. There is
still no persistence, repository, state management, Portfolio UI, or financial
calculation.

## Portfolio Application Use Cases

The Portfolio feature now has a thin application-layer use-case foundation:
`RenamePortfolioUseCase`, `AddAssetToPortfolioUseCase`,
`ReplaceAssetInPortfolioUseCase`, `RemoveAssetFromPortfolioUseCase`,
`AddLiabilityToPortfolioUseCase`, `ReplaceLiabilityInPortfolioUseCase`, and
`RemoveLiabilityFromPortfolioUseCase`. These stateless synchronous use cases
delegate to Portfolio, return a new validated snapshot, receive `updatedAt`
from the caller, and allow domain exceptions to propagate unchanged. No
persistence, repository, Firebase, state management, Portfolio UI, or
financial calculations are implemented.

## In-Memory Portfolio Repository

`lib/features/portfolio/infrastructure/repositories/in_memory_portfolio_repository.dart`
provides an in-memory implementation of the application-layer
`PortfolioRepository` contract for development and testing. It stores complete
Portfolio aggregates by ID, supports `findById`, `save`, and `deleteById`, and
replaces a stored snapshot when the same ID is saved. Missing lookups return
null and missing deletion completes normally. Repository instances have
isolated storage and preserve supplied Portfolio references. This storage is
not durable: data is lost when its repository instance is discarded. No
Firebase, database, local storage, authentication, UI integration, or financial
calculations exist.

## Portfolio Persistence Workflows

The Portfolio application layer now includes `LoadPortfolioUseCase`,
`SavePortfolioUseCase`, and `DeletePortfolioUseCase`. Each receives a
`PortfolioRepository` through constructor injection and delegates directly to
it. Load returns `Future<Portfolio?>`; save and delete return `Future<void>`.
These asynchronous workflows do not depend on a concrete repository, generate
no IDs or timestamps, and allow repository exceptions to propagate unchanged.
The existing seven aggregate-operation use cases remain synchronous and
repository-free. No Firebase, Firestore, authentication, UI integration, or
financial calculations are implemented.

## Application Composition Root

`AppCompositionRoot` provides explicit, manual constructor-based dependency
injection for the current Portfolio dependency graph. It selects
`InMemoryPortfolioRepository` by default, or accepts a `PortfolioRepository`
implementation through its constructor as a future replacement point. One
repository instance is shared by `LoadPortfolioUseCase`, `SavePortfolioUseCase`,
and `DeletePortfolioUseCase`; all seven synchronous aggregate-operation use
cases are also exposed. Aggregate modification and persistence remain separate
operations.

No service locator, dependency-injection package, or global mutable singleton
is used. No UI currently consumes the composition root. Firebase, Firestore,
authentication, and user ownership remain unimplemented.

## Firebase Core Foundation

Firebase Core is the only Firebase Flutter dependency and is initialized in
`main.dart` before `runApp`, using `DefaultFirebaseOptions.currentPlatform`.
The required `lib/firebase_options.dart` file must be generated by FlutterFire
CLI; Fyqen does not manually author Firebase configuration values.

Firebase Core is limited to the application bootstrap boundary. Domain,
application use cases, Portfolio infrastructure, and the active
`InMemoryPortfolioRepository` remain Firebase-independent. Initialization does
not store Portfolio data. Cloud Firestore, user ownership, cloud
synchronization, and Firebase UI integration are not implemented.

To configure Firebase manually, install or verify Firebase CLI, authenticate,
activate or verify FlutterFire CLI, then run `flutterfire configure` from the
Fyqen project directory. Select the intended Firebase project and only intended
platforms, allow the CLI to generate `lib/firebase_options.dart`, run dependency
and validation commands, then start the app on a configured target. Runtime
validation requires a correctly configured Firebase project.

## Firebase Authentication Foundation

Fyqen now includes `firebase_auth` behind Firebase-independent feature types.
`AuthenticatedUser` is the domain identity model, `AuthenticationRepository` is
the application contract, and `FirebaseAuthenticationRepository` is the sole
Firebase-backed infrastructure adapter. Firebase failures are translated at the
infrastructure boundary into application-owned `AuthenticationException` values.

`AppCompositionRoot` composes one authentication repository per root and
exposes use cases for observing authentication state, reading the current user,
email/password sign-in, registration, and sign-out. No UI consumes these use
cases yet: there is no login or registration screen, route guard, or state
management. Passwords are neither logged nor persisted by Fyqen code.

Firebase Authentication does not create Portfolio ownership, Cloud Firestore,
or cloud Portfolio persistence. Before future runtime email/password operations
can succeed, enable the Email/Password provider in the correct Firebase Console
project's Authentication settings.

## Authentication Presentation Foundation

Fyqen now presents email/password authentication through `AuthenticationGate`,
which owns a Flutter SDK `ChangeNotifier` controller and selects login,
registration, session-restoration, or the existing authenticated navigation
shell. The authentication-state stream remains the source of truth for signed-in
state. Login and registration screens use local form controllers only, and a
callback-based sign-out action is available in Settings.

Widgets receive state and callbacks; they do not access Firebase or repositories
directly. Password reset, email verification, social sign-in, Firestore,
Portfolio ownership, and cloud persistence remain unimplemented. Passwords are
never logged or persisted. Enable Email/Password manually in Firebase Console
for project `fyqen-df590` before runtime authentication can succeed.

## Portfolio Persistence Data Mapping

The Portfolio infrastructure layer now provides a persistence data-mapping
boundary. `PortfolioDto` defines the complete version 1 persistence schema and
`PortfolioMapper` converts complete Portfolio aggregates to and from DTO/map
data. Exact decimal values are stored as strings, enum meanings use stable enum
names, and timestamps use UTC ISO-8601 strings. Asset and Liability ordering is
preserved. Malformed external data produces `PortfolioDataMappingException`.

Domain entities remain persistence-independent. Firebase, Firestore,
authentication, user ownership, durable persistence, direct UI use of the
mapper, and financial calculations are not implemented.

## Portfolio Repository Contract

The Portfolio application layer now defines a persistence-neutral
`PortfolioRepository` contract for finding one Portfolio by ID, saving a
complete Portfolio snapshot, and deleting by ID. It has no implementation,
database, Firebase integration, authentication dependency, or financial logic.

## Technology

- Flutter
- Dart
- Android
- Kotlin for the Android host project
- Material 3
- Centralized design tokens
- Dark Purple default theme

Firebase is planned for a later stage and is not currently integrated.

## Architecture

Fyqen follows a pragmatic feature-first architecture with clear layer
boundaries. Read the [architecture guide](docs/architecture.md) for details.
Primary navigation uses Material 3 `NavigationBar`, state-preserving
`IndexedStack` composition, and Flutter SDK navigation only.

## Reusable UI Foundation

Future screens use the shared `AppPage`, `AppSection`, `AppCard`,
`SectionTitle`, and `EmptyState` building blocks. They provide consistent page
layout, spacing, cards, headings, and empty-content messaging.

## Form and Feedback Foundation

Reusable controls include `AppTextField`, `AppButton`, `AppLoadingIndicator`,
and `AppErrorState`. `AppSnackBar`, the app confirmation dialog, and
`AppValidators` provide generic user-feedback and validation foundations.
Authentication and finance forms remain unimplemented.

## Documentation

- [Architecture](docs/architecture.md)
- [Coding standards](docs/coding_standards.md)

## Local Validation

Run these commands in a normal PowerShell terminal:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Important Notes

- Do not commit secrets.
- CLI and Git operations are performed outside the Codex sandbox.
- Features are implemented incrementally.
