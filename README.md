# AI Agent Launcher

Launcher desktop cho Windows, được xây dựng bằng Flutter, BLoC/Cubit và Clean
Architecture tổ chức theo tính năng.

## Bộ công cụ

- Flutter `3.44.4`, được quản lý bằng FVM.
- Dart `3.12.2`.
- Windows 10/11 x64.
- Visual Studio 2022 với workload Desktop development with C++.

## Các lệnh thường dùng

```powershell
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter analyze
fvm flutter test
fvm flutter run -d windows -t lib/main_dev.dart `
  --dart-define=API_BASE_URL=https://dev.example.invalid `
  --dart-define=LAUNCHER_UPDATE_MANIFEST_URL=https://dev.example.invalid/launcher/latest.json `
  --dart-define=LAUNCHER_UPDATE_PUBLIC_KEY=BASE64_ED25519_PUBLIC_KEY
```

Bản production phải được build trên Windows runner có Visual Studio 2022 và
workload Desktop development with C++.

Khi phát triển UI local mà không có nguồn update đã ký, hãy bỏ
`LAUNCHER_UPDATE_MANIFEST_URL` để đi thẳng tới đăng nhập. Manifest không có chữ
ký không bao giờ được bật mặc định; `ALLOW_UNSIGNED_UPDATES=true` chỉ dành cho
bản build development trong môi trường kiểm soát.

## Tài liệu

- [Kiến trúc](docs/architecture.md)
- [Quản trị dự án](docs/governance.md)
- [Kiểm thử launcher updater trên Windows](docs/windows-local-launcher-update-test.md)
- [Quy trình kiểm thử updater nhanh](docs/quy-trinh-test-updater-nhanh.md)
- [Nguồn update local và fixture cố định](local_update_feed/README.md)
- [Lịch sử thay đổi](CHANGELOG.md)
