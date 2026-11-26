# Checklist QA — Gameplay & UI/UX

Phạm vi: kiểm thử thủ công trong Godot Editor và bản Web/mobile. CI chỉ xác nhận dữ liệu, import/parser, khởi động headless và export; không thay thế các bước dưới đây.

## 1. Công cụ và thao tác
- [ ] Chọn thẻ cây rồi chọn Xẻng: lựa chọn thẻ cũ phải bị hủy.
- [ ] Chọn Xẻng rồi chọn thẻ cây: chế độ Xẻng phải bị hủy.
- [ ] Đào cây trên Liên Diệp: cây phía trên bị xóa trước, Liên Diệp vẫn còn.
- [ ] Đào ô trống hoặc ô có vật cản: không phát sinh hoàn tiền Linh Khí.
- [ ] Nhấn Linh Đan khi cây đang bận: không trừ lượt sử dụng.
- [ ] Thử click chuột và chạm màn hình ở cùng một ô: chỉ một thao tác được xử lý.

## 2. Đội hình và hồi chiêu
- [ ] Vào màn từ khởi động, menu chọn màn và bản đồ: luôn xuất hiện giao diện chọn đội hình trước khi trận bắt đầu.
- [ ] Mỗi màn chọn đúng số thẻ quy định; nút Bắt đầu chỉ bật khi đủ số lượng.
- [ ] Cây bắt buộc của màn được chọn sẵn, có nhãn BẮT BUỘC và không thể bỏ chọn.
- [ ] Màn hồ sen luôn có Nhật Nguyệt Thảo và Liên Diệp; màn đêm luôn có Dạ Quang Nấm trong đội hình.
- [ ] Nút Đội hình đề xuất giữ lại các cây bắt buộc và điền đủ số ô còn lại.
- [ ] Đội hình được lưu; mở lại màn và khởi động lại không tạo ra đội hình thiếu cây bắt buộc.
- [ ] Sau khi trồng, đúng thẻ cây chuyển sang Hồi chiêu; các thẻ khác vẫn chọn được.
- [ ] Khi hồi chiêu còn thời gian, thẻ bị vô hiệu hóa và bộ đếm giảm; khi về 0, thẻ bật lại.
- [ ] Tạm dừng làm thời gian hồi chiêu dừng; tăng tốc làm hồi chiêu tiến triển nhanh tương ứng.
- [ ] Đặt cây thất bại do ô không hợp lệ hoặc thiếu Linh Khí không bắt đầu hồi chiêu.

## 3. Linh Đan rơi và thu thập
- [ ] Cương Thi dẫn đầu/Boss có cấu hình rơi Linh Đan thì khi bị hạ mới tạo vật phẩm.
- [ ] Hạ cùng mục tiêu bởi nhiều nguồn sát thương liên tiếp chỉ tạo một vật phẩm.
- [ ] Nhặt Linh Đan tăng đúng một lượt; không nhặt thì vật phẩm tự biến mất theo thời hạn.
- [ ] Chuyển màn hoặc chơi lại xóa các vật phẩm Linh Đan còn sót.

## 4. Pause và tốc độ
- [ ] Chuyển tốc độ 1.0x → 1.5x → 2.0x, sau đó Pause/Resume: tốc độ trước khi Pause phải được giữ nguyên.
- [ ] Khi Pause, zombie, đạn, wave, rơi Linh Khí và thời gian hiệu ứng gameplay phải dừng.
- [ ] Mở Almanac/Bản đồ/Vườn Thiền khi đang chơi: gameplay tạm dừng; đóng panel phải khôi phục đúng trạng thái pause và tốc độ trước đó.
- [ ] Kết thúc màn khi đang ở tốc độ 2.0x: trạng thái kết thúc không được giữ tốc độ hoặc pause của màn trước.

## 4. Linh Khí và HUD
- [ ] Thu thập Linh Khí khi không kéo/chọn thẻ: tăng đúng số lượng và phát âm thanh.
- [ ] Nhặt nhiều Linh Khí liên tiếp: cao độ SFX thay đổi trong giới hạn, không tăng vô hạn.
- [ ] Thử nhấp Linh Khí sát thanh thẻ: điểm chạm phải không bị nút HUD khác chiếm.
- [ ] Không đủ Linh Khí: không tạo cây, không trừ tài nguyên.
- [ ] Sau khi chuyển màn hoặc chơi lại: Linh Khí rơi từ màn cũ phải được dọn sạch.

## 5. Wave, zombie và xe cắt cỏ
- [ ] Kiểm tra mọi lane có đúng một xe cắt cỏ khi bắt đầu màn.
- [ ] Zombie chạm ngưỡng kích hoạt: xe chạy đúng lane, hạ zombie trên đường và tự biến mất ở mép phải.
- [ ] Mỗi xe chỉ kích hoạt một lần trong một lượt màn; chơi lại phải khôi phục xe.
- [ ] Wave thường không bật nhạc cao trào; wave boss/final/đông bật nhạc cao trào và khi kết thúc trở về bình thường.
- [ ] Sau wave cuối, chỉ chiến thắng khi không còn zombie.
- [ ] Zombie vượt qua ngưỡng nhà khi xe cắt cỏ đã mất: kích hoạt thua đúng một lần.

## 6. Vườn Thiền và lưu dữ liệu
- [ ] Gieo cây vào chậu trống; không thể gieo đè lên chậu đã có cây.
- [ ] Chỉ công cụ khớp nhu cầu mới làm tăng trưởng và cộng xu.
- [ ] Chăm sóc sai nhu cầu: không cộng xu, không tăng trưởng.
- [ ] Đóng và mở lại game: cây, giai đoạn phát triển, nhu cầu, xu và tiến trình màn được giữ.
- [ ] Thoát ứng dụng hoặc chuyển ứng dụng trên thiết bị di động: dữ liệu được lưu.
- [ ] File save hỏng/thiếu trường: game khởi tạo giá trị mặc định mà không dừng khởi động.

## 7. Tutorial và đa màn hình
- [ ] Tutorial lần đầu hướng dẫn chọn thẻ rồi đặt cây; nút bỏ qua hoạt động.
- [ ] Hoàn thành hoặc bỏ qua Tutorial: không tự hiện lại ở lần chạy sau.
- [ ] Kiểm tra độ phân giải 16:9, 21:9 và 4:3; HUD không che ô chơi hoặc bị cắt.
- [ ] Kiểm tra điện thoại có tai thỏ/camera khoét màn hình và xoay ngang trái/phải.
- [ ] Safe Area được áp dụng sau khi kích thước viewport thay đổi.

## 8. Rung và phản hồi
- [ ] Nổ cây và kích hoạt xe cắt cỏ tạo rung nhẹ ở lớp sân chơi, không làm lệch HUD.
- [ ] Nhiều vụ nổ liên tiếp không tạo tween rung chồng vô hạn.
- [ ] Hit Flash không để lại màu tint sau khi tween kết thúc.

## Ghi nhận
Với mỗi lỗi, lưu: thiết bị/độ phân giải, màn chơi, thao tác tái hiện, kết quả thực tế, kết quả mong đợi và log Godot.
