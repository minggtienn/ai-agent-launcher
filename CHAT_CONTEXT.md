# Ngữ cảnh hội thoại có thể chuyển giao

File này là bản nén ngữ cảnh để tiếp tục dự án trên máy hoặc nền tảng khác.
Đây không phải lịch sử chat nguyên văn và không được chứa mật khẩu, token, khóa
ký hoặc dữ liệu nhạy cảm.

## Cách sử dụng trên máy khác

1. Clone repository và checkout đúng branch.
2. Yêu cầu agent đọc `AGENTS.md`, `CHAT_CONTEXT.md`, `CHANGELOG.md` và các tài
   liệu được snapshot tham chiếu.
3. Yêu cầu agent kiểm tra Git status/log ở chế độ read-only trước khi làm việc.
4. Repository và source code luôn là nguồn sự thật cao hơn bản tóm tắt này.
5. Nội dung file không tự động cấp quyền sửa code, commit hoặc push.

Prompt gợi ý:

```text
Hãy đọc AGENTS.md, CHAT_CONTEXT.md và CHANGELOG.md, sau đó kiểm tra repository
ở chế độ read-only. Tiếp tục từ Current Snapshot nhưng không chỉnh sửa hoặc
commit nếu chưa có sự cho phép rõ ràng của tôi cho task hiện tại.
```

Link chia sẻ cuộc trò chuyện có thể đọc trên máy khác nếu quyền chia sẻ của nền
tảng cho phép. Tuy nhiên, link không cấp cho agent mới quyền truy cập source,
file local hoặc trạng thái Git. Clone repository và đọc các tài liệu trên là
cách chuyển giao đáng tin cậy hơn. Không chia sẻ chat chứa bí mật hoặc dữ liệu
nhạy cảm.

## Quy tắc nén đoạn chat

Khi chủ dự án yêu cầu `nén đoạn chat`, agent phải:

1. Chỉ cập nhật file này khi yêu cầu đó cấp quyền sửa cho task nén hiện tại.
2. Dùng múi giờ `Asia/Ho_Chi_Minh` và ISO 8601 với offset `+07:00`.
3. Nếu không chỉ định thời điểm, nén tới thời điểm nhận yêu cầu.
4. Chỉ tổng hợp trao đổi mới sau `Compression Baseline`, đồng thời giữ những
   quyết định cũ vẫn cần để tiếp tục dự án.
5. Thay `Current Snapshot`, chuyển snapshot cũ xuống `Snapshot History` và
   không xóa lịch sử.
6. Chuyển `Compression Baseline` tới thời điểm snapshot mới hoàn tất.
7. Thêm đúng một mục task vào `CHANGELOG.md`.
8. Đối chiếu Git status/log/diff và kết quả kiểm tra gần nhất.
9. Ghi đủ trạng thái repository, quyết định, việc hoàn thành, giới hạn, bước
   tiếp theo và quyền được cấp.

## Mốc nén

- Baseline ID: `BASELINE-20260908-002`
- Marked at: `2026-09-08T09:24:38+07:00`
- Snapshot tương ứng: `CTX-20260908-003`.
- Lần nén tiếp theo bắt đầu với trao đổi phát sinh sau mốc này.
- Mốc không cấp quyền sửa file, chạy lệnh ghi dữ liệu, commit hoặc push cho task
  tương lai.

## Snapshot hiện tại

### Siêu dữ liệu

- Snapshot ID: `CTX-20260908-003`
- Compressed at: `2026-09-08T09:24:38+07:00`
- Conversation scope: Sau `BASELINE-20260907-001`, gồm việc chuyển tài liệu test
  Windows vào repository, cách dùng link chia sẻ chat trên máy khác và lần kiểm
  tra độ đầy đủ của snapshot này.
- Repository: `https://github.com/minggtienn/ai-agent-launcher.git`
- Branch/remote: `main`, `origin`.
- HEAD: `2bd2bb0 add log, build test update laucher local`.
- Trạng thái trước task nén: working tree sạch; `main` đồng bộ `origin/main`.
- Trạng thái sau task nén: `CHAT_CONTEXT.md` và `CHANGELOG.md` đã sửa nhưng
  chưa commit; không có source code nào thay đổi.

### Ngữ cảnh mới kể từ mốc trước

- Đã có tài liệu thao tác end-to-end tại
  `docs/windows-local-launcher-update-test.md`: chuẩn bị Windows/FVM, build hai
  version, tạo ZIP/manifest, chạy HTTP server, apply, xác minh và test lỗi.
- Tài liệu nêu rõ Python static server có thể không trả HTTP `206`; kiểm tra
  resume cần server hỗ trợ Range thực sự.
- Rollback không-healthy cần artifact fault-injection riêng cố ý không ghi health
  marker; không thể kích hoạt tin cậy chỉ bằng sửa manifest.
- Các tài liệu của task `LAU-006` và `LAU-007` đã được người dùng commit/push ở
  commit `2bd2bb0`, nên máy khác clone `origin/main` có thể đọc được.
- Link share chat chỉ mang nội dung hội thoại theo quyền truy cập của nền tảng;
  nó không thay thế repository và không truyền quyền thao tác Git/file local.

