# Quy tắc dành cho agent

Các quy tắc này áp dụng cho mọi agent tự động làm việc trong repository.

1. Mặc định chỉ kiểm tra read-only và lập kế hoạch.
2. Không tạo, sửa, di chuyển hoặc xóa file nếu chưa có sự cho phép rõ ràng của
   chủ dự án cho task hiện tại.
3. Trước khi sửa, phải nêu phạm vi và danh sách file dự kiến. Nếu phát sinh phạm
   vi ngoài dự kiến, phải dừng và xin phép lại.
4. Mỗi task được phép thay đổi repository phải thêm đúng một entry vào
   `CHANGELOG.md`.
5. Quyền sửa file không bao gồm quyền Git commit. Phải trình bày diff và kết quả
   xác minh, sau đó chờ quyền commit riêng.
6. Không amend, rebase, merge, push, tag, release, stash, loại bỏ hoặc ghi đè
   thay đổi của người dùng nếu chưa có quyền rõ ràng cho chính xác thao tác đó.
7. Không lưu mật khẩu, access token, refresh token, signing key hoặc secret khác
   trong repository hay log.
