# Vạn Giới Linh Viên

Game tower-defense 2D có runtime hiện tại chạy trên **Godot 4.2+ / GDScript**. Tuy nhiên, toàn bộ quy trình phát triển không bị giới hạn ở GDScript hay riêng Godot: dữ liệu, hình ảnh, âm thanh, công cụ tự động hóa, thiết kế nội dung và các pipeline bên ngoài có thể dùng nhiều định dạng/phần mềm khác nhau.

> **Phân biệt quan trọng:** Godot là engine đang chạy game trong repository này. Unity, Blender, Aseprite, Krita, công cụ AI và các phần mềm khác có thể tham gia quy trình tạo nội dung hoặc làm pipeline riêng; chúng không tự động trở thành runtime của project nếu chưa có project tích hợp và cấu hình build tương ứng.

## Công nghệ và công cụ

- **Runtime hiện tại:** Godot 4.2+, GDScript, scene/resource Godot.
- **Dữ liệu game:** JSON cho Plant, Zombie, level và cấu hình.
- **Tooling/QA:** Python 3 cho validator, AI Content Studio và unit tests.
- **Web:** HTML shell/CSS/JavaScript hỗ trợ giao diện xuất bản; Godot chịu trách nhiệm export game HTML5.
- **Art/audio:** PNG và OGG hiện được nạp trong game; file nguồn có thể được tạo/chỉnh sửa bằng công cụ đồ họa/âm thanh phù hợp.
- **Engine/phần mềm bên ngoài:** Unity, Blender, Aseprite, Krita, Photoshop, Audacity hoặc DAW có thể được dùng khi cần. Xem [Development Toolchain](docs/DEVELOPMENT_TOOLCHAIN.md) để biết ranh giới tích hợp và định dạng trao đổi.

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
- Dùng nút Tạm dừng và Tốc độ để tạm dừng hoặc chuyển giữa 1.0x, 1.5x và 2.0x.

## Giao diện tra cứu và bản đồ

- **Almanac** hiển thị danh sách Plant/Zombie, hình đã có và chỉ số/khả năng đọc trực tiếp từ JSON.
- **Bản đồ Vạn Giới** hiển thị các màn theo hàng ngang, trạng thái khóa, mở khóa và hoàn thành.
- Input đặt cây và dùng xẻng hỗ trợ cả click chuột và chạm màn hình.
- HUD được sắp xếp theo kích thước viewport; dự án sử dụng chế độ stretch `canvas_items` với aspect `expand`.

## Phạm vi bản demo hiện tại

Bản thử nghiệm đang tập trung vào **một màn duy nhất — Thư Viện Cổ** — với đúng hai Plant và hai Zombie:

| Vai trò | Nhân vật | Cơ chế chính |
|---|---|---|
| Plant tấn công | Trúc Tiễn | Bắn đạn mực theo làn; Linh Đan tạo loạt bắn nhanh |
| Plant nổ | Hồng Liên Nổ | Nổ diện rộng khi Cương Thi đến gần; Linh Đan gây đại bạo phá dọc một làn |
| Zombie cơ bản | Cương Thi Thường | Di chuyển và tấn công theo làn |
| Zombie có giáp | Cương Thi Đội Nón | Lớp giáp hấp thụ sát thương trước khi mất sinh lực |

- Màn có 3 đợt tấn công tăng dần áp lực; chỉ sử dụng hai loại Zombie trên.
- Thanh chọn có đúng 2 thẻ Plant; giới hạn này được cấu hình riêng trong JSON của màn, không làm thay đổi số thẻ của các màn khác.
- Màn khởi đầu với 250 Linh Khí và 1 lượt Linh Đan. Linh Khí tiếp tục rơi theo chu kỳ để người chơi xây dựng đội hình trên sân.
- Hai Plant và hai Zombie đều có đường dẫn sprite trong repository. Nền màn chưa có tranh riêng, nên bản demo dùng nền màu dự phòng và lưới chiến đấu của Godot.
- Bốn màn còn lại được giữ nguyên dữ liệu hiện có; chưa phải trọng tâm kiểm thử của bản demo này.

Sau khi vòng chơi của màn mẫu ổn định, mới mở rộng thêm Plant, Zombie, màn chơi và chế độ phụ.

## Cơ chế hiện có

- Cây sản xuất Linh Khí; Nguyệt Quang Nấm tăng sản lượng theo các mốc trưởng thành trong JSON.
- Cây bắn hỗ trợ nhiều đạn, xuyên mục tiêu, làm chậm, đóng băng và đẩy lùi.
- Trúc Tiễn có kiểu đạn mực riêng.
- Cây nổ, cây nuốt mục tiêu, cây chắn, Linh Đan và bệ Liên Diệp.
- Cây và cương thi nhấp sáng khi nhận sát thương để phản hồi trận đấu rõ hơn.
- Bộ dữ liệu toàn game có các biến thể Cương Thi có giáp, nhảy, bay, gọi viện binh và dẫn đầu; bản demo hiện chỉ dùng Cương Thi Thường và Cương Thi Đội Nón.
- Màn hồ sen có ô nước và yêu cầu bệ Liên Diệp; màn đêm không có Linh Khí rơi từ trời; màn sương che tầm nhìn ở ba cột phải.
- Màn mái nhà hiện có bộ ô mái ngói riêng về mặt hình ảnh; chưa có cơ chế chậu trồng/độ dốc riêng.

