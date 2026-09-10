# Nguồn cập nhật launcher cục bộ

Thư mục này dùng riêng để kiểm thử updater trên Windows. Các gói ZIP lớn,
manifest sinh ra, thư mục cài thử và log server đều bị Git bỏ qua.

Không chạy bài test trên thư mục launcher đang sử dụng thật. Không bật
`ALLOW_UNSIGNED_UPDATES=true` trong staging hoặc production.

## Dữ liệu kiểm thử đang được giữ cố định

- Bản cũ: `1.1.0+2`, dùng `window_manager`.
- Thư mục gốc được bảo quản:
  `test_install_legacy_window_manager_1.1.0/current`.
- ZIP khôi phục, đã đặt thuộc tính chỉ đọc:
  `artifacts/launcher-1.1.0-window-manager-fixture.zip`.
- Kích thước ZIP: `14075044` byte.
- SHA-256:
  `b5c56cf87619ca1ea9ffcb3aab5a99640c8d8e3a72af700972e609cc78f8050e`.
- Payload mới hiện tại: `1.2.0+3`, dùng `bitsdojo_window`.
- Gói update hiện tại: `artifacts/launcher-1.2.0.zip`.

Tuyệt đối không chạy executable trực tiếp trong thư mục gốc được bảo quản.
Updater sẽ thay thế thư mục `current`. Mỗi lần test phải tạo một bản sao mới.

## 1. Kiểm tra môi trường

Mở PowerShell tại `D:\ai-agent-launcher`:

```powershell
fvm --version
fvm flutter --version
fvm flutter doctor -v
```

Flutter phải là `3.44.4`, Dart phải là `3.12.2` và `flutter doctor` phải nhận
Visual Studio với workload Desktop development with C++.

## 2. Tạo lại bản cài thử từ fixture

Ví dụ dưới đây dùng `test_install_replay`. Nếu thư mục này đã tồn tại, hãy dùng
một tên mới để không ghi đè dữ liệu cũ.

```powershell
Set-Location D:\ai-agent-launcher\local_update_feed

$fixture = ".\test_install_legacy_window_manager_1.1.0\current"
$trialRoot = ".\test_install_replay"
$trialCurrent = Join-Path $trialRoot "current"

if (Test-Path $trialRoot) {
  throw "Thư mục test đã tồn tại: $trialRoot"
}

New-Item -ItemType Directory -Path $trialRoot
Copy-Item -LiteralPath $fixture -Destination $trialCurrent -Recurse
```

Xác nhận bản sao đúng là bản cũ:

```powershell
$oldExe = Get-Item "$trialCurrent\ai_agent_launcher.exe"
$oldExe.VersionInfo.ProductVersion
Test-Path "$trialCurrent\window_manager_plugin.dll"
```

Kết quả mong đợi là `1.1.0+2` và `True`.

Nếu fixture dạng thư mục bị thay đổi nhầm, giải nén ZIP dự phòng vào một thư
mục `current` mới. Trước khi dùng, tính lại SHA-256 và so sánh với giá trị đã
ghi ở phần đầu tài liệu:

```powershell
Get-FileHash `
  .\artifacts\launcher-1.1.0-window-manager-fixture.zip `
  -Algorithm SHA256
```

## 3. Build phiên bản mới

Version mới phải lớn hơn version cũ. Ví dụ build `1.2.0+3`:

```powershell
Set-Location D:\ai-agent-launcher

fvm flutter clean
fvm flutter pub get
fvm flutter build windows --release `
  --build-name=1.2.0 `
  --build-number=3 `
  --dart-define=LAUNCHER_UPDATE_MANIFEST_URL=http://127.0.0.1:8080/latest.json `
  --dart-define=ALLOW_UNSIGNED_UPDATES=true
```

`flutter clean` rất quan trọng khi dependency Windows thay đổi. Nó ngăn DLL đã
bị loại bỏ ở version mới còn sót trong thư mục Release từ lần build trước.

Kiểm tra version và bảo đảm DLL cũ không còn trong output:

```powershell
$release = "D:\ai-agent-launcher\build\windows\x64\runner\Release"
$newExe = Get-Item "$release\ai_agent_launcher.exe"

