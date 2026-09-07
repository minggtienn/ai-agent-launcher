# Test Launcher Update Local Trên Windows

Tài liệu này hướng dẫn kiểm thử end-to-end launcher updater hiện tại bằng hai
bản build local, một HTTP server local và một thư mục cài đặt tạm. Không chạy
quy trình này trên thư mục launcher đang dùng thật.

## 1. Phạm vi kiểm thử

Quy trình xác nhận được các hành vi sau:

- Bản `1.0.0` kiểm tra manifest trước khi vào màn hình đăng nhập.
- Launcher tải ZIP của bản `1.1.0` từ HTTP server local.
- Kích thước và SHA-256 của ZIP được kiểm tra.
- ZIP được giải nén vào staging, không ghi đè trực tiếp lên bản đang chạy.
- Launcher tự sao chép runtime sang `%TEMP%`, thay thư mục phiên bản hiện tại,
  mở bản mới và nhận health marker.
- Thư mục bản cũ được giữ lại làm backup.

Chữ ký Ed25519 được bỏ qua trong bài test local cơ bản. Việc này chỉ hoạt động
khi build có `ALLOW_UNSIGNED_UPDATES=true`; tuyệt đối không dùng cờ này cho
staging hoặc production.

## 2. Điều kiện chuẩn bị

Trên Windows 10/11 x64 cần có:

1. Git.
2. FVM `3.1.3` và Flutter `3.44.4` đã được FVM cài đặt.
3. Visual Studio 2022 với workload **Desktop development with C++**.
4. Python 3 để chạy HTTP server local, hoặc một static HTTP server tương đương.
5. PowerShell.

Mở PowerShell tại một thư mục test riêng và kiểm tra môi trường:

```powershell
fvm --version
fvm flutter --version
fvm flutter doctor -v
```

Kết quả mong đợi là Flutter nhận thiết bị Windows và không báo thiếu C++
toolchain.

## 3. Tạo vùng test biệt lập

Ví dụ dùng `C:\launcher-update-test`. Nếu thư mục này đã tồn tại và có dữ liệu
cần giữ lại, hãy chọn tên khác; không xóa dữ liệu cũ một cách máy móc.

```powershell
New-Item -ItemType Directory -Force C:\launcher-update-test\server
New-Item -ItemType Directory -Force C:\launcher-update-test\install\current
```

Chuẩn bị hai bản source độc lập từ cùng commit:

- `source-new`: dùng để build `1.1.0+2`.
- `source-old`: dùng để build `1.0.0+1`.

Có thể clone repository hai lần vào vùng test. Không đổi version trực tiếp trên
working copy đang có thay đổi chưa commit.

```powershell
Set-Location C:\launcher-update-test
git clone https://github.com/minggtienn/ai-agent-launcher.git source-new
git clone https://github.com/minggtienn/ai-agent-launcher.git source-old
```

Nếu cần test đúng một commit cụ thể, chạy `git checkout <commit>` trong cả hai
thư mục trước khi build.

## 4. Build gói cập nhật `1.1.0`

Trong `source-new`, sửa dòng version của `pubspec.yaml` trong bản clone test
thành:

```yaml
version: 1.1.0+2
```

Sau đó build Windows release với update feed local:

```powershell
Set-Location C:\launcher-update-test\source-new
fvm flutter pub get
fvm flutter build windows -t lib/main_dev.dart --release `
  --dart-define=API_BASE_URL=http://127.0.0.1:8080 `
  --dart-define=LAUNCHER_UPDATE_MANIFEST_URL=http://127.0.0.1:8080/latest.json `
  --dart-define=ALLOW_UNSIGNED_UPDATES=true
