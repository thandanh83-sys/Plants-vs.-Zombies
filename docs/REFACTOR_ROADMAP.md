# Lộ trình refactor theo source hiện tại

Phạm vi gần nhất vẫn là bản demo có thể chơi thử: một màn Thư Viện Cổ, hai Plant và hai Zombie. Không refactor diện rộng trước khi lát cắt này ổn định.

## Kết quả kiểm tra kiến trúc

- `core/GameEvents.gd` đã tồn tại. Nó đang dùng cho sự kiện liên hệ thống như rung màn hình, cường độ wave và xu. Không tạo thêm EventBus thứ hai.
- `core/GameManager.gd` sở hữu trạng thái trận, Linh Khí, Linh Đan và các signal `sun_changed`, `state_changed`, `plant_food_changed`.
- `core/CardManager.gd` chỉ tạo/quản lý thẻ, affordability, hồi chiêu và phát `card_selected`; nó không gọi `GameManager.spend_sun()` và không tự đặt Plant.
- `core/EntityFactory.gd` đã đọc `behavior_script` từ JSON, có script mặc định nếu không khai báo.
- `behaviors/PlantBehavior.gd` phân loại theo `type` và `abilities`; `behaviors/ZombieBehavior.gd` xử lý các kỹ năng qua `abilities`. Không thấy nhánh so sánh ID riêng của từng Plant/Zombie trong hai behavior này.
- `scenes/Main.gd` vẫn là bộ điều phối lớn: dựng màn hình, nhận input trên sân, thực hiện giao dịch đặt cây và điều phối các manager. Đây là điểm refactor quan trọng tiếp theo, nhưng tách vội sẽ tạo nhiều rủi ro hồi quy.
- `tools/validate_project.py` và Python unit tests đã có; CI hiện chạy kiểm tra dữ liệu, Godot import/parser, khởi động headless và export Web. Chưa có JSON Schema tiêu chuẩn riêng.

## Thay đổi trong nhánh demo

1. Thẻ Plant ưu tiên `card_sprite` trong JSON, rồi đường dẫn theo ID, rồi sprite Plant; ảnh dùng chung là phương án cuối.
2. Sửa manifest UI để chỉ tham chiếu file đang tồn tại.
3. Đưa tầm kích nổ, bán kính và sát thương Linh Đan của Hồng Liên Nổ vào JSON.
4. Validator kiểm tra đường dẫn UI đã khai báo và `card_sprite`; unit tests khóa phạm vi demo và kiểm tra asset/giá trị chiến đấu.

## Thứ tự làm tiếp

### P0 — Hoàn thiện bản demo
- Bổ sung ảnh thẻ Hồng Liên Nổ và background Thư Viện Cổ.
- Giữ test kiểm tra tất cả đường dẫn asset đã khai báo.
- Chơi thử để điều chỉnh giá, sát thương, tốc độ, hồi chiêu và nhịp wave; CI không thay thế kiểm thử gameplay trực tiếp.

### P1 — Chuẩn hóa dữ liệu
- Tách các giá trị gameplay còn hardcode khỏi default/fallback trong behavior khi chúng thực sự cần cấu hình theo từng entity.
- Bổ sung JSON Schema cho Plant, Zombie, level và cấu hình; chạy schema validation trong CI sau khi thống nhất schema với dữ liệu hiện tại.
- Giữ fallback trong GDScript cho khả năng tương thích và thông báo lỗi rõ ràng; không biến mọi hằng số trình bày thành dữ liệu gameplay.

### P2 — Giảm trách nhiệm của Main
- Trước tiên tách phần dựng HUD/overlay thành UI controller độc lập.
- Sau đó mới tách vòng đời màn/wave thành Level controller.
- Giữ giao dịch đặt Plant ở một gameplay/controller service: kiểm tra ô, kiểm tra/trừ Linh Khí, tạo entity và đánh dấu ô thành công theo một thứ tự nguyên tử. Không chuyển trách nhiệm trừ tài nguyên vào CardManager hoặc GridManager chỉ để tách file.

### Nguyên tắc
- Mỗi đợt refactor nhỏ có test và CI riêng.
- Không đổi ID dữ liệu đang được SaveSystem hoặc level tham chiếu.
- Không di chuyển hàng loạt thư mục nếu không có lợi ích runtime/maintainability rõ ràng.
- Không coi CI headless/export là bằng chứng đã chơi thử thành công.