$newExe.VersionInfo.ProductVersion
Test-Path "$release\window_manager_plugin.dll"
```

Kết quả mong đợi là `1.2.0+3` và `False`.

## 4. Đóng gói ZIP update

Phải nén nội dung bên trong thư mục Release để executable nằm ngay ở root của
ZIP:

```powershell
$version = "1.2.0"
$zip = "D:\ai-agent-launcher\local_update_feed\artifacts\launcher-$version.zip"

if (Test-Path $zip) {
  throw "Gói update đã tồn tại: $zip"
}

Compress-Archive `
  -Path "$release\*" `
  -DestinationPath $zip `
  -CompressionLevel Optimal
```

Kiểm tra nội dung ZIP:

```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($zip)
try {
  $archive.Entries | Select-Object -First 20 -ExpandProperty FullName
} finally {
  $archive.Dispose()
}
```

Danh sách phải có `ai_agent_launcher.exe` ở root.

## 5. Tính size và SHA-256

```powershell
$zipInfo = Get-Item $zip
$zipSize = $zipInfo.Length
$zipHash = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLowerInvariant()

$zipSize
$zipHash
```

Không dùng lại size hoặc hash của ZIP cũ. Chỉ cần nội dung ZIP thay đổi một byte
thì phải tính lại cả hai giá trị.

## 6. Cập nhật manifest `latest.json`

Tạo hoặc sửa `local_update_feed/latest.json`:

```json
{
  "version": "1.2.0",
  "mandatory": true,
  "downloadUrl": "http://127.0.0.1:8080/artifacts/launcher-1.2.0.zip",
  "size": 14031478,
  "sha256": "thay-bằng-sha256-thực-tế-của-zip",
  "signature": "",
  "entryExecutable": "ai_agent_launcher.exe",
  "releaseNotes": ["Kiểm thử cập nhật launcher cục bộ"]
}
```

- `version` phải lớn hơn version cài trong fixture.
- `size` là số nguyên, không đặt trong dấu nháy.
- `sha256` phải viết thường và khớp tuyệt đối với ZIP.
- `mandatory: true` khiến bản cũ tự update.
- Chữ ký trống chỉ được chấp nhận vì build local bật
  `ALLOW_UNSIGNED_UPDATES=true`.

## 7. Chạy server local

Mở một cửa sổ PowerShell riêng:

```powershell
Set-Location D:\ai-agent-launcher\local_update_feed
fvm dart run server.dart
```

Giữ cửa sổ này mở trong suốt bài test. Kiểm tra manifest và ZIP:

```powershell
Invoke-RestMethod http://127.0.0.1:8080/latest.json
Invoke-WebRequest `
  http://127.0.0.1:8080/artifacts/launcher-1.2.0.zip `
  -Method Head
```

Cả hai request phải thành công trước khi mở launcher cũ.

## 8. Chạy update từ bản cũ

```powershell
Set-Location `
  D:\ai-agent-launcher\local_update_feed\test_install_replay\current
.\ai_agent_launcher.exe
```

Luồng mong đợi:

1. Bản `1.1.0+2` mở màn hình startup.
2. Launcher đọc `latest.json` và phát hiện `1.2.0`.
3. Thanh tiến trình chỉ xuất hiện khi có update.
4. ZIP được tải vào file `.zip.part`.
5. Updater kiểm tra size và SHA-256.
6. ZIP hợp lệ được đổi thành `1.2.0.zip` và giải nén vào staging.
7. Launcher cũ sao chép helper sang `%TEMP%`, sau đó tự thoát.
8. Helper đổi `current` cũ thành `current.backup-<timestamp>`.
9. Staging được đổi thành `current` mới.
10. Launcher mới mở, ghi health marker và helper tự thoát.
11. Launcher mới vào màn hình đăng nhập nếu manifest không còn version cao hơn.