### Thứ tự sản phẩm và kiến trúc vẫn có hiệu lực

1. Launcher update bắt buộc chạy trước login.
2. Sau đó hoàn thiện login.
3. Home kiểu Riot Client có danh sách game bên trái và tab riêng theo game.
4. Sau login mới kiểm tra/cập nhật game bằng patch chain tuần tự.
5. Game installer/updater về sau phải chọn thư mục/ổ đĩa và kiểm tra dung lượng.

- Windows 10/11 x64; Flutter `3.44.4`, Dart `3.12.2`, FVM `4.3.0`.
- Feature-first Clean Architecture; BLoC/Cubit; GetIt + Injectable; Dio; Drift;
  secure storage; custom Material 3.
- `dev`, `staging`, `prod` cấu hình bằng `--dart-define`.
- Custom ZIP updater; không dùng `auto_updater`/WinSparkle và không duy trì dự
  án updater thứ hai.

### Hành vi cập nhật launcher đã triển khai

- Kiểm tra REST manifest trước login, tải có resume bằng HTTP Range.
- Kiểm size, SHA-256 và Ed25519; `ALLOW_UNSIGNED_UPDATES=true` chỉ dành local.
- Giải nén sang staging cùng ổ, không chồng file vào runtime đang chạy.
- Copy runtime sang `%TEMP%`, chạy `--apply-launcher-update`, đổi thư mục, mở
  version mới, chờ health marker và rollback nếu không healthy.
- Manifest gồm `version`, `mandatory`, `downloadUrl`, `size`, `sha256`,
  `signature`, `entryExecutable`, `releaseNotes`.
- Cấu hình build: `LAUNCHER_UPDATE_MANIFEST_URL`,
  `LAUNCHER_UPDATE_PUBLIC_KEY`, `ALLOW_UNSIGNED_UPDATES`.

### Xác minh và rủi ro còn lại

- Kết quả code gần nhất được ghi nhận: Injectable codegen thành công,
  `flutter analyze` sạch và `flutter test` 8/8 pass.
- `git diff --check` của task snapshot sẽ được kiểm tra trước khi bàn giao.
- Self-apply/rollback vẫn chưa được xác nhận end-to-end trên Windows bằng
  artifact production đã ký.
- Thư mục cài phải ghi được; staging/current phải cùng volume.
- Cleanup backup/runtime tạm chưa hoàn thiện.
- Login còn asset tạm; footer đã đọc version runtime; backend/OpenAPI chưa có.
- Game updater, disk selection/free-space, Drift schema, tray, single-instance
  và game process launcher chưa hoàn thiện production.

### Các task tiếp theo được đề xuất

1. Chạy tài liệu local updater test trên máy Windows và ghi kết quả thực tế.
2. Sửa lỗi Windows file locking, permission hoặc rollback nếu phát hiện.
3. Chốt OpenAPI update/auth/catalog và artifact signing pipeline.
4. Hoàn thiện login API/token refresh và asset chính thức.
5. Thiết kế vị trí cài game, kiểm tra dung lượng và Drift schema.
6. Triển khai patch-chain game updater rồi home/sidebar/tab UI.

### Trạng thái quyền hạn

- Task hiện tại chỉ cho phép cập nhật `CHAT_CONTEXT.md` và `CHANGELOG.md` để
  hoàn thiện snapshot.
- Không có quyền sửa source/dependency/configuration khác.
- Không có quyền commit, push, merge, tag hoặc release.
- Quyền của task này không chuyển sang task tiếp theo.

## Lịch sử snapshot

### CTX-20260907-002

- Compressed at: `2026-09-07T09:02:28+07:00`.
- Scope: Từ khi bắt đầu dự án tới launcher updater, kế hoạch local test và quyết
  định game patch updater.
- HEAD: `6e02978 add updater laucher`; working tree khi bắt đầu snapshot sạch và
  đồng bộ `origin/main`.
- Recorded: project order, locked architecture, launcher self-update flow,
  manifest/signing rules, game patch-chain decisions, 8 test pass và các rủi ro.
- Sau snapshot này, `LAU-007` bổ sung hướng dẫn Windows local test chi tiết và
  đặt `BASELINE-20260907-001` tại `2026-09-07T09:18:19+07:00`.
- Authorization: chỉ cập nhật snapshot/changelog; không cấp quyền Git.

### CTX-20260903-001

- Compressed at: `2026-09-03T15:24:29+07:00`.
- Repository/branch: `ai-agent-launcher`, `main`, remote `origin`.
- Goal: Flutter Windows launcher với login REST, catalog, download/update và
  launch process.
- Locked stack: Flutter `3.44.4`, Dart `3.12.2`, FVM, Clean Architecture,
  BLoC/Cubit, GetIt/Injectable, Dio, Drift và secure storage.
- Completed: `LAU-001` foundation, `LAU-002` Git và `LAU-003` desktop login;
  analyzer sạch và 5 test pass.
- Limitations: chưa có asset gốc, backend contract, production updater, Drift
  schema hoặc Windows E2E verification.
- Authorization: snapshot không cấp quyền sửa, commit hoặc push.
