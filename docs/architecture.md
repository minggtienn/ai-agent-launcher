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

Launcher startup is gated by a signed update manifest. It downloads a resumable
ZIP, verifies size, SHA-256 and Ed25519 signature, then extracts to a sibling
staging directory. To avoid a second updater project, the launcher copies its
own runtime to a temporary directory and starts that executable in apply mode.
The temporary process switches directories, starts the new launcher, waits for
a health marker and rolls back when startup fails.

Production executables, manifests and update artifacts must be signed. Game
patch updates are intentionally deferred to a separate task and will reuse the
download, integrity and progress concepts without sharing launcher apply logic.
