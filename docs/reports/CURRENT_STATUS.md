# Báo cáo rà soát hiện trạng — Vạn Giới Linh Viên

**Nhánh rà soát:** `main`  
**Mục tiêu:** kiểm tra code, dữ liệu, cấu hình và quy trình xuất Web; không kiểm tra các sprite Plant/Zombie và ảnh nền người dùng đang tự tạo.

## Thành phần repository

Các phần nền tảng hiện có: project Godot, scene Main, các Autoload, script tạo entity, grid, card, wave, save, audio, 20 file dữ liệu Plant, 10 file dữ liệu Zombie, 5 màn chơi, cấu hình Web, custom HTML shell và workflow CI.

## Các sửa chữa trong đợt rà soát

- Sửa Địa Lôi Phù để không thể kích nổ trước khi hết thời gian kích hoạt.
- Bổ sung tăng trưởng theo thời gian cho Nguyệt Quang Nấm bằng các mốc được khai báo trong JSON.
- Bổ sung giáp báo cho Cương Thi Cầm Báo; chỉ tăng tốc một lần khi giáp báo thực sự bị phá.
- Điều chỉnh Cương Thi Đội Nón từ tốc độ 1.0 lên 8.0 để giữ vai trò cương thi giáp nặng nhưng không gần như đứng yên.
- Đảm bảo Cương Thi Cầm Cờ xuất hiện đầu wave và được gắn nhãn dẫn đầu.
- Bổ sung kiểu đạn mực cho Trúc Tiễn.
- Sửa kiểm tra mục tiêu của cây có khả năng bắn các làn kề.
- Cho vùng sương mù che mục tiêu khỏi hệ thống chọn mục tiêu của cây.
- Thêm đường trang trí mái ngói cho địa hình mái nhà.
- Bổ sung âm thanh tổng hợp khi chưa có file OGG.
- Xóa các vật phẩm Linh Khí còn tồn tại khi chuyển màn; đặt lại đồng hồ rơi Linh Khí.
- Ngăn callback hoàn tất wave của màn cũ kết thúc nhầm màn mới.
- Mở rộng validator để kiểm tra tăng trưởng, giáp và dữ liệu wave.
- Xóa file tạm `project.autoload.tmp`.

## Các giới hạn còn lại

- Mái nhà hiện là bộ ô địa hình có phong cách mái ngói; chưa có hệ thống chậu trồng hoặc độ dốc có ảnh hưởng đến gameplay.
- Hiệu ứng sương mù hiện chặn khả năng chọn mục tiêu của cây khi zombie còn nằm trong vùng sương; chưa có hiệu ứng che sprite độc lập trên lớp giao diện.
- Các hiệu ứng hoạt ảnh, âm thanh và cân bằng gameplay cần được kiểm tra trong quá trình chơi thực tế.
- Không có kiểm thử tự động mô phỏng toàn bộ trận đấu; workflow CI không xác nhận mọi cơ chế đều cân bằng hoặc hoạt động đúng theo cảm nhận người chơi.
- Sprite Plant/Zombie và ảnh nền vẫn do người dùng tạo và bổ sung thủ công. Không đưa chúng vào danh sách lỗi code.

## Quy trình xác minh

Workflow GitHub Actions chạy:
1. Kiểm tra JSON và tham chiếu bằng Python.
2. Import project bằng Godot 4.2.2 headless.
3. Khởi động project headless.
4. Cài export templates.
5. Xuất bản HTML5 và tải artifact.

Trạng thái thực tế của lần chạy tương ứng với commit này phải được đối chiếu trong tab Actions sau khi push.


## Bổ sung vòng phát triển hiện tại

- Thêm nút tạm dừng và điều chỉnh tốc độ trận đấu 1.0x / 1.5x / 2.0x; các timer gameplay và timer hết hạn vật phẩm được cấu hình để dừng khi pause.
- Sửa luồng Linh Đan để không trừ lượt khi cây đang bận thực hiện kỹ năng.
- Thẻ chọn cây ưu tiên sprite riêng của Plant khi ảnh đã được bổ sung, fallback khi chưa có.
- Lưu kỷ lục Linh Khí còn lại khi hoàn thành màn.
- Bỏ tham chiếu logo bị thiếu khỏi cấu hình UI; seed packet và Linh Khí vẫn được cấu hình riêng.
- Thêm AI Content Studio chạy ngoài runtime Godot: 12 Agent, MasterAI, DataHub, PromptBuilder, QA Reviewer, validator và memory cục bộ.
- Bản nháp AI mặc định lưu trong .game_ai/drafts/; chỉ cài vào data/ khi có cờ --install và đã qua validator/QA.
- Tích hợp kiểm thử unittest cho công cụ AI vào GitHub Actions. Kiểm thử không gọi API bên ngoài.
- Không có khóa API trong repository; việc gọi model trực tuyến cần người phát triển cấu hình biến môi trường cục bộ.

