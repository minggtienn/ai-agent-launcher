# Kiến trúc

## Quy tắc phụ thuộc

```text
Presentation -> Domain
Data         -> Domain
Platform     -> Domain/Core contracts
Domain       -> Dart thuần
```

Mã nguồn được tổ chức theo tính năng. Mỗi tính năng sở hữu các lớp data,
domain và presentation của nó. Domain không được import Flutter, plugin, cơ sở
dữ liệu hoặc implementation HTTP. Interface repository thuộc domain;
implementation thuộc data. DTO không được đi qua ranh giới data.

## Quản lý trạng thái

- BLoC quản lý phiên đăng nhập, tải dữ liệu, khởi chạy và update launcher.
- Cubit quản lý bộ lọc catalog và thiết lập.
- BLoC chỉ gọi use case và chỉ công khai state bất biến.
- Exception kỹ thuật phải được chuyển thành `Failure` trước khi tới presentation.

## Môi trường

`main_dev.dart`, `main_staging.dart` và `main_prod.dart` chọn môi trường chạy.
Không biên dịch secret vào ứng dụng. Endpoint không bí mật và update channel
được truyền bằng `--dart-define`.

## Ranh giới Windows

Khởi chạy process, single-instance, system tray, đăng ký startup, deep link và
updater phải nằm sau các interface. Launcher chạy với quyền người dùng tiêu
chuẩn và chỉ yêu cầu elevation cho thao tác đã được phê duyệt rõ ràng.

Custom frame Windows dùng `bitsdojo_window`. `main.cpp` chỉ chứa cấu hình
bootstrap bắt buộc của package; kích thước, vị trí, kéo cửa sổ và nút điều khiển
được quản lý từ Dart. Không thêm workaround DWM/Win32 tùy biến khi chưa có thiết
kế và test riêng.

## Cập nhật launcher

Startup bị chặn bởi bước kiểm tra manifest update đã ký. Launcher tải ZIP có
khả năng tiếp tục, kiểm tra size, SHA-256 và chữ ký Ed25519 rồi giải nén vào thư
mục staging cùng cấp.

Để không duy trì project updater thứ hai, launcher sao chép runtime của chính
nó vào thư mục tạm và chạy executable đó ở chế độ apply. Helper tạm đổi nguyên
thư mục cài đặt, mở launcher mới, chờ health marker và rollback nếu startup
không healthy.

Updater thay nguyên thư mục, không trộn file. DLL đã bỏ ở version mới chỉ còn
trong backup của version cũ. Bản production, manifest và artifact update đều
phải được ký.

Update game được tách sang task khác. Phần đó có thể tái sử dụng khái niệm tải,
kiểm tra toàn vẹn và tiến trình nhưng không dùng chung logic apply launcher.
