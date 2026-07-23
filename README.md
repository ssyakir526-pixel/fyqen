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