## Thẻ cây

Khi có sprite Plant tương ứng, thẻ chọn cây sẽ dùng hình của Plant đó; nếu chưa có ảnh, game tiếp tục dùng biểu tượng dự phòng. Giữ nguyên ID và đường dẫn asset trong JSON khi bổ sung hình.

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

## AI Content Studio

Repository có bộ công cụ AI hỗ trợ phát triển nội dung, lấy cảm hứng từ kiến trúc Multi-Agent của Văn Hiến và bộ quy tắc/validator của Prompt. Công cụ gồm MasterAI, 12 Agent chuyên môn, DataHub, bộ tạo prompt, QA Reviewer, validator dữ liệu và bộ nhớ cục bộ. Công cụ chỉ dùng trong quy trình phát triển, không chạy trong trận đấu và không được đóng gói vào Web export.

Tài liệu: [docs/AI_CONTENT_STUDIO.md](docs/AI_CONTENT_STUDIO.md).

Liệt kê Agent và kiểm tra dữ liệu:

~~~bash
python tools/game_ai_studio.py agents
python tools/game_ai_studio.py inspect --kind plants
python tools/game_ai_studio.py lint "Tạo Plant mới, xuất JSON theo schema hiện tại, không đổi ID"
~~~

Muốn gọi AI, cấu hình `GAME_AI_API_KEY`, `GAME_AI_MODEL` và tùy chọn `GAME_AI_BASE_URL` trong môi trường máy phát triển. Không lưu khóa trong Git. AI tạo bản nháp trước; chỉ cài vào `data/` sau khi đã xem xét kết quả.

## Kiểm thử

Chạy bộ kiểm thử AI và dữ liệu:

~~~bash
python -m unittest discover -s tools/tests -v
python3 tools/validate_project.py
~~~

Kiểm tra import/runtime bằng Godot:

```bash
godot --headless --editor --path . --quit
godot --headless --path . --quit
```

Kiểm thử gameplay trực tiếp vẫn cần mở game và thử thao tác. CI hiện kiểm tra Python, JSON, Godot import, khởi động headless và xuất Web; nó không tự động kiểm thử Unity hoặc các phần mềm ngoài khác.

## Vườn Thiền, xe cắt cỏ và phản hồi trận đấu

- Xe cắt cỏ xuất hiện ở mỗi làn, tự kích hoạt khi zombie tiến đến mép sân và chỉ dùng một lần trong mỗi lượt màn.
- Nổ cây và xe cắt cỏ phát tín hiệu rung lớp sân chơi; HUD không bị dịch chuyển.
- Vườn Thiền có ba chậu lưu cây, giai đoạn phát triển và nhu cầu chăm sóc. Dùng đúng công cụ mới tăng trưởng và nhận xu.
- Tutorial lần đầu hướng dẫn chọn thẻ rồi đặt cây; có thể bỏ qua.
- Save JSON được mở rộng để lưu xu, cây đã mở khóa, trạng thái Vườn Thiền và Tutorial; lưu khi ứng dụng tạm dừng/thoát.
- EventBus dùng Godot signals để gửi yêu cầu rung, thay đổi nhạc theo wave và cập nhật xu mà không buộc gameplay tham chiếu trực tiếp đến HUD.

### Nhạc nền thích ứng (tùy chọn)

Thêm hai tệp OGG nếu có nhạc phù hợp:
- `assets/audio/music-normal.ogg` — nhạc nền bình thường.
- `assets/audio/music-horde.ogg` — nhạc nền cao trào.

AudioManager sẽ crossfade khi wave boss, wave cuối hoặc wave có từ 10 zombie trở lên. Nếu chưa có hai tệp này, game vẫn chạy bình thường; các SFX tổng hợp hiện có tiếp tục hoạt động.

Checklist kiểm thử thủ công: `docs/QA_UI_UX_CHECKLIST.md`.

## Quy trình phát triển đa công cụ

Godot/GDScript là runtime hiện tại, không phải giới hạn của toàn bộ dự án. Có thể sử dụng phần mềm và định dạng khác ở các khâu thiết kế, tạo asset, xử lý âm thanh, tự động hóa, kiểm thử hoặc tạo prototype độc lập. Xem [docs/DEVELOPMENT_TOOLCHAIN.md](docs/DEVELOPMENT_TOOLCHAIN.md) để biết công cụ nào đang thực sự có mặt, công cụ nào là lựa chọn mở rộng và cách trao đổi file mà không làm hỏng project.
