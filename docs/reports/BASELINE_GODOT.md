# NHIỆM VỤ 02 — Baseline Godot

Chưa thể chạy Godot trực tiếp trong môi trường hiện có. Vì vậy, kết luận dưới đây dựa trên kiểm tra tĩnh `project.godot` và source; chưa xác nhận lỗi runtime cụ thể.

## 1. Phiên bản Godot cần dùng

Project yêu cầu:

- **Godot 4.2 trở lên**
- Dòng cấu hình: `config/features=PackedStringArray("4.2", "GL Compatibility")`
- Renderer: `gl_compatibility`

Khuyến nghị dùng **Godot 4.2.x ổn định đầu tiên** hoặc bản tương thích Godot 4 mới nhất. Không dùng Godot 3.x.

Nguồn: [`project.godot`, dòng 1–28](https://github.com/thandanh83-sys/Plants-vs.-Zombies/blob/a41ab635e6213a7182cf2991b4ed225e63b30f6d/project.godot#L1-L28)

## 2. Cách mở và import project

1. Tải Godot Engine tương thích 4.2+.
2. Không chạy file riêng lẻ.
3. Chọn **Import** trong Project Manager.
4. Trỏ tới thư mục chứa [`project.godot`](https://github.com/thandanh83-sys/Plants-vs.-Zombies/blob/a41ab635e6213a7182cf2991b4ed225e63b30f6d/project.godot).
5. Chọn **Import & Edit**.
6. Chờ Godot quét và import tài nguyên.
7. Mở các panel:
   - **Output**
   - **Debugger → Errors**
   - **Debugger → Stack Trace**

Scene khởi chạy là [`scenes/Main.tscn`](https://github.com/thandanh83-sys/Plants-vs.-Zombies/blob/a41ab635e6213a7182cf2991b4ed225e63b30f6d/scenes/Main.tscn#L1-L10).

## 3. Autoload cần khởi tạo

Đúng thứ tự khai báo trong project:

| Tên | Script |
|---|---|
| `DataLoader` | `res://core/DataLoader.gd` |
| `GameManager` | `res://core/GameManager.gd` |
| `AudioManager` | `res://core/AudioManager.gd` |
| `CardManager` | `res://core/CardManager.gd` |
| `SaveSystem` | `res://core/SaveSystem.gd` |
| `SunManager` | `res://core/SunManager.gd` |

Nguồn: [`project.godot`, dòng 10–16](https://github.com/thandanh83-sys/Plants-vs.-Zombies/blob/a41ab635e6213a7182cf2991b4ed225e63b30f6d/project.godot#L10-L16)

## 4. Chạy và thu thập log

### Trong Editor

1. Nhấn **F6** để chạy scene hiện tại; `Main.tscn` là scene khởi chạy.
2. Hoặc nhấn **F5** để chạy toàn project.
3. Quan sát cửa sổ game 1280×720.
4. Nếu có lỗi, dừng game bằng nút Stop.
5. Trong **Output**, copy toàn bộ đoạn output có `[DataLoader]`, `ERROR`, `WARNING`, đường dẫn `res://` và số dòng.
6. Trong **Debugger → Errors**, copy tên lỗi, file và dòng.
7. Trong **Debugger → Stack Trace**, copy call stack.

### Chạy bằng command line

```bash
godot --path /đường-dẫn/Plants-vs.-Zombies
```

Godot 4 có thể yêu cầu tên executable khác:

```bash
Godot_v4.2.x --path /đường-dẫn/Plants-vs.-Zombies
```

Giữ cửa sổ terminal mở và gửi toàn bộ output.

### Mẫu thông báo cần gửi

```text
Phiên bản Godot:
OS:
Lệnh chạy:
Bước tái hiện:
1. ...
Kết quả mong đợi:
Kết quả thực tế:
[Output]
...
[Debugger Stack Trace]
...
```

## 5. Lỗi import/parser

Không có lỗi import/parser đã xác nhận.

Một số cảnh báo/nguy cơ từ kiểm tra tĩnh:

- Repository không có file âm thanh `.ogg`.
- Không có sprite PNG trong `assets/plants/` và `assets/zombies/`.
- Các level JSON trỏ tới file nền PNG chưa xuất hiện trong repository.
- Code không nạp hoặc cảnh báo background; kiểm tra `Main.gd` chỉ tạo `ColorRect`.
- `project.autoload.tmp` không phải cấu hình Godot; project thực tế chỉ dùng `project.godot`.

Chưa xác nhận parser có đọc lỗi hay không.

## 6. Lỗi runtime có thể tái hiện

Chưa có thông báo runtime cụ thể nên chưa có lỗi đã xác nhận. Tình huống nên kiểm thử:

1. Khởi chạy project.
2. Chọn và đặt một số cây.
3. Chờ wave zombie xuất hiện.
4. Để zombie tiếp cận cây.
5. Cho zombie tới ô ngưỡng bên trái.
6. Để tất cả wave kết thúc.
7. Nhặt Linh Khí rơi.
8. Nhấn Linh Đan sẵn sàng rồi chọn cây.
9. Chạy lại scene sau khi thắng/thua.
10. Kiểm tra file save trong `user://savegame.json`.

## 7. Phân loại kết quả mong đợi

| Loại | Trạng thái |
|---|---|
| Import/parser | Chưa xác minh |
| Cú pháp hoặc kiểu GDScript | Chưa xác minh |
| Đường dẫn tài nguyên | Có nguy cơ: sprite, background và audio thiếu; chưa có log xác nhận |
| Autoload/signal | Có nguy cơ: cần kiểm tra khi scene khởi chạy; chưa có lỗi xác nhận |
| Runtime | Chưa xác minh |
| Cảnh báo không dừng game | Dự kiến do thiếu sprite/audio và fallback; chưa xác nhận |

## 8. Những phần đã chạy được

Không thể xác nhận phần nào đã chạy được trong Godot.

Từ kiểm tra source tĩnh:

- Scene entry được khai báo.
- Dữ liệu được quét trong `_ready()` của `DataLoader`.
- Các Autoload được khai báo trong project.
- Luồng game cơ bản được mô tả từ `Main.gd`, `CardManager`, `GridManager`, `EntityFactory`, `WaveManager`, `PlantBehavior` và `ZombieBehavior`.

Các phần này không được coi là đã chạy được cho tới khi Godot trả lại bằng chứng thực tế.

## 9. Những phần chưa thể xác minh

- Project có import thành công hay không.
- Các script có parser hoặc lỗi type-check hay không.
- `DataLoader` có tải đủ JSON hay không.
- `DataLoader.data_loaded` có phát/signal có kết nối đúng hay không.
- `Main.gd._ready()` có khởi tạo toàn bộ hệ thống hay không.
- Grid, thẻ cây, trồng cây, đạn, zombie và sóng có hoạt động hay không.
- Plant Food có hoạt động đúng hay không.
- Save system có ghi/mở lưu đúng hay không.
- Victory/defeat có kích hoạt đúng hay không.
- Dữ liệu thiếu asset có làm project dừng hay chỉ fallback hay không.
- Không xác minh được bằng chứng editor/run trong môi trường hiện tại.
