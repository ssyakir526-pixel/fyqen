# Fyqen

Track Your Journey to Financial Freedom.

## Overview

Fyqen is a Flutter mobile application being built to help people understand
and progress toward financial freedom through a net-worth-focused journey.

## Current Development Status

The project is in the foundation stage. The current application provides a
minimal shell and temporary Dashboard placeholder while its architecture is
established.

## Technology

- Flutter
- Dart
- Android
- Kotlin for the Android host project

Firebase is planned for a later stage and is not currently integrated.

## Architecture

Fyqen follows a pragmatic feature-first architecture with clear layer
boundaries. Read the [architecture guide](docs/architecture.md) for details.

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
