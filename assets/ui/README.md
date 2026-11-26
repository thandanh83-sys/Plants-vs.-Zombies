# Tài nguyên giao diện

Các tài nguyên UI đã được đưa trực tiếp vào repository:

- `logo.png` — logo tại `assets/ui/logo.png`.
- `linh-khi.png` — biểu tượng Linh Khí tại `assets/ui/linh-khi.png`.
- Ảnh mặt trước thẻ Plant đặt tại `assets/ui/seed-packet/<plant-id>.png`.

## Quy tắc chọn ảnh thẻ

`CardManager.gd` chọn ảnh theo thứ tự:

1. Trường `card_sprite` trong JSON của Plant (nếu được khai báo).
2. Đường dẫn mặc định `res://assets/ui/seed-packet/<plant-id>.png`.
3. Sprite nhân vật tại `res://assets/plants/<plant-id>.png`.
4. Ảnh gói thẻ dùng chung, nếu được khai báo hợp lệ trong `data/config/ui-assets.json`.

Không cần chạy script đổi tên asset để khởi động game. Khi thêm ảnh, cập nhật đường dẫn JSON nếu dùng tên/vị trí khác; validator sẽ kiểm tra các đường dẫn đã khai báo.
