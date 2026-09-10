# Nhật ký thay đổi kỹ thuật

Nhật ký chỉ được nối thêm này ghi đúng một entry cho mỗi task hoặc pull request.

## [LAU-010] Tự động hóa kiểm thử updater local

- Ngày: 2026-09-10
- Tác giả: Codex, theo yêu cầu của chủ dự án
- Loại: Thêm mới, tài liệu, kiểm thử
- Module: Công cụ kiểm thử launcher updater
- Môi trường: Development, Windows local
- Thay đổi phá vỡ tương thích: Không

### Mục đích và thay đổi

- Thêm script PowerShell hỗ trợ quy trình `Quick` tự động toàn bộ.
- Thêm quy trình hai giai đoạn: mở đầy đủ bản cũ với manifest cùng version, đóng
  launcher, công bố update mới rồi mở lại để thực hiện update.
- Thêm các action `PrepareOld`, `PublishUpdate`, `RunUpdate`, `Verify` và
  `StopServer`.
- Thêm tài liệu tiếng Việt riêng với lệnh, kết quả mong đợi và cách xử lý lỗi.
- Bỏ qua PID server local do script tạo.

### Xác minh

- PowerShell parser, analyzer/test repository và bài smoke test của script.

### Rủi ro và rollback

- `ALLOW_UNSIGNED_UPDATES=true` chỉ dành cho môi trường local được kiểm soát.
- `-ForceArtifact` có thể thay đúng artifact trùng version; mặc định script từ
  chối ghi đè.

## [LAU-009] Hoàn thiện updater Windows và giao diện cửa sổ

- Ngày: 2026-09-08
- Tác giả: Codex, theo yêu cầu của chủ dự án
- Loại: Thêm mới, thay đổi, sửa lỗi, kiểm thử, tài liệu
- Module: launcher updater, xác thực, Windows runner
- Môi trường: Tất cả, Windows
- Thay đổi phá vỡ tương thích: Không
- Migration/cấu hình: Thay `window_manager` bằng `bitsdojo_window`

### Mục đích

Hoàn thiện luồng tự cập nhật trên Windows, hiển thị đúng version runtime, bổ
sung khả năng sửa dữ liệu update, cải thiện startup và loại bỏ lỗi khung cửa sổ.

### Thay đổi

- Thêm completion marker để helper tạm thoát sau apply hoặc rollback.
- Footer đăng nhập đọc version và build number từ `PackageInfo`.
- Thêm thao tác kiểm tra update development và sửa download/staging bị lỗi.
- Thêm nguồn update local, artifact và fixture kiểm thử bị Git bỏ qua.
- Đặt Flutter binding và `runApp` trong cùng guarded zone.
- Startup chỉ hiện tiến trình khi có update; nếu đã mới nhất thì tự vào login.
- Brand startup có hai dòng ở giữa và reveal đồng thời từ trái sang phải.
- Dùng `bitsdojo_window` cho custom frame, kích thước, vị trí, kéo cửa sổ,
  minimize và close; không còn workaround trong `win32_window.cpp`.
- Ẩn cửa sổ khi chuyển route/kích thước, sau đó căn giữa và hiện frame login.
- Giữ fixture `window_manager` 1.1.0+2 và ZIP khôi phục chỉ đọc có SHA-256.
- Xác minh E2E update từ 1.1.0+2 lên `bitsdojo_window` 1.2.0+3, gồm download,
  hash, staging, backup, health marker, DLL cũ được loại bỏ và helper tự thoát.
- Việt hóa toàn bộ tài liệu Markdown và bổ sung hướng dẫn test updater chi tiết.

### Xác minh

- `fvm flutter analyze`: không có lỗi.
- `fvm flutter test`: 9/9 test thành công.
- `git diff --check`: thành công.
- Build Windows Debug và Release thành công.
- E2E Windows local thành công; backup cũ khớp hash fixture.

### Rủi ro và rollback

- Test rollback không healthy cần artifact fault-injection riêng.
- Chỉ hoàn tác task sau khi chủ dự án cho phép rõ ràng.

### Tham chiếu

- Ticket: LAU-009
- Pull request: Chưa tạo
- Thiết kế: `docs/windows-local-launcher-update-test.md`
- Fixture: `local_update_feed/README.md`

## [LAU-008] Hoàn thiện ngữ cảnh chuyển giao sau mốc nén

- Ngày: 2026-09-08
- Loại: Thay đổi, tài liệu
- Module: Giao tiếp dự án, quản trị

### Mục đích và thay đổi

- Đồng bộ snapshot chuyển giao với trao đổi và trạng thái repository mới nhất.
- Thêm `CTX-20260908-003`, lưu `CTX-20260907-002` vào lịch sử và chuyển mốc
  nén sang `BASELINE-20260908-002`.
- Ghi nhận tài liệu test updater Windows và giới hạn của link chia sẻ chat.

### Xác minh và rủi ro

- Đối chiếu Git status/log, tài liệu test và các quyết định gần nhất.
- Chỉ thay đổi tài liệu; repository luôn là nguồn sự thật nếu snapshot cũ.

## [LAU-007] Tài liệu hóa kiểm thử launcher update local trên Windows

