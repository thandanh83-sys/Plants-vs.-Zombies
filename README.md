# Vạn Giới Linh Viên

Một game tower-defense bằng Godot 4, lấy cảm hứng từ Plants vs. Zombies và văn hóa Việt Nam.

## Mở và chạy

1. Cài Godot 4.2 trở lên.
2. Clone repo, mở `project.godot` bằng Godot Editor.
3. Chạy scene `res://scenes/Main.tscn` bằng F6 hoặc **Run Project**.

## Chuẩn bị 3 ảnh UI đã tải lên

Ba ảnh gốc đang ở thư mục gốc repo. Để đưa chúng vào đường dẫn mà Godot sử dụng, chạy tại thư mục repo:

```bash
python tools/rename_assets.py
```

Script chuyển:

- `Biểu tượng hoa sen mực thủy mặc.png` → `assets/ui/logo.png`
- `Bùa Tre Trúc Ngọc Bích.png` → `assets/ui/seed-packet.png`
- `Quả cầu ngọc linh sen vàng.png` → `assets/ui/linh-khi.png`

Nếu đích đã tồn tại, script giữ nguyên cả ảnh nguồn và ảnh đích để tránh ghi đè. Sau khi chạy, commit các file trong `assets/ui/` nếu bạn muốn chúng được lưu trên GitHub.

## Cấu trúc nội dung

- `core/` — DataLoader, GameManager, CardManager, AudioManager, SaveSystem và các manager.
- `behaviors/` — hành vi cây, zombie, đạn.
- `scenes/` — scene và script giao diện game.
- `data/plants/*.json`, `data/zombies/*.json`, `data/levels/*.json` — nội dung game theo dữ liệu.
- `data/config/game-settings.json` — cài đặt dùng chung.
- `assets/ui/`, `assets/plants/`, `assets/zombies/`, `assets/backgrounds/` — ảnh game.

`DataLoader` tự quét JSON cho cây, zombie, màn và đọc cấu hình. Tiến trình mở màn được lưu ở `user://savegame.json` qua `SaveSystem`.