Không mở lại executable bằng tay khi helper đang đổi thư mục.

## 9. Xác minh kết quả

```powershell
$trialRoot = "D:\ai-agent-launcher\local_update_feed\test_install_replay"
$current = Join-Path $trialRoot "current"
$backup = Get-ChildItem $trialRoot `
  -Directory `
  -Filter "current.backup-*" |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

(Get-Item "$current\ai_agent_launcher.exe").VersionInfo.ProductVersion
(Get-Item "$($backup.FullName)\ai_agent_launcher.exe").VersionInfo.ProductVersion
Test-Path "$current\window_manager_plugin.dll"
Test-Path "$($backup.FullName)\window_manager_plugin.dll"
Test-Path "$trialRoot\.launcher-update\1.2.0.zip.part"
Get-Process ai_agent_launcher -ErrorAction SilentlyContinue |
  Select-Object Id, Path
```

Kết quả đạt:

- `current` là `1.2.0+3`.
- Backup là `1.1.0+2`.
- `window_manager_plugin.dll` không có trong `current` mới.
- `window_manager_plugin.dll` vẫn có trong backup cũ.
- Không còn `.zip.part`.
- Chỉ còn tiến trình launcher mới; helper trong `%TEMP%` đã thoát.
- Log server có request `GET /latest.json` và `GET` gói ZIP.

## 10. DLL bị loại bỏ ở version mới

Updater không trộn file mới vào bản cũ. Nó thay nguyên thư mục `current` bằng
thư mục staging đã xác minh. Vì vậy DLL chỉ dùng ở version cũ sẽ không còn trong
`current` mới và chỉ được giữ trong backup. Đây là kết quả đúng.

Nếu tiến trình khác vẫn khóa DLL hoặc executable cũ, Windows có thể chặn thao
tác đổi tên. Updater sẽ thử lại; nếu launcher mới không ghi health marker, nó
đổi bản lỗi thành `current.failed-*`, phục hồi backup và mở lại bản cũ. Không
xóa backup trước khi đã xác nhận bản mới hoạt động ổn định.

## 11. Kiểm thử các tình huống lỗi

Mỗi tình huống phải bắt đầu từ một bản sao mới của fixture.

### SHA-256 sai

Sửa một ký tự trong `sha256`, chạy bản cũ và xác nhận updater từ chối apply.
Sau đó khôi phục hash đúng trước bài test tiếp theo.

### Size sai

Tăng hoặc giảm `size` trong manifest. Updater phải báo lỗi xác minh và giữ
nguyên bản cũ.

### ZIP thiếu executable

Tạo ZIP không có `ai_agent_launcher.exe` ở root, cập nhật lại size/hash rồi
chạy. Updater phải từ chối staging trước khi apply.

### Mất kết nối

Dừng server khi đang tải. Phải xuất hiện `.zip.part`. Sau khi bật lại server và
thử lại, server hỗ trợ HTTP Range phải trả `206`; nếu trả `200`, updater sẽ xóa
phần tải dở và tải lại toàn bộ theo thiết kế.

### Launcher mới không healthy

Ca này cần artifact test riêng cố ý thoát trước khi ghi health marker. Sau thời
gian chờ, helper phải giữ bản lỗi trong `current.failed-*`, phục hồi backup và
mở lại bản cũ. Không đưa artifact lỗi này lên staging hoặc production.

### Sửa dữ liệu update

Nút `SỬA DỮ LIỆU CẬP NHẬT` xóa `.zip.part` và staging cũ, nhưng không xóa ZIP
đã xác minh, backup hoặc launcher hiện tại.

## 12. Kết thúc bài test

1. Xác nhận launcher mới hoạt động và helper đã thoát.
2. Dừng server bằng `Ctrl+C`.
3. Giữ nguyên fixture gốc và ZIP khôi phục.
4. Chỉ xóa thư mục trial do chính bài test tạo khi chắc chắn không cần log hoặc
   backup của lần chạy đó.

Không xóa hàng loạt `test_install_*` vì trong đó có fixture được bảo quản.
