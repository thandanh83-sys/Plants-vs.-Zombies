# Báo cáo rà soát hiện trạng — Vạn Giới Linh Viên

**Nhánh rà soát:** `feat/pvz-core-gameplay-parity` (PR #13, draft)  
**Mục tiêu:** kiểm tra code, dữ liệu, cấu hình và quy trình xuất Web; không kiểm tra các sprite Plant/Zombie và ảnh nền người dùng đang tự tạo.

## Phân biệt engine và toolchain

- Runtime đang có trong repository là **Godot 4.2+**, logic runtime dùng GDScript.
- Điều này không có nghĩa toàn bộ quy trình làm game chỉ được dùng GDScript hoặc chỉ được dùng Godot.
- Repository cũng có Python tooling, JSON data, HTML shell, PNG art và OGG audio. Có thể phối hợp Unity, Blender, Aseprite, Krita/Photoshop, Audacity/DAW hoặc công cụ AI ở các khâu phù hợp.
- Tại commit rà soát này, **chưa có Unity project độc lập** và GitHub Actions chưa build/test Unity. Các đoạn Unity C# được cung cấp trước đây là tài liệu tham khảo; các phần đã tích hợp vào runtime hiện tại được chuyển/viết lại cho Godot.
- Không đưa Unity C# vào thư mục GDScript hoặc khẳng định Unity đã được tích hợp nếu chưa có project, cấu hình build và kiểm thử riêng.

Chi tiết công cụ, loại file và quy tắc mở rộng: [docs/DEVELOPMENT_TOOLCHAIN.md](../DEVELOPMENT_TOOLCHAIN.md).

## Thành phần repository

Các phần nền tảng hiện có: project Godot, scene Main, các Autoload, script tạo entity, grid, card, wave, save, audio, 20 file dữ liệu Plant, 10 file dữ liệu Zombie, 5 màn chơi, cấu hình Web, custom HTML shell, Python tools và workflow CI.

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
2. Chạy unit tests của AI Content Studio.
3. Import project bằng Godot 4.2.2 headless.
4. Khởi động project headless.
5. Cài export templates.
6. Xuất bản HTML5 và tải artifact.

Trạng thái thực tế của lần chạy tương ứng với commit phải được đối chiếu trong tab Actions sau khi push.

## Bổ sung vòng phát triển hiện tại

- Thêm nút tạm dừng và điều chỉnh tốc độ trận đấu 1.0x / 1.5x / 2.0x; các timer gameplay và timer hết hạn vật phẩm được cấu hình để dừng khi pause.
- Sửa luồng Linh Đan để không trừ lượt khi cây đang bận thực hiện kỹ năng.
- Thẻ chọn cây ưu tiên `card_sprite`, tiếp đến đường dẫn `assets/ui/seed-packet/<plant-id>.png`, sprite Plant và cuối cùng ảnh thẻ dùng chung nếu được cấu hình hợp lệ.
- Lưu kỷ lục Linh Khí còn lại khi hoàn thành màn.
- Đồng bộ `ui-assets.json` với các file thực tế: logo và Linh Khí có đường dẫn hợp lệ; bỏ đường dẫn seed-packet dùng chung vốn không tồn tại.
- Thêm AI Content Studio chạy ngoài runtime Godot: 12 Agent, MasterAI, DataHub, PromptBuilder, QA Reviewer, validator và memory cục bộ.
- Bản nháp AI mặc định lưu trong `.game_ai/drafts/`; chỉ cài vào data/ khi có cờ `--install` và đã qua validator/QA.
- Tích hợp kiểm thử unittest cho công cụ AI vào GitHub Actions. Kiểm thử không gọi API bên ngoài.
- Không có khóa API trong repository; việc gọi model trực tuyến cần người phát triển cấu hình biến môi trường cục bộ.

## Bổ sung UI/UX từ bộ tham khảo PvZ

- Các đoạn Unity C# được dùng làm tài liệu tham khảo thiết kế; hành vi được triển khai cho runtime Godot bằng GDScript, không copy C# Unity vào project.
- Thêm công cụ Xẻng: đào bỏ cây ở ô được chọn; ưu tiên cây phía trên bệ Liên Diệp, không hoàn lại Linh Khí.
- Thêm ghost preview theo ô hợp lệ và sprite Plant đã có; dùng hình dự phòng khi chưa có sprite.
- Mở rộng input đặt cây/xẻng để nhận cả InputEventMouseButton và InputEventScreenTouch.
- Thêm Almanac tra cứu Plant/Zombie trực tiếp từ DataLoader, gồm ảnh, chỉ số và danh sách kỹ năng.
- Thêm bản đồ màn chơi cuộn ngang, biểu thị màn đã hoàn thành/mở khóa/bị khóa.
- Thêm thanh tiến độ wave và biểu ngữ cho boss, final wave và wave có số lượng đông.
- Thêm hiệu ứng hit flash cho Plant và Zombie khi nhận sát thương.

## Bổ sung phần UI/UX nâng cao

- Dùng `core/GameEvents.gd` (đã tồn tại) cho rung sân chơi, cường độ nhạc và cập nhật xu; không tạo EventBus trùng lặp.
- Thêm rung lớp WorldLayer khi cây nổ, xe cắt cỏ kích hoạt hoặc xuất hiện boss; HUD không bị dịch chuyển.
- Thêm xe cắt cỏ cho từng lane, kích hoạt một lần mỗi màn và tự chạy hết sân.
- Thêm Vườn Thiền có ba chậu, lưu ID cây/giai đoạn/nhu cầu; chăm sóc đúng công cụ tăng trưởng và nhận xu.
- Mở rộng SaveSystem với coins, unlocked_plant_ids, zen_garden_pots, tutorial_completed; lưu khi app pause/close.
- Bổ sung Tutorial hai bước và nút bỏ qua.
- AudioManager hỗ trợ hai nhạc nền OGG và crossfade theo wave boss/final/đông; nếu chưa có tệp nhạc, tính năng thích ứng không phát nhạc và không ảnh hưởng gameplay.
- Tạo checklist QA thủ công tại docs/QA_UI_UX_CHECKLIST.md.
- Bộ sinh lưới Unity không được chuyển nguyên xi: sân Godot tiếp tục do GridManager dựng bằng dữ liệu cấu hình.

## Các giới hạn cần kiểm tra trực tiếp

- Giá trị thưởng Vườn Thiền hiện là 10 xu cho mỗi lần chăm sóc đúng; đây là thông số khởi điểm, chưa được cân bằng.
- Vườn Thiền hiện dùng UI nút/nhãn mặc định, chưa có animation, sprite dụng cụ hoặc lịch chăm sóc theo thời gian thực.
- Nhạc thích ứng chỉ hoạt động khi người phát triển thêm đủ hai tệp OGG nêu trong README; repository hiện không chứa các track đó.
- Xe cắt cỏ dùng hình vẽ dự phòng trong code, chưa có sprite/animation riêng.
- Tutorial là lớp hướng dẫn không chặn thao tác, chưa có spotlight mask hoặc hand-pointer animation.
- Rung màn hình hiện áp dụng cho lớp sân chơi bằng tween, không rung HUD.

## Phạm vi kiểm thử

- CI xác minh Python tests, JSON, Godot import/parser, headless startup và HTML5 export.
- CI **không** xác minh Unity, Blender, Aseprite, phần mềm chỉnh ảnh/âm thanh hoặc build của engine khác.
- Kiểm thử gameplay trực tiếp vẫn cần mở game và thử thao tác trên PC/điện thoại; chưa có bằng chứng QA thiết bị thực tế trong báo cáo này.


## Đồng bộ bản demo và kiểm tra kiến trúc — 2026-11-26

- Phạm vi PR #13: một màn Thư Viện Cổ, hai Plant (Trúc Tiễn, Hồng Liên Nổ), hai Zombie (Cương Thi Thường, Cương Thi Đội Nón), ba wave.
- Đã xác minh bốn sprite nhân vật, logo, biểu tượng Linh Khí và ảnh thẻ Trúc Tiễn có trong nhánh. Ảnh thẻ Hồng Liên Nổ và background Thư Viện Cổ vẫn chưa có; game có fallback nên không khai báo đường dẫn giả.
- `CardManager` không tiêu Linh Khí và không đặt Plant; nó phát `card_selected`, quản lý hồi chiêu và trạng thái thẻ. Giao dịch đặt cây vẫn do `Main.gd` điều phối.
- `GameManager` đang sở hữu trạng thái/tài nguyên và phát signal. `GameEvents.gd` phụ trách sự kiện liên hệ thống. Không tạo EventBus mới.
- `PlantBehavior.gd` và `ZombieBehavior.gd` dùng dữ liệu `type`/`abilities`, không có nhánh hành vi theo ID riêng của từng nhân vật trong source đã kiểm tra.
- `EntityFactory.gd` đã hỗ trợ `behavior_script` trong JSON.
- Hồng Liên Nổ đã khai báo tầm kích nổ, bán kính và sát thương Linh Đan trong JSON. Validator kiểm tra UI asset manifest và đường dẫn `card_sprite`; unit tests bổ sung kiểm tra đường dẫn và thông số demo.
- `Main.gd` vẫn là controller lớn. Việc tách UI/Level controller được để ở bước P2, sau khi demo được kiểm thử gameplay để giảm nguy cơ regression.
- Lần CI thành công trước đó thuộc commit cũ `a0d32b1`; các thay đổi mới phải chờ workflow chạy trên head commit mới trước khi kết luận. CI chỉ xác minh Python/data, Godot import/startup và HTML5 export, không thay thế chơi thử thủ công.