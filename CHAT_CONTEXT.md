# Portable Chat Context

File này là bản nén ngữ cảnh để tiếp tục dự án trên máy hoặc nền tảng khác.
Đây không phải lịch sử chat nguyên văn và không được chứa mật khẩu, token, khóa
ký hoặc dữ liệu nhạy cảm.

## Cách sử dụng trên máy khác

1. Clone repository và checkout đúng branch.
2. Gửi toàn bộ file này cho trợ lý/agent mới.
3. Yêu cầu agent đọc thêm `AGENTS.md`, `CHANGELOG.md` và kiểm tra trạng thái Git.
4. Repo và source code luôn là nguồn sự thật cao hơn bản tóm tắt này.
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
7. Ghi mục tương ứng vào `CHANGELOG.md` vì đây là thay đổi repository.
8. Trước khi kết thúc, đối chiếu bằng Git status/diff và các test gần nhất.

Mỗi snapshot phải ghi đủ:

- Thời điểm và phạm vi hội thoại được tổng hợp.
- Mục tiêu sản phẩm và quyết định kiến trúc đã khóa.
- Việc đã hoàn thành, file/module quan trọng và kết quả kiểm tra.
- Thay đổi chưa commit và trạng thái branch/remote.
- Việc đang làm, blocker, rủi ro và bước tiếp theo.
- Quyền đã được cấp trong task hiện tại; không chuyển quyền đó sang task mới.

## Current Snapshot

### Metadata

- Snapshot ID: `CTX-20260903-001`
- Compressed at: `2026-09-03T15:24:29+07:00`
- Conversation scope: Từ khi lập kế hoạch dự án đến thời điểm snapshot.
- Repository: `https://github.com/minggtienn/ai-agent-launcher.git`
- Branch: `main`
- Remote: `origin`

### Product goal

Xây dựng launcher desktop Windows 10/11 x64 bằng Flutter. V1 đăng nhập bằng tài
khoản/mật khẩu qua REST API, hiển thị catalog, tải/cập nhật ứng dụng, khởi chạy
process và tự cập nhật launcher.

### Locked technical decisions

- Flutter `3.44.4`, Dart `3.12.2`, FVM `3.1.3`.
- Feature-first Clean Architecture.
- BLoC cho session/download/launch/update; Cubit cho catalog/settings.
- GetIt + Injectable, Dio, Drift, secure storage và custom Material 3.
- Ba môi trường `dev`, `staging`, `prod` qua `--dart-define`.
- Update ứng dụng bằng signed manifest, full-file resumable download, SHA-256,
  staging install và rollback một phiên bản.
- `app_links` thay cho `protocol_handler` do xung đột `win32_registry` với
  `launch_at_startup`.

### Governance

- Mặc định chỉ được đọc và phân tích.
- Sửa file cần chủ dự án cho phép rõ ràng theo từng task.
- Phát sinh ngoài phạm vi phải dừng và xin phép lại.
- Mọi task thay đổi repository phải thêm một mục vào `CHANGELOG.md`.
- Quyền commit tách biệt với quyền sửa; push, merge, tag và release cần quyền
  riêng cho từng thao tác.
- Không ghi đè, stash hoặc loại bỏ thay đổi của người dùng.

### Completed work

- `LAU-001`: Khởi tạo Flutter Windows project, Clean Architecture, dependency,
  environment entrypoint, DI, authentication foundation, domain contracts,
  CI, test và tài liệu quản trị.
- `LAU-002`: Khởi tạo Git branch `main` và cấu hình remote `origin`.
- `LAU-003`: Tạo màn hình đăng nhập desktop theo reference gồm campaign/news
  panel, form đăng nhập, custom title bar và responsive layout.
- Lần kiểm tra gần nhất: `fvm flutter analyze` không có lỗi; toàn bộ 5 test pass.

### Current limitations

- Banner, logo và news thumbnail hiện là widget/gradient thay thế; chưa có asset
  gốc từ chủ dự án.
- Backend contract và endpoint thật chưa được cung cấp.
- Download engine, Drift schema, tray, single-instance, process launcher và
  updater mới có package/domain boundary, chưa có production implementation.
- Windows release build chưa được kiểm tra vì môi trường triển khai ban đầu là
  macOS; cần Windows runner hoặc máy Windows có Visual Studio 2022 Desktop C++.

### Next recommended tasks

1. Nhận banner/logo/news assets và hoàn thiện visual fidelity của login screen.
2. Chốt OpenAPI authentication/catalog/manifest contract.
3. Triển khai token refresh interceptor và authentication integration test.
4. Thiết kế Drift schema cho catalog, settings, installations và download queue.
5. Triển khai Windows lifecycle và kiểm thử trên Windows.

### Authorization state

- Task tạo `CHAT_CONTEXT.md`: được chủ dự án yêu cầu.
- Không có quyền commit hoặc push từ yêu cầu này.
- Task tiếp theo phải xin hoặc nhận quyền sửa mới.

## Snapshot History

Chưa có snapshot cũ. Snapshot hiện tại sẽ được chuyển xuống đây ở lần nén tiếp
theo.
