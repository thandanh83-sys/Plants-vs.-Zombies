# Checklist QA — Bản demo Thư Viện Cổ

Phạm vi hiện tại: một màn, hai Plant và hai Zombie. CI kiểm tra dữ liệu, import/parser, khởi động headless và export; các mục bên dưới vẫn cần chơi thử thủ công.

## 1. Màn hình và đội hình
- [ ] Khởi động game hiển thị màn chọn đội hình với đúng 2 thẻ: Trúc Tiễn và Hồng Liên Nổ.
- [ ] Cả hai thẻ dùng sprite tương ứng, không hiển thị đa giác dự phòng.
- [ ] Thanh thẻ không có Plant thứ ba; seed slot được đọc từ `level-01-thu-vien.json`.
- [ ] Nhấn Bắt đầu trận khởi chạy đúng màn Thư Viện Cổ.
- [ ] Chơi lại màn vẫn giữ đúng bộ hai Plant, không lấy lại các Plant đã chọn ở màn khác.

## 2. Linh Khí, hồi chiêu và Plant Food
- [ ] Bắt đầu với 250 Linh Khí và 1 lượt Linh Đan.
- [ ] Đặt Trúc Tiễn trừ đúng 100 Linh Khí; thẻ Trúc Tiễn hồi chiêu, thẻ Hồng Liên Nổ vẫn có thể dùng.
- [ ] Đặt Hồng Liên Nổ trừ đúng 150 Linh Khí và kích hoạt nổ khi Zombie tiến vào phạm vi.
- [ ] Thẻ không thể chọn khi chưa đủ Linh Khí hoặc đang hồi chiêu.
- [ ] Linh Khí rơi theo chu kỳ ban ngày; nhặt một vật phẩm chỉ cộng đúng số lượng cấu hình.
- [ ] Dùng Linh Đan lên Trúc Tiễn tạo loạt bắn nhanh.
- [ ] Dùng Linh Đan lên Hồng Liên Nổ gây đại bạo phá dọc làn; lượt Linh Đan chỉ bị trừ khi kích hoạt hợp lệ.

## 3. Hai loại Zombie và ba đợt
- [ ] Wave 1 chỉ sinh Cương Thi Thường.
- [ ] Wave 2 và wave 3 chỉ sinh Cương Thi Thường hoặc Cương Thi Đội Nón; không có loại Zombie thứ ba.
- [ ] Cương Thi Thường nhận sát thương trực tiếp và bị hạ đúng lúc.
- [ ] Giáp của Cương Thi Đội Nón hấp thụ sát thương trước sinh lực; hiển thị và hành vi không bị lỗi.
- [ ] Zombie đi đúng làn, tấn công Plant khi tiếp cận và gây thua nếu vượt ngưỡng nhà.
- [ ] Sau wave cuối, chỉ thắng khi không còn Zombie.

## 4. Kết thúc và chơi lại
- [ ] Thắng màn hiển thị trạng thái hoàn thành và lưu tiến trình.
- [ ] Thua màn hiển thị đúng trạng thái; nút chơi lại hoạt động.
- [ ] Chơi lại xóa Zombie, đạn và Linh Khí còn sót; không nhân đôi tín hiệu hoặc bộ đếm wave.
- [ ] Pause/Resume và tốc độ 1.0x, 1.5x, 2.0x hoạt động trong trận.
- [ ] Kiểm tra click chuột và chạm màn hình ở cùng một ô: chỉ một thao tác được xử lý.

## 5. Hiển thị
- [ ] Màn vẫn đọc được khi chưa có tranh nền riêng; nền màu dự phòng và lưới không bị che.
- [ ] Hai Plant và hai Zombie không bị phóng quá lớn so với ô chơi.
- [ ] HUD, thanh thẻ và thanh tiến độ không đè lên nhau ở tỷ lệ 16:9.
- [ ] Không xuất hiện lỗi script, lỗi tải sprite hoặc lỗi JSON trong Output.