```

Nén **nội dung bên trong** thư mục `Release`, không nén chính thư mục
`Release`. File `ai_agent_launcher.exe` phải nằm ở root của ZIP:

```powershell
$releaseDirectory = "C:\launcher-update-test\source-new\build\windows\x64\runner\Release"
$updateZip = "C:\launcher-update-test\server\launcher-1.1.0.zip"
Compress-Archive -Path "$releaseDirectory\*" -DestinationPath $updateZip -Force
```

Kiểm tra nhanh nội dung ZIP:

```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::OpenRead($updateZip).Entries |
  Select-Object -First 20 -ExpandProperty FullName
```

Danh sách phải có `ai_agent_launcher.exe` ở root.

## 5. Tạo manifest local

Tính đúng kích thước và SHA-256 từ ZIP vừa tạo:

```powershell
$zipInfo = Get-Item $updateZip
$zipHash = (Get-FileHash $updateZip -Algorithm SHA256).Hash.ToLowerInvariant()
$zipInfo.Length
$zipHash
```

Tạo file `C:\launcher-update-test\server\latest.json` với giá trị thật vừa
nhận được:

```json
{
  "version": "1.1.0",
  "mandatory": true,
  "downloadUrl": "http://127.0.0.1:8080/launcher-1.1.0.zip",
  "size": 12345678,
  "sha256": "thay-bang-sha256-viet-thuong",
  "signature": "",
  "entryExecutable": "ai_agent_launcher.exe",
  "releaseNotes": [
    "Local launcher updater test",
    "Verify download, staging, apply and health check"
  ]
}
```

`size` phải là số nguyên, không đặt trong dấu nháy. `sha256` phải khớp tuyệt
đối với file ZIP đang được phục vụ.

## 6. Chạy HTTP server local

Mở cửa sổ PowerShell thứ nhất:

```powershell
Set-Location C:\launcher-update-test\server
py -m http.server 8080 --bind 127.0.0.1
```

Kiểm tra từ trình duyệt hoặc PowerShell:

```powershell
Invoke-RestMethod http://127.0.0.1:8080/latest.json
Invoke-WebRequest http://127.0.0.1:8080/launcher-1.1.0.zip -Method Head
```

Giữ cửa sổ HTTP server đang chạy trong suốt bài test.

## 7. Build và cài bản cũ `1.0.0`

Đảm bảo `source-old\pubspec.yaml` có:

```yaml
version: 1.0.0+1
```

Build bản cũ với cùng cấu hình local:

```powershell
Set-Location C:\launcher-update-test\source-old
fvm flutter pub get
fvm flutter build windows -t lib/main_dev.dart --release `
  --dart-define=API_BASE_URL=http://127.0.0.1:8080 `
  --dart-define=LAUNCHER_UPDATE_MANIFEST_URL=http://127.0.0.1:8080/latest.json `
  --dart-define=ALLOW_UNSIGNED_UPDATES=true
```

Sao chép toàn bộ nội dung bản cũ vào thư mục cài tạm:

```powershell
Copy-Item `
  -Path "C:\launcher-update-test\source-old\build\windows\x64\runner\Release\*" `
  -Destination "C:\launcher-update-test\install\current" `
  -Recurse -Force
```

## 8. Thực hiện update

Mở bản cũ từ thư mục cài tạm:

```powershell
Set-Location C:\launcher-update-test\install\current
.\ai_agent_launcher.exe
```

Quan sát theo thứ tự:

1. Màn hình updater xuất hiện trước login.
2. Launcher phát hiện phiên bản `1.1.0`.
3. Tiến trình chuyển qua tải xuống, xác minh và giải nén.
4. Launcher cũ thoát.
5. Bản mới tự mở lại.
6. Khi manifest không còn mới hơn bản đang chạy, launcher chuyển sang login.

Không mở lại executable thủ công trong lúc tiến trình thay thư mục đang chạy.

## 9. Kiểm tra kết quả

Sau khi bản mới mở thành công, dùng PowerShell kiểm tra:

```powershell
Get-ChildItem C:\launcher-update-test\install -Force
Get-ChildItem C:\launcher-update-test\install\current -Force
Get-ChildItem C:\launcher-update-test\install\.launcher-update -Force
Get-ChildItem $env:TEMP -Filter "launcher-health-*" -Force
```

