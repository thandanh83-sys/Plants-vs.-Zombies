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
- Dùng cây chắn để giữ cương thi; cây bắn sẽ tự tìm mục tiêu trong tầm và cùng làn (một số cây có thể bắn làn kề).

## Cơ chế hiện có

- Cây sản xuất Linh Khí; Nguyệt Quang Nấm tăng sản lượng theo các mốc trưởng thành trong JSON.
- Cây bắn hỗ trợ nhiều đạn, xuyên mục tiêu, làm chậm, đóng băng và đẩy lùi.
- Trúc Tiễn có kiểu đạn mực riêng.
- Cây nổ, cây nuốt mục tiêu, cây chắn, Linh Đan và bệ Liên Diệp.
- Cương thi có giáp, nhảy qua cây, bay, gọi viện binh, dẫn đầu đợt và tăng tốc khi lớp báo bị phá.
- Màn hồ sen có ô nước và yêu cầu bệ Liên Diệp; màn đêm không có Linh Khí rơi từ trời; màn sương che tầm nhìn ở ba cột phải.
- Màn mái nhà hiện có bộ ô mái ngói riêng về mặt hình ảnh; chưa có cơ chế chậu trồng/độ dốc riêng.

## Âm thanh

`AudioManager` ưu tiên file OGG trong `assets/audio/`. Nếu chưa có file, game tự tạo âm thanh ngắn bằng sóng tổng hợp cho các sự kiện trồng cây, thu thập Linh Khí, nổ, thắng và thua. Vì vậy, thư mục âm thanh trống không làm mất hoàn toàn phản hồi âm thanh.

Để thay âm thanh tổng hợp bằng âm thanh riêng, thêm các file:
- `assets/audio/plant.ogg`
- `assets/audio/collect.ogg`
- `assets/audio/explosion.ogg`
- `assets/audio/win.ogg`
- `assets/audio/lose.ogg`

## Xuất bản Web (HTML5)

Repository có preset **Web** và HTML shell tại `web/custom_shell.html`.

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

Workflow **Validate and export Web** tự kiểm tra JSON, import project, chạy thử khởi động headless và xuất HTML5 mỗi khi push lên `main`. Khi workflow thành công:

1. Mở tab **Actions** của repository.
2. Chọn lần chạy mới nhất.
3. Tải artifact `van-gioi-linh-vien-web`.
4. Giải nén và phục vụ thư mục đó bằng web server tĩnh.

Artifact có thời hạn lưu theo cấu hình workflow. Chưa có bản Web được xác nhận cho tới khi workflow chạy thành công.

## Bổ sung ảnh thủ công

Tên file mặc định:

- Cây: `assets/plants/<id-cây>.png`
- Cương thi: `assets/zombies/<id-cương-thi>.png`
- Nền màn: đường dẫn trong trường `background` của JSON màn, hiện ở `assets/backgrounds/`.

Ví dụ:
- `assets/plants/truc-tien.png`
- `assets/zombies/cuong-thi-thuong.png`
- `assets/backgrounds/thu-vien-co.png`

Giữ nguyên ID trong tên file JSON. Nếu ảnh chưa có, game dùng hình đa giác dự phòng; không cần tạo ảnh trước để kiểm tra logic. Danh sách ảnh cần tạo nằm trong `docs/ART_ASSET_CHECKLIST.md`.

## Cấu trúc chính

- `core/DataLoader.gd`: quét JSON, kiểm tra dữ liệu và tham chiếu.
- `core/EntityFactory.gd`: tạo cây/cương thi theo dữ liệu.
- `core/GridManager.gd`: lưới, địa hình nước, bia mộ và vùng sương mù.
- `core/CardManager.gd`: thẻ cây và kiểm tra chi phí.
- `core/WaveManager.gd`: sinh cương thi theo wave.
- `core/AudioManager.gd`: phát OGG hoặc âm thanh tổng hợp.
- `behaviors/`: hành vi cây, cương thi và đạn.
- `data/`: dữ liệu cây, cương thi, màn và cấu hình.
- `tools/validate_project.py`: kiểm tra JSON, schema và tham chiếu.
- `docs/reports/CURRENT_STATUS.md`: trạng thái và giới hạn đã rà soát.

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

Kiểm thử gameplay trực tiếp vẫn cần mở game và thử thao tác. CI chỉ xác nhận import, khởi động headless, kiểm tra dữ liệu và xuất Web; không thay thế kiểm thử cân bằng/gameplay bằng người chơi.
