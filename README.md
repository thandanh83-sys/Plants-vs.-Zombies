# Vạn Giới Linh Viên

Game tower-defense viết bằng GDScript cho Godot 4.2+, lấy cảm hứng từ Plants vs. Zombies và văn hóa Việt Nam.

## Mở game

1. Clone repository và cài Godot 4.2 trở lên.
2. Chạy `python tools/rename_assets.py` để chuyển ba ảnh thiết kế ở thư mục gốc vào `assets/ui/`.
3. Mở `project.godot` trong Godot Editor và chạy project.

## Nội dung hiện có

- `core/DataLoader.gd` nạp JSON từ `data/plants/`, `data/zombies/`, `data/levels/` và cấu hình chung.
- `core/GridManager.gd` tạo lưới, `core/EntityFactory.gd` tạo entity.
- `core/WaveManager.gd` phát sóng; các script `behaviors/` xử lý cây, zombie, đạn và hiệu ứng.
- `core/SaveSystem.gd` lưu tiến trình vào `user://savegame.json`.
- Main scene: `scenes/Main.tscn`.

## Thêm nội dung

Thêm JSON mới với ID riêng vào thư mục phù hợp. Sprite tùy chọn đặt theo ID trong `assets/plants/<id>.png` hoặc `assets/zombies/<id>.png`. Level khai báo ID trong `available_plants` và `waves`. Mỗi file JSON phải là một object JSON hợp lệ.

## Tài nguyên hình ảnh

Ảnh nguồn UI được chuyển theo quy tắc:

- `Biểu tượng hoa sen mực thủy mặc.png` → `assets/ui/logo.png`
- `Bùa Tre Trúc Ngọc Bích.png` → `assets/ui/seed-packet.png`
- `Quả cầu ngọc linh sen vàng.png` → `assets/ui/linh-khi.png`

Ảnh cây, zombie, nền và âm thanh là tài nguyên bổ sung; game dùng hình khối dự phòng khi thiếu sprite nhân vật.
