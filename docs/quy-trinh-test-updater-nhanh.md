# Quy trình kiểm thử updater nhanh

Script `tools/test-local-updater.ps1` hỗ trợ hai cách test. Chạy các lệnh từ
PowerShell tại `D:\ai-agent-launcher`.

## Cách 1: Tự động toàn bộ

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test-local-updater.ps1 `
  -Action Quick `
  -VersionName 1.2.0 `
  -BuildNumber 3 `
  -ForceArtifact
```

Script tự clean/build Release, tạo ZIP, tính size/SHA-256, sinh `latest.json`,
tạo trial từ fixture, chạy server, mở launcher cũ, chờ update và in `PASS` hoặc
`FAIL`. Trial dùng tên có timestamp và được giữ lại sau test.

## Cách 2: Xem đầy đủ bản cũ rồi mới công bố update

Cách này đúng với tình huống cần mở launcher cũ vào login trước, sau đó mới cấu
hình update và mở lại.

### Bước 1: Chuẩn bị và mở bản cũ

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test-local-updater.ps1 `
  -Action PrepareOld `
  -TrialName test_install_demo
```

Script sao chép fixture `1.1.0+2`, tạo manifest có cùng version và chạy server.
Vì manifest không mới hơn, launcher cũ sẽ hoàn thành startup và vào login mà
không update. Kiểm tra giao diện xong thì đóng launcher bằng nút Close.

Không chạy trực tiếp fixture gốc trong
`local_update_feed/test_install_legacy_window_manager_1.1.0/current`.

### Bước 2: Build và công bố bản mới

Chỉ chạy sau khi đã đóng launcher cũ:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test-local-updater.ps1 `
  -Action PublishUpdate `
  -VersionName 1.2.0 `
  -BuildNumber 3 `
  -ForceArtifact
```

Script chạy `flutter clean`, build Release, kiểm tra không còn DLL
`window_manager`, tạo ZIP và thay `latest.json` bằng manifest bắt buộc của
version mới. Server đang chạy sẽ đọc manifest mới ngay, không cần restart.

Version semantic phải tăng. Từ `1.1.0+2` phải lên ít nhất `1.1.1`, `1.2.0` hoặc
`2.0.0`; chỉ tăng build number thành `1.1.0+3` không kích hoạt updater.

### Bước 3: Mở lại bản cũ để update

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test-local-updater.ps1 `
  -Action RunUpdate `
  -TrialName test_install_demo
```

Script từ chối chạy nếu executable trial cũ vẫn đang mở. Khi chạy thành công,
launcher đọc manifest mới, tải ZIP, staging, tự thoát, tạo backup, đổi sang bản
mới và mở lại.

### Bước 4: Xác minh

Chờ launcher mới mở hoàn chỉnh rồi chạy:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test-local-updater.ps1 `
  -Action Verify `
  -TrialName test_install_demo `
  -VersionName 1.2.0
```

Kết quả `PASS` yêu cầu:

- `current` có version mới.
- `current.backup-*` có version `1.1.0+2`.
- Không còn `.zip.part`.
- `window_manager_plugin.dll` không còn trong bản mới.

### Bước 5: Dừng server

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test-local-updater.ps1 -Action StopServer
```

Lệnh chỉ dừng PID Dart do chính script ghi trong `.server.pid`. Trial, backup,
ZIP và log được giữ lại để kiểm tra.

## Khi artifact đã tồn tại

Mặc định script không ghi đè ZIP. `-ForceArtifact` chỉ cho phép thay đúng ZIP
của `VersionName` đang build. Không dùng cờ này nếu cần giữ artifact cũ; hãy
tăng version hoặc sao lưu artifact trước.

## Khi test thất bại

Kiểm tra:

- `local_update_feed/quick-server.stdout.log`.
- `local_update_feed/quick-server.stderr.log`.
- `local_update_feed/latest.json`.
- `<trial>/.launcher-update`.
- `<trial>/current.backup-*` và `<trial>/current.failed-*`.

Không xóa fixture gốc hoặc ZIP fixture chỉ đọc. Quy trình thủ công đầy đủ và các
ca SHA-256 sai, size sai, mất kết nối, ZIP thiếu executable và rollback nằm tại
`local_update_feed/README.md`.
