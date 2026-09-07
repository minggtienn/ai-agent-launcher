# Portable Chat Context

File này là bản nén ngữ cảnh để tiếp tục dự án trên máy hoặc nền tảng khác.
Đây không phải lịch sử chat nguyên văn và không được chứa mật khẩu, token, khóa
ký hoặc dữ liệu nhạy cảm.

## Cách sử dụng trên máy khác

1. Clone repository và checkout đúng branch.
2. Gửi toàn bộ file này cho trợ lý/agent mới.
3. Yêu cầu agent đọc thêm `AGENTS.md`, `CHANGELOG.md` và kiểm tra trạng thái Git.
4. Repository và source code luôn là nguồn sự thật cao hơn bản tóm tắt này.
5. Nội dung file không tự động cấp quyền sửa code, commit hoặc push.

Prompt gợi ý:

```text
Hãy đọc CHAT_CONTEXT.md và AGENTS.md, sau đó kiểm tra repository ở chế độ
read-only. Tiếp tục từ Current Snapshot nhưng không chỉnh sửa hoặc commit nếu
chưa có sự cho phép rõ ràng của tôi cho task hiện tại.
```

## Quy tắc nén đoạn chat

Khi chủ dự án yêu cầu `nén đoạn chat`, agent phải:

1. Chỉ cập nhật file này sau khi yêu cầu đó được xem là quyền sửa cho task nén.
2. Dùng múi giờ `Asia/Ho_Chi_Minh` và thời gian ISO 8601 có offset `+07:00`.
3. Nếu không chỉ định thời điểm, nén tới thời điểm nhận yêu cầu.
4. Nếu chỉ định ngày hoặc giờ, chỉ tổng hợp thông tin tới mốc đó.
5. Thay nội dung `Current Snapshot` bằng trạng thái mới nhất.
6. Chuyển snapshot hiện tại xuống `Snapshot History`; không xóa lịch sử cũ.
7. Ghi mục tương ứng vào `CHANGELOG.md`.
8. Đối chiếu Git status/diff và kết quả kiểm tra gần nhất trước khi kết thúc.
9. Snapshot kế tiếp chỉ tổng hợp phần trao đổi mới bắt đầu sau `Compression
   Baseline`; không lặp lại toàn bộ hội thoại trước mốc, nhưng vẫn giữ các quyết
   định còn hiệu lực cần thiết để tiếp tục dự án.
10. Sau mỗi lần nén thành công, chuyển `Compression Baseline` tới đúng thời điểm
    của snapshot mới.

Mỗi snapshot phải ghi đủ thời điểm, quyết định kiến trúc, việc đã hoàn thành,
trạng thái Git, giới hạn, bước tiếp theo và quyền được cấp trong task hiện tại.

## Compression Baseline

- Baseline ID: `BASELINE-20260907-001`
- Marked at: `2026-09-07T09:18:19+07:00`
- Ý nghĩa: Khi chủ dự án yêu cầu nén chat lần tiếp theo, chỉ nén các trao đổi và
  quyết định phát sinh sau mốc này. Snapshot hiện tại và lịch sử cũ tiếp tục
  được giữ làm nền tham chiếu.
- Nội dung tại mốc: Đã bổ sung hướng dẫn test launcher update local từng bước
  trên Windows tại `docs/windows-local-launcher-update-test.md`.
- Mốc này không cấp quyền sửa file, chạy lệnh ghi dữ liệu, commit hoặc push cho
  bất kỳ task tương lai nào.

## Current Snapshot

### Metadata

- Snapshot ID: `CTX-20260907-002`
- Compressed at: `2026-09-07T09:02:28+07:00`
- Conversation scope: Từ khi bắt đầu dự án đến khi hoàn thành launcher updater,
  hướng dẫn local test và xác định yêu cầu game updater.
