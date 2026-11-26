# Backgrounds

Ảnh nền màn chơi dùng đường dẫn `res://assets/backgrounds/<file>.png` trong JSON level.

## Màn demo hiện tại

- Dự kiến: `thu-vien-co.png` — nền Thư Viện Cổ.
- Trạng thái: chưa có ảnh nền riêng trong repository.
- Khi chưa có trường `background` trong JSON level, game dùng nền màu/lưới mặc định; không tạo đường dẫn trỏ tới file chưa tồn tại.

## Quy cách

- PNG ngang, ưu tiên bố cục 16:9 và độ phân giải phù hợp viewport 1280×720.
- Giữ vùng sân chơi trung tâm tương đối thoáng, chi tiết kiến trúc đặt ở hậu cảnh và rìa khung hình.
- Không đặt Plant, Zombie, thẻ UI, chữ hoặc lưới chiến đấu cố định vào ảnh nền; các thành phần này do game render riêng.
- Không dùng ảnh có bản quyền từ trò chơi khác.
