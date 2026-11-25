# Vạn Giới Linh Viên

Game tower-defense 2D viết bằng GDScript cho **Godot 4.2+**. Dự án dùng JSON để khai báo cây, cương thi và màn chơi; sprite có thể bổ sung sau mà không cần thay đổi code nếu giữ đúng tên file.

## Chạy bằng Godot

1. Tải Godot 4.2.2 hoặc bản Godot 4 tương thích.
2. Import thư mục chứa `project.godot`.
3. Chờ Godot import tài nguyên, sau đó nhấn **F5**.
4. Chọn màn đã mở khóa ở góc trên bên phải và nhấn **Vào màn**.

## Điều khiển

- Chọn thẻ cây ở thanh phía trên, sau đó nhấp ô trống để trồng.
- Nhấp vào Linh Khí rơi để thu thập.
- Nhấn **Linh Đan**, sau đó nhấp vào cây để kích hoạt kỹ năng.
- Dùng thẻ chắn để giữ cương thi; cây bắn sẽ tự tấn công mục tiêu trong làn.

## Xuất bản Web (HTML5)

Repository đã có preset **Web** và HTML shell tại `web/custom_shell.html`.

### Xuất trên máy

1. Mở project bằng Godot 4.2+.
2. Cài **Export Templates** tương ứng trong Godot Editor.
3. Chạy lệnh:

```bash
godot --headless --editor --path . --quit
godot --headless --path . --export-release "Web" build/web/index.html
```

4. Mở game qua một web server tĩnh (không mở trực tiếp bằng `file://`). Thư mục `build/web/` là bản xuất; không cần đưa vào Git.

### Tải bản Web từ GitHub Actions

Workflow **Validate and export Web** tự kiểm tra JSON, import project và thử xuất HTML5 mỗi khi push lên `main`. Khi workflow thành công:

1. Mở tab **Actions** của repository.
2. Chọn lần chạy mới nhất.
3. Tải artifact `van-gioi-linh-vien-web`.
4. Giải nén và phục vụ thư mục đó bằng web server tĩnh.

Nếu bước export thất bại, xem log workflow để biết lỗi Godot cụ thể. Chưa có bản Web được xác nhận cho tới khi workflow chạy thành công.

## Bổ sung ảnh thủ công

Tên file mặc định:

- Cây: `assets/plants/<id-cây>.png`
- Cương thi: `assets/zombies/<id-cương-thi>.png`
- Nền màn: đường dẫn trong trường `background` của JSON màn, hiện ở `assets/backgrounds/`.

Ví dụ:
- `assets/plants/truc-tien.png`
- `assets/zombies/cuong-thi-thuong.png`
- `assets/backgrounds/thu-vien-co.png`

Giữ nguyên ID trong tên file JSON. Nếu ảnh chưa có, game dùng hình đa giác dự phòng; không cần tạo ảnh trước để kiểm tra logic.

## Cấu trúc chính

- `core/DataLoader.gd`: quét JSON, kiểm tra dữ liệu và tham chiếu.
- `core/EntityFactory.gd`: tạo cây/cương thi theo dữ liệu.
- `core/GridManager.gd`: lưới và trạng thái ô.
- `core/CardManager.gd`: thẻ cây và kiểm tra chi phí.
- `core/WaveManager.gd`: sinh cương thi theo wave.
- `behaviors/`: hành vi cây, cương thi, đạn và hiệu ứng.
- `data/`: dữ liệu cây, cương thi, màn và cấu hình.
- `tools/validate_project.py`: kiểm tra JSON và đường dẫn tham chiếu.
- `docs/reports/BASELINE_GODOT.md`: báo cáo baseline ban đầu.

## Kiểm thử

Chạy kiểm tra dữ liệu:

```bash
python3 tools/validate_project.py
```

Kiểm tra import/runtime bằng Godot:

```bash
godot --headless --editor --path . --quit
godot --headless --path . --quit
```

Kiểm tra runtime thực tế vẫn cần mở game và thử thao tác trong Godot hoặc chạy bản Web đã export. Các trường JSON mô tả cơ chế chưa được hỗ trợ sẽ không tự hoạt động chỉ vì được khai báo.
