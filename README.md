# Vạn Giới Linh Viên — Godot 4.2+

Dự án tower-defense 2D viết bằng GDScript. Thiết kế hướng dữ liệu: thêm cây, zombie hoặc màn thường chỉ cần thêm JSON mới vào thư mục dữ liệu tương ứng, không sửa danh sách hard-code trong manager.

## Chạy

1. Mở `project.godot` bằng Godot 4.2 trở lên.
2. Nhấn F6/F5 để chạy scene/project.
3. Nếu có lỗi, xem tab **Debugger → Errors** và **Output**. Repo chưa kèm kết quả chạy headless nên cần xác nhận bằng Godot Editor.

## Thêm plant

Tạo `data/plants/<id>.json`. Ví dụ:

```json
{
  "name": "Trúc Tiễn",
  "type": "shooter",
  "cost": 100,
  "hp": 300,
  "damage": 20,
  "fire_rate": 1.5,
  "range": 9,
  "sprite": "res://assets/plants/truc-tien.png",
  "abilities": {"projectiles_per_attack": 1}
}
```

Để màn dùng cây mới, thêm ID vào `available_plants` của level tương ứng. Sprite là tùy chọn; nếu bỏ qua, dùng hình dự phòng. Script hành vi tùy chỉnh có thể khai báo `behavior_script` trong JSON, kế thừa hành vi setup tương thích.

## Thêm zombie

Tạo `data/zombies/<id>.json` với `name`, `type`, `hp`, `speed`, `damage`, `attack_rate`. Thêm ID vào danh sách `zombies` trong wave của màn. Sprite tùy chọn đặt ở `assets/zombies/<id>.png`. Có thể chỉ định `behavior_script` để dùng script riêng.

## Thêm màn

Tạo `data/levels/<id>.json` gồm `name`, `environment`, `available_plants`, `waves`; mỗi wave có `zombies`, `count`, `interval`. DataLoader kiểm tra tham chiếu ID cây/quái và báo lỗi nếu sai.

## Cấu trúc

- `data/plants`, `data/zombies`, `data/levels`: dữ liệu nội dung.
- `core/DataLoader.gd`: tự quét JSON, nạp và kiểm tra tham chiếu.
- `core/EntityFactory.gd`: tạo entity từ dữ liệu; script có thể override bằng JSON.
- `core/WaveManager.gd`: phát wave từ JSON.
- `behaviors/`: hành vi entity mặc định.
- `assets/`: hình, âm thanh và UI.

## Hạn chế hiện tại

Cấu trúc JSON mới làm giảm việc sửa code khi thêm nội dung cùng loại. Các tính năng có hành vi hoàn toàn mới vẫn cần script hoặc capability tương ứng; khai báo một trường JSON tự nó không tự tạo ra cơ chế. Hình ảnh, âm thanh và hiệu ứng cần được cung cấp riêng. Kiểm tra cú pháp/runtime cuối cùng phải thực hiện trong Godot 4.2+.
