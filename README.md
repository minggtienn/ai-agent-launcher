# AI Agent Launcher

Windows desktop launcher built with Flutter, BLoC/Cubit and feature-first Clean Architecture.

## Toolchain

- Flutter 3.44.4 (managed by FVM)
- Dart 3.12.2
- Windows 10/11 x64

## Commands

```bash
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter analyze
fvm flutter test
fvm flutter run -d windows -t lib/main_dev.dart \
  --dart-define=API_BASE_URL=https://dev.example.invalid \
  --dart-define=LAUNCHER_UPDATE_MANIFEST_URL=https://dev.example.invalid/launcher/latest.json \
  --dart-define=LAUNCHER_UPDATE_PUBLIC_KEY=BASE64_ED25519_PUBLIC_KEY
```

Production builds must run on a Windows runner with Visual Studio 2022 and the
Desktop development with C++ workload.

For local UI development without a signed update feed, omit the manifest URL to
continue directly to login. Unsigned manifests are never enabled by default;
`ALLOW_UNSIGNED_UPDATES=true` is restricted to controlled development builds.

See [architecture](docs/architecture.md), [governance](docs/governance.md), and
[change history](CHANGELOG.md).
