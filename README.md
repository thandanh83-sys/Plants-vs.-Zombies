# Vạn Giới Linh Viên

Một game tower-defense theo phong cách Plants vs. Zombies, lấy cảm hứng văn hóa Việt Nam và kiến trúc dữ liệu mở rộng.

## Trạng thái hiện tại

Đã có bản nguyên mẫu chạy được trong Godot 4:

- Tải tự động cây, zombie và màn chơi từ thư mục `data/`
- Lưới 5×9 bằng `GridManager.gd`
- Thẻ Linh Phù bằng `CardManager.gd`
- Sinh cây/zombie bằng `EntityFactory.gd`
- Cây bắn, zombie di chuyển và tấn công, Linh Khí tăng/tiêu
- Sinh sóng zombie theo JSON
- Thắng/thua cơ bản

## Chạy dự án

1. Cài Godot 4.2 trở lên.
2. Mở thư mục repo bằng Godot Editor.
3. Nhấn **F6** hoặc **Run Project**.

Scene khởi động là `res://scenes/Main.tscn`.

## Thêm nội dung

- Thêm `data/plants/<id>.json` để đăng ký cây mới.
- Thêm `data/zombies/<id>.json` để đăng ký zombie mới.
- Thêm `data/levels/<id>.json` để đăng ký màn mới.
- Đặt sprite tại `assets/plants/<id>.png` hoặc `assets/zombies/<id>.png`.

Core đọc dữ liệu tự động qua `DataLoader`; không cần hard-code thêm tên entity.
