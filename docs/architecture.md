# Architecture

## Dependency rule

```text
Presentation -> Domain
Data         -> Domain
Platform     -> Domain/Core contracts
Domain       -> Pure Dart
```

The codebase is organized by feature. A feature owns its data, domain and
presentation layers. Domain code must not import Flutter, plugins, database or
HTTP implementations. Repository contracts belong to domain; implementations
belong to data. DTOs never cross the data boundary.

## State ownership

- Bloc: session, downloads, launching and launcher updates.
- Cubit: catalog filters and settings.
- Blocs call use cases only and expose immutable states.
- Technical exceptions are mapped to `Failure` before reaching presentation.

## Environments

`main_dev.dart`, `main_staging.dart` and `main_prod.dart` select an environment.
Secrets are never compiled into the app. Non-secret endpoints and update
channels are supplied with `--dart-define`.

## Windows boundary

Process launching, single-instance handling, tray, startup registration,
deep links and updater integration live behind contracts. The launcher runs as
a standard user and requests elevation only for an explicitly approved action.

## Updates

Managed applications use a signed manifest, resumable full-file downloads,
SHA-256 verification, staging installation and one-version rollback. Launcher
self-update uses WinSparkle. Production executables and update feeds must be
signed and verified on Windows.