- Ngày: 2026-09-07
- Loại: Thêm mới, thay đổi, tài liệu
- Module: Launcher updater, giao tiếp dự án

### Mục đích và thay đổi

- Thêm quy trình Windows từng bước cho build hai version, đóng gói ZIP, tạo
  manifest, chạy HTTP local, apply, xác minh và các tình huống lỗi.
- Ghi rõ giới hạn HTTP Range và yêu cầu artifact riêng để test rollback.
- Thêm `BASELINE-20260907-001` cho lần nén hội thoại tiếp theo.

### Xác minh và rủi ro

- Đối chiếu lệnh, field manifest và cấu trúc thư mục với implementation updater.
- Tại thời điểm task, hành vi Windows thực tế vẫn cần chạy trên máy Windows.

## [LAU-006] Cập nhật ngữ cảnh chuyển giao sau launcher updater

- Ngày: 2026-09-07
- Loại: Thay đổi, tài liệu
- Module: Giao tiếp dự án, quản trị

### Mục đích và thay đổi

- Thay snapshot hiện tại bằng `CTX-20260907-002` và lưu snapshot cũ vào lịch sử.
- Ghi lại self-update, quy trình test Windows, quyết định game patch, giới hạn
  hiện tại và các task tiếp theo.

### Xác minh và rủi ro

- Đối chiếu snapshot với Git status/log và kết quả analyzer/test gần nhất.
- Repository luôn là nguồn sự thật nếu snapshot trở nên cũ.

## [LAU-005] Xây dựng nền tảng tự cập nhật launcher

- Ngày: 2026-09-04
- Loại: Thêm mới, thay đổi, bảo mật
- Module: Launcher updater, startup routing, vòng đời Windows
- Cấu hình: Manifest URL và public key Ed25519

### Mục đích và thay đổi

- Kiểm tra update trước login với giao diện tiến trình gọn.
- Tải ZIP có resume, kiểm size, SHA-256 và chữ ký rồi giải nén staging an toàn.
- Copy runtime sang `%TEMP%`, apply bằng helper, health check và rollback.
- Bổ sung cấu hình, test và tài liệu release; game updater để task sau.

### Xác minh và rủi ro

- Injectable codegen thành công; analyzer sạch; 8 test thành công.
- Thư mục cài phải ghi được và staging phải ở cùng volume.
- Apply/rollback production cần artifact đã ký và kiểm thử Windows.

## [LAU-004] Thêm ngữ cảnh hội thoại có thể chuyển giao

- Ngày: 2026-09-03
- Loại: Thêm mới, tài liệu
- Module: Giao tiếp dự án, quản trị

### Mục đích và thay đổi

- Thêm `CHAT_CONTEXT.md` để chuyển trạng thái dự án giữa máy và hội thoại.
- Định nghĩa quy trình snapshot và giữ ranh giới quyền hạn; snapshot không tự
  cấp quyền sửa file hoặc thao tác Git cho agent khác.

### Xác minh và rủi ro

- Đối chiếu snapshot với `AGENTS.md`, changelog và trạng thái Git.
- Snapshot có thể cũ; repository luôn là nguồn sự thật.

## [LAU-003] Triển khai màn hình đăng nhập desktop

- Ngày: 2026-09-03
- Loại: Thêm mới, thay đổi
- Module: Giao diện xác thực, cửa sổ desktop

### Mục đích và thay đổi

- Thêm bố cục responsive gồm campaign, tin tức và đăng nhập.
- Thêm validation, ẩn/hiện mật khẩu, thao tác phụ, title bar và window controls.
- Giữ artwork dưới dạng widget có thể thay thế khi nhận asset chính thức.

### Xác minh và rủi ro

- Analyzer sạch; test bố cục login 1280x720 thành công.
- Độ chính xác hình ảnh cuối phụ thuộc asset banner, logo và tin tức gốc.

## [LAU-002] Khởi tạo Git repository

- Ngày: 2026-09-03
- Loại: Thay đổi
- Module: Cấu hình repository

### Mục đích và thay đổi

- Khởi tạo Git với branch mặc định `main`.
- Thêm `https://github.com/minggtienn/ai-agent-launcher.git` làm `origin`.

### Xác minh và rủi ro

- `git remote -v` và `git status` trả đúng cấu hình mong đợi.
- Không commit hoặc push source trong task này.

## [LAU-001] Khởi tạo kiến trúc Flutter Windows launcher

- Ngày: 2026-09-03
- Loại: Thêm mới, thay đổi, dependency, tài liệu
- Module: Nền tảng dự án, application shell, quản trị
- Cấu hình: Cố định Flutter `3.44.4` bằng FVM

### Mục đích và thay đổi

- Tạo nền tảng Flutter Windows theo Clean Architecture tổ chức theo tính năng,
  BLoC/Cubit, GetIt/Injectable và contract hướng REST.
- Thêm cấu hình ứng dụng, core contracts và ranh giới tính năng.
- Thay `protocol_handler` bằng `app_links` do xung đột dependency registry.
- Thêm tài liệu kiến trúc và quản trị.

### Xác minh và rủi ro

- Analyzer sạch; 4 test thành công; Injectable codegen thành công.
- Tại thời điểm task, build Windows release còn chờ Windows runner.