## Giới hạn cần kiểm tra trực tiếp

- Chưa có sprite cho các Plant, Zombie và background đang chờ người dùng tạo.
- Công cụ AI đã có kiểm thử schema/định tuyến; khả năng kết nối model thật phụ thuộc provider, model và biến môi trường, chưa được kiểm chứng khi không có khóa API.
- CI kiểm tra parser, startup headless, data và HTML5 export; không mô phỏng một trận đấu hoàn chỉnh hoặc đánh giá cân bằng bằng người chơi.
- Cần thử thao tác pause/speed, Linh Đan, hoàn thành màn, tải save và gameplay thực tế trong Godot Editor/Web export.


## Bổ sung UI/UX từ bộ tham khảo PvZ

- Chuyển các hành vi tham khảo từ Unity C# sang GDScript, không đưa mã Unity vào project Godot.
- Thêm công cụ Xẻng: đào bỏ cây ở ô được chọn; ưu tiên cây phía trên bệ Liên Diệp, không hoàn lại Linh Khí.
- Thêm ghost preview theo ô hợp lệ và sprite Plant đã có; dùng hình dự phòng khi chưa có sprite.
- Mở rộng input đặt cây/xẻng để nhận cả InputEventMouseButton và InputEventScreenTouch.
- Thêm Almanac tra cứu Plant/Zombie trực tiếp từ DataLoader, gồm ảnh, chỉ số và danh sách kỹ năng.
- Thêm bản đồ màn chơi cuộn ngang, biểu thị màn đã hoàn thành/mở khóa/bị khóa.
- Thêm thanh tiến độ wave và biểu ngữ cho boss, final wave và wave có số lượng đông.
- Thêm hiệu ứng hit flash cho Plant và Zombie khi nhận sát thương.
- Chưa thêm Zen Garden, Power-ups Pinch/Toss hoặc pre-battle seed chooser: các hệ thống này cần vòng lặp gameplay, dữ liệu tiến trình và UI độc lập; chưa nên giả lập bằng các nút không có logic thật.
- Hệ thống cooldown thẻ chỉ nên kích hoạt khi dữ liệu Plant có thời gian hồi chiêu được cân bằng và khai báo rõ; hiện không tự gán thời gian mặc định.



## Bổ sung phần UI/UX nâng cao

- Thêm EventBus dựa trên Godot signals cho rung sân chơi, cường độ nhạc và cập nhật xu.
- Thêm rung lớp WorldLayer khi cây nổ, xe cắt cỏ kích hoạt hoặc xuất hiện boss; HUD không bị rung theo.
- Thêm xe cắt cỏ cho từng lane, kích hoạt một lần mỗi màn và tự chạy hết sân.
- Thêm Vườn Thiền có ba chậu, lưu ID cây/giai đoạn/nhu cầu; chăm sóc đúng công cụ tăng trưởng và nhận xu.
- Mở rộng SaveSystem với coins, unlocked_plant_ids, zen_garden_pots, tutorial_completed; lưu khi app pause/close.
- Bổ sung Tutorial hai bước và nút bỏ qua.
- AudioManager hỗ trợ hai nhạc nền OGG và crossfade theo wave boss/final/đông; nếu chưa có tệp nhạc, tính năng thích ứng không phát nhạc và không ảnh hưởng gameplay.
- Tạo checklist QA thủ công tại docs/QA_UI_UX_CHECKLIST.md.
- Bộ sinh lưới Unity không được chuyển nguyên xi: sân Godot tiếp tục do GridManager dựng bằng dữ liệu cấu hình.

## Các giới hạn mới cần xác minh trực tiếp

- Giá trị thưởng Vườn Thiền hiện là 10 xu cho mỗi lần chăm sóc đúng; đây là thông số khởi điểm, chưa được cân bằng.
- Vườn Thiền hiện dùng UI nút/nhãn mặc định, chưa có animation, sprite dụng cụ hoặc lịch chăm sóc theo thời gian thực.
- Nhạc thích ứng chỉ hoạt động khi người phát triển thêm đủ hai tệp OGG nêu trong README; repository hiện không chứa các track đó.
- Xe cắt cỏ dùng hình vẽ dự phòng trong code, chưa có sprite/animation riêng.
- Tutorial là lớp hướng dẫn không chặn thao tác, chưa có spotlight mask hoặc hand-pointer animation.
- Rung màn hình hiện áp dụng cho lớp sân chơi bằng tween, không rung HUD.