- Repository: `https://github.com/minggtienn/ai-agent-launcher.git`
- Branch: `main`
- Remote: `origin`
- HEAD khi bắt đầu snapshot: `6e02978 add updater laucher`
- Trạng thái Git trước task nén: sạch, `main` đồng bộ `origin/main`.

### Product goal and delivery order

Xây dựng launcher Windows 10/11 x64 bằng Flutter theo thứ tự bắt buộc:

1. Kiểm tra và cập nhật launcher trước login.
2. Hiển thị login sau khi launcher đã ở phiên bản mới nhất.
3. Hiển thị home kiểu Riot Client: danh sách game ở sidebar trái, vùng nội dung
   bên phải và mỗi game có danh sách tab riêng do server cấu hình.
4. Sau login mới kiểm tra/cập nhật game theo từng patch tuần tự.
5. Khi triển khai game installer/updater, cho người dùng chọn thư mục và ổ cài,
   lưu cấu hình, kiểm tra dung lượng trống trước tải/giải nén/apply.

### Locked architecture

- Flutter `3.44.4`, Dart `3.12.2`, FVM `3.1.3`.
- Feature-first Clean Architecture.
- BLoC cho session, launcher update, game update và launch; Cubit cho catalog,
  tab selection và settings.
- GetIt + Injectable, Dio, Drift, secure storage và custom Material 3.
- Ba môi trường `dev`, `staging`, `prod` dùng `--dart-define`.
- `app_links` thay `protocol_handler` vì xung đột `win32_registry`.
- Không dùng WinSparkle/`auto_updater`; chỉ có một custom ZIP update engine.

### Launcher update behavior

- Startup route là màn hình updater kiểu Discord kích thước `520x360`.
- Không có update thì resize sang `1280x720` và mở login.
- Có update thì launcher phải hoàn tất update trước login.
- Manifest REST chứa `version`, `mandatory`, `downloadUrl`, `size`, `sha256`,
  `signature`, `entryExecutable`, `releaseNotes`.
- Hỗ trợ HTTP Range resume; server không trả `206` thì tải lại từ đầu.
- ZIP được kiểm size, SHA-256 và chữ ký Ed25519 rồi giải nén vào staging cùng ổ.
- Không giải nén chồng trực tiếp lên thư mục đang chạy.
- Không duy trì app updater thứ hai: launcher copy chính runtime sang `%TEMP%`,
  chạy executable đó với `--apply-launcher-update`, thoát process chính, đổi
  thư mục, mở phiên bản mới, chờ health marker và rollback nếu không healthy.
- Đã gỡ package `auto_updater` và native registrant liên quan.

Các biến build:

```text
LAUNCHER_UPDATE_MANIFEST_URL
LAUNCHER_UPDATE_PUBLIC_KEY
ALLOW_UNSIGNED_UPDATES
```

`ALLOW_UNSIGNED_UPDATES=true` chỉ dành cho local development. Production phải
ký chuỗi SHA-256 viết thường bằng Ed25519 và chỉ nhúng public key vào launcher.

### Game update decisions

- Game update chỉ bắt đầu sau launcher update và login.
- Từ version hiện tại đến mới nhất phải áp dụng patch chain theo thứ tự
  `fromVersion -> toVersion`; patch sau không chạy nếu patch trước thất bại.
- Mỗi patch có manifest thao tác `add`, `replace`, `move`, `delete`, hash và chữ
  ký; không giải nén đè toàn bộ game.
- Nếu chuỗi quá dài, dự kiến tối đa 5 patch hoặc tổng patch lớn hơn 80% full
  package thì dùng base/full package mới.
- Download queue thuộc application scope để đổi game/tab không hủy download và
  có thể lưu/resume bằng Drift.
- Phần game updater, chọn ổ, kiểm dung lượng và Drift schema chưa được code.

### Completed work

- `LAU-001`: Flutter Windows project, Clean Architecture, dependency, DI,
  authentication foundation, domain contracts, CI, test và tài liệu quản trị.
