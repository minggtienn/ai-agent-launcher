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
  --dart-define=API_BASE_URL=https://dev.example.invalid
```

Production builds must run on a Windows runner with Visual Studio 2022 and the
Desktop development with C++ workload.

See [architecture](docs/architecture.md), [governance](docs/governance.md), and
[change history](CHANGELOG.md).
