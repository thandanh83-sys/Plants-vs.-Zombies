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