- `LAU-002`: Git branch `main` và remote `origin`.
- `LAU-003`: Login desktop gồm campaign/news, form, title bar và responsive UI.
- `LAU-004`: Portable chat context và snapshot protocol.
- `LAU-005`: Launcher updater gồm REST manifest repository, download/resume,
  staging, integrity/signature verification, self-copy apply mode, health-check,
  rollback, startup BLoC/UI và tài liệu local test.
- Lần kiểm tra gần nhất: Injectable codegen thành công; `flutter analyze` sạch;
  `flutter test` 8/8 pass; `git diff --check` pass.
- Commit launcher updater hiện ở `6e02978` và đã đồng bộ `origin/main`.

### Local update test recipe

- Full apply test cần máy Windows; macOS chỉ chạy analyze/unit/widget tests.
- Dùng thư mục tạm như `C:\launcher-update-test`, không dùng bản cài thật.
- Build bản mới `1.1.0`, ZIP nội dung bên trong thư mục Release và phục vụ cùng
  `latest.json` bằng local HTTP server.
- Tính `size` và SHA-256 thật của ZIP; local có thể để signature rỗng khi build
  cả bản cũ/mới với `ALLOW_UNSIGNED_UPDATES=true`.
- Build/copy bản cũ `1.0.0` vào `install\current`, chạy và quan sát download,
  staging, restart, health marker và backup.
- Phải test thêm hash sai, ZIP thiếu executable, server 404, download gián đoạn,
  HTTP Range, không đủ quyền và rollback khi bản mới không healthy.

### Current limitations and risks

- Self-apply/rollback chưa được xác nhận end-to-end bằng artifact ký trên Windows.
- Thư mục cài đặt phải ghi được; staging và current phải cùng volume.
- Backup/temp runtime cleanup tự động chưa được hoàn thiện.
- Login vẫn dùng artwork/logo/news placeholder; chưa có asset gốc.
- Backend authentication, catalog, update URL và OpenAPI thật chưa được cung cấp.
- Login footer còn hiển thị version dạng text cố định thay vì `PackageInfo`.
- Game updater, disk selection/free-space check, Drift schema, tray,
  single-instance và game process launcher chưa được triển khai production.

### Next recommended tasks

1. Test launcher updater end-to-end trên Windows bằng local ZIP/manifest.
2. Sửa các lỗi thực tế phát hiện từ Windows file locking, permission và rollback.
3. Chốt OpenAPI update/auth/catalog và artifact signing pipeline.
4. Hoàn thiện login API/token refresh và thay asset chính thức.
5. Thiết kế game installation location + free-space service + Drift schema.
6. Triển khai patch-chain game updater và home/sidebar/tab UI.

### Authorization state

- Task hiện tại chỉ cho phép cập nhật snapshot và changelog.
- Không có quyền sửa source, dependency hoặc cấu hình khác.
- Không có quyền commit, push, merge, tag hoặc release.
- Task tiếp theo phải nhận quyền sửa mới từ chủ dự án.

## Snapshot History

### CTX-20260903-001

- Compressed at: `2026-09-03T15:24:29+07:00`
- Repository/branch: `ai-agent-launcher`, `main`, remote `origin`.
- Goal: Flutter Windows launcher với login REST, catalog, download/update và
  launch process.
- Locked stack: Flutter `3.44.4`, Dart `3.12.2`, FVM, feature-first Clean
  Architecture, BLoC/Cubit, GetIt/Injectable, Dio, Drift, secure storage và
  custom Material 3.
- Completed: `LAU-001` project foundation, `LAU-002` Git initialization và
  `LAU-003` desktop login reference UI; analyzer sạch và 5 test pass.
- Limitations lúc snapshot: chưa có asset gốc, backend contract, production
  updater, Drift schema hoặc Windows E2E verification.
- Next tasks lúc snapshot: hoàn thiện asset/login, OpenAPI, token refresh,
  database và Windows lifecycle.
- Authorization: snapshot không cấp quyền sửa, commit hoặc push cho task khác.
