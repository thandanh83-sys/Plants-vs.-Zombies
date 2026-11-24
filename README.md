# Vạn Giới Linh Viên

Game tower-defense viết bằng GDScript cho Godot 4.2+, lấy cảm hứng từ Plants vs. Zombies và văn hóa Việt Nam.

## Mở game

1. Cài Godot 4.2 trở lên.
2. Clone repository và mở thư mục chứa `project.godot` trong Godot Editor.
3. Nhấn F5 hoặc nút Run để chạy game.

## Nội dung hiện có

- `core/DataLoader.gd` nạp JSON từ `data/plants/`, `data/zombies/`, `data/levels/` và cấu hình chung.
- `core/GridManager.gd` tạo lưới 5 × 9, `core/EntityFactory.gd` tạo thực thể.
- `core/WaveManager.gd` phát sóng; các script trong `behaviors/` xử lý cây, zombie, đạn và hiệu ứng.
- `core/SaveSystem.gd` lưu tiến trình vào `user://savegame.json`.
- Scene chính nằm trong `scenes/Main.tscn`.

## Thêm nội dung

- Cây: `data/plants/<id>.json`
- Zombie: `data/zombies/<id>.json`
- Màn chơi: `data/levels/<id>.json`

Sprite tùy chọn:

- Cây: `assets/plants/<id>.png`
- Zombie: `assets/zombies/<id>.png`

Khi thiếu sprite, game tự dùng hình khối dự phòng.

## Tài nguyên hình ảnh UI

- `logo.png` → `assets/ui/logo.png`
- `seed-packet.png` → `assets/ui/seed-packet.png`
- `linh-khi.png` → `assets/ui/linh-khi.png`

Cấu hình đường dẫn nằm trong `data/config/ui-assets.json`.
