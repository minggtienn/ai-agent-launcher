# Quản trị dự án

## Quyền của chủ dự án

Mặc định chỉ được kiểm tra và lập kế hoạch ở chế độ read-only. Việc tạo, sửa,
di chuyển hoặc xóa file cần chủ dự án cho phép rõ ràng trong task hiện tại.
Quyền không tự chuyển sang task khác. Nếu phát sinh phạm vi ngoài dự kiến, phải
dừng và xin phép trước khi tiếp tục.

Quyền sửa file tách biệt với quyền commit. Không được commit, amend, rebase,
merge, push, tag, release, stash hoặc loại bỏ thay đổi nếu chưa có đúng quyền
cho thao tác đó.

## Quy trình thay đổi

1. Kiểm tra repository mà không thay đổi file tracked.
2. Trình bày mục tiêu, cách làm, danh sách file và lệnh có khả năng ghi dữ liệu.
3. Nhận sự cho phép của chủ dự án cho task hiện tại.
4. Chỉ sửa phạm vi đã được duyệt và thêm đúng một entry vào `CHANGELOG.md`.
5. Chạy kiểm tra, trình bày diff và kết quả xác minh.
6. Xin quyền riêng trước khi tạo commit.

## Quyền sở hữu và yêu cầu review

| Khu vực | Chủ sở hữu | Review bắt buộc |
| --- | --- | --- |
| Presentation/UI | Nhóm Flutter/UI | Chủ tính năng |
| Domain | Chủ tính năng | Trưởng nhóm code |
| Data/API/cơ sở dữ liệu | Developer/Senior | Chủ tính năng |
| Xác thực/bảo mật | Chủ bảo mật | Bảo mật và trưởng nhóm code |
| Tải dữ liệu/updater | Chủ Windows/Release | Hai người phê duyệt |
| Windows/installer | Windows/DevOps | Trưởng nhóm code và release |
| Dependency/FVM/lint | Trưởng nhóm code | Trưởng nhóm code |
| CI/CD/ký artifact | DevOps | Release và bảo mật |
| `CHANGELOG.md` | Người được giao | Trưởng nhóm code |

Quyền sở hữu khu vực không thay thế yêu cầu xin phép chủ dự án.