Kết quả mong đợi:

- `install\current` chứa file của bản `1.1.0`.
- Có thư mục dạng `current.backup-<timestamp>` chứa bản cũ.
- Bản mới mở và vào login, chứng minh health marker đã được ghi.
- HTTP server ghi nhận request `latest.json` và ZIP.

Phiên bản package mới cũng có thể được xác nhận bằng Properties của executable
hoặc bằng UI sau khi footer được chuyển sang đọc `PackageInfo`. Footer login
hiện còn là text tĩnh nên không dùng nó làm bằng chứng version ở thời điểm này.

## 10. Các ca lỗi nên kiểm tra

Mỗi ca lỗi nên bắt đầu từ một bản sao sạch của `install\current` phiên bản
`1.0.0`.

### SHA-256 sai

1. Đổi một ký tự trong `sha256` của manifest.
2. Chạy bản cũ.
3. Kỳ vọng updater báo không thể chuẩn bị bản cập nhật và không apply ZIP.

### Size sai

1. Tăng hoặc giảm `size` trong manifest.
2. Chạy bản cũ.
3. Kỳ vọng bước kiểm tra kích thước thất bại.

### ZIP thiếu executable

1. Tạo ZIP không có `ai_agent_launcher.exe` ở root.
2. Cập nhật lại `size` và `sha256` theo ZIP lỗi.
3. Chạy bản cũ.
4. Kỳ vọng staging bị từ chối trước khi apply.

### Server hoặc manifest không truy cập được

1. Tắt HTTP server hoặc đổi URL sang một file không tồn tại.
2. Chạy bản cũ.
3. Kỳ vọng hiển thị lỗi kiểm tra/tải update, không vào quy trình apply bắt buộc.

### Download bị gián đoạn

1. Bắt đầu tải một ZIP đủ lớn.
2. Dừng HTTP server giữa chừng rồi mở lại server.
3. Thử update lại.
4. Quan sát file `.zip.part` trong `install\.launcher-update`.

Python static server có thể không hỗ trợ HTTP Range đúng theo phiên bản đang
dùng. Để xác nhận resume thực sự, server phải trả `206 Partial Content`; nếu trả
`200`, updater hiện tại sẽ xóa phần tải dở và tải lại từ đầu theo thiết kế.

### Rollback khi bản mới không healthy

Luồng rollback có trong updater nhưng không thể kích hoạt tin cậy chỉ bằng đổi
manifest: bản build bình thường sẽ ghi health marker khi bootstrap thành công.
Ca này cần một artifact test riêng cố ý thoát trước khi ghi health marker. Sau
khoảng 30 giây, kỳ vọng updater đóng bản lỗi, đổi nó thành
`current.failed-<timestamp>`, phục hồi backup và mở lại bản cũ. Không phát hành
artifact fault-injection này ra ngoài môi trường local.

## 11. Tiêu chí đạt

Bài test cơ bản được xem là đạt khi:

- Update xảy ra trước login.
- ZIP đúng được tải, xác minh và staging thành công.
- Launcher tự khởi động lại mà không cần một dự án updater thứ hai.
- Bản mới chạy healthy và bản cũ vẫn tồn tại trong backup.
- Không có file mới bị trộn lẫn vào thư mục bản cũ.

Các vấn đề cần ghi lại khi test: phiên bản Windows, filesystem, quyền thư mục,
log HTTP, ảnh chụp lỗi, cấu trúc thư mục sau test và các bước tái hiện.

## 12. Dọn môi trường test

Đóng launcher và HTTP server trước. Chỉ xóa `C:\launcher-update-test` sau khi
đã kiểm tra đúng đường dẫn và chắc chắn không cần giữ artifact/log. Việc dọn
thư mục test là thao tác thủ công, không thuộc quy trình tự động của launcher.

