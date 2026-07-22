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
layers and performs no calculations.

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
