# Đối chiếu hệ thống — Vạn Giới Linh Viên với Plants vs. Zombies 1 và 2

## Mục tiêu và ranh giới

Mục tiêu là tái tạo **cảm giác chơi và các hệ thống chức năng** của dòng game thủ thành theo làn: chuẩn bị đội hình, quản lý tài nguyên, đặt quân theo ô, chống các đợt kẻ địch, mở khóa nội dung và chơi lại vì chiến thuật. Vạn Giới Linh Viên giữ chủ đề tiên đạo/phật giáo, tên gọi, thiết kế nhân vật, hình ảnh, âm thanh, cốt truyện và mã nguồn riêng.

Không sao chép mã nguồn, sprite, âm thanh, tên nhân vật, lời thoại, màn hình hoặc bố cục độc quyền của Plants vs. Zombies. "Giống" ở đây là tương đương về chức năng và nhịp chơi, không phải bản sao tài sản trí tuệ.

## Phạm vi đang triển khai trước mắt

Không phát triển đồng thời toàn bộ chiến dịch. Bản dựng hiện tại chỉ kiểm tra một lát cắt dọc hoàn chỉnh:

- **Màn:** Thư Viện Cổ.
- **2 Plant:** Trúc Tiễn và Hồng Liên Nổ.
- **2 Zombie:** Cương Thi Thường và Cương Thi Đội Nón.
- **3 wave:** wave đầu chỉ có Cương Thi Thường; wave 2 và 3 phối hợp hai loại.
- **Mục tiêu kiểm thử:** đặt cây, tiêu Linh Khí, hồi chiêu, bắn đạn, nổ diện rộng, dùng Linh Đan, thắng/thua và chơi lại.
- **Asset:** cả bốn nhân vật có sprite trong repository; nền màn hiện dùng nền màu dự phòng vì chưa có tranh nền riêng.

Các level 2–5 được giữ nguyên dữ liệu từ `main`, không đưa thêm nội dung vào đợt này. Những hệ thống nhiều thế giới, shop, mini-game, Survival/Endless, nhiệm vụ và Arena được hoãn cho tới khi màn mẫu đạt yêu cầu chơi thử.

## Mốc tham chiếu

- Plants vs. Zombies 1 có Adventure, Mini-Games, Puzzle, Survival và Zen Garden; Adventure đi qua các môi trường ngày, đêm, sương mù, hồ bơi và mái nhà, đồng thời có Almanac và cửa hàng của Crazy Dave. Nguồn: trang game chính thức trên Steam: https://store.steampowered.com/app/3590/Plants_vs_Zombies/
- Plants vs. Zombies 2 mở rộng với nhiều thế giới, hàng trăm Plant/Zombie, Seed Packets, nâng cấp cây, Arena/competitive league, nhiệm vụ Travel Log, sự kiện/mini-game, Endless Zones và boss cuối thế giới. Nguồn: EA Features: https://www.ea.com/games/plants-vs-zombies/plants-vs-zombies-2/features
- EA mô tả Plant Food, power-up cảm ứng, nhiệm vụ phụ và Challenge Zones trong thông cáo ra mắt PVZ2: https://news.ea.com/press-releases/press-releases-details/2013/PopCap-Launches-Plants-vs.-Zombies-2-Worldwide/default.aspx

## Bảng đối chiếu tại thời điểm rà soát

| Hệ thống | PvZ 1 / PvZ 2 | Vạn Giới Linh Viên trước nhánh này | Trạng thái sau nhánh này |
|---|---|---|---|
| Sân chơi theo làn/ô | Cơ chế trung tâm | Có lưới 5x9, 5 làn | Đã có |
| Đặt Plant, giá tài nguyên | Có | Có Linh Khí, thẻ Plant | Đã có |
| Hồi chiêu Seed Packet | Có | Chưa có hồi chiêu sau khi trồng | Đã thêm hồi chiêu theo vai trò; có thể cấu hình từng Plant |
| Chọn đội hình trước màn | Có | Tự hiện toàn bộ cây khả dụng | Đã thêm chọn tối đa 6 cây trước màn |
| Đội hình trước màn | Chọn một nhóm Seed Packet trước trận | Trước đây toàn bộ cây khả dụng tự hiện trên thanh | Bản demo hiện chọn đúng 2 Plant, giới hạn theo level JSON |
| Plant Food / Linh Đan | PvZ2 có Plant Food | Game có lượt Linh Đan ban đầu | Bản demo có hiệu ứng riêng cho Trúc Tiễn và Hồng Liên Nổ; chưa dùng cơ chế Zombie rơi vật phẩm |
| Đợt tấn công, tăng áp lực | Có | Có wave theo JSON và Boss cơ bản | Đã có nền tảng; cần bổ sung wave đa pha/định hình tốt hơn |
| Kẻ địch có vai trò khác nhau | Có | 10 loại dữ liệu; giáp, nhảy, bay, triệu hồi, dẫn đầu | Đã có nền tảng; cần nhiều biến thể và cân bằng hơn |
| Môi trường | Ngày/đêm/sương/hồ/mái | Có 5 loại môi trường logic/hình vẽ cơ bản | Có nền tảng; mái chưa có chậu/độ dốc gameplay, sương chưa có lớp phủ hình ảnh độc lập |
| Almanac | Có | Có tra cứu Plant/Zombie từ JSON | Đã có bản cơ bản |
| Bản đồ, mở khóa màn | Có | Có 5 màn và mở khóa tuần tự | Đã có bản cơ bản |
| Zen Garden | Có | Có 3 chậu và chăm sóc tức thời | Có bản đơn giản; chưa có mô phỏng thời gian, nhiều khu vườn, vật phẩm trang trí |
| Mini-Games / Puzzle / Survival | Có trong PvZ1; PvZ2 có minigames/challenge | Chưa có các mode tách biệt | Chưa làm |
| Shop / nâng cấp Plant | Crazy Dave Shop ở PvZ1; Seed Packet upgrades ở PvZ2 | Có coins và trường unlocked_plant_ids nhưng chưa có shop/upgrade loop hoàn chỉnh | Chưa làm |
| Nhiệm vụ / sự kiện / Endless / Arena | PvZ2 có | Chưa có | Chưa làm |
| Chiến dịch dài, nhiều thế giới | PvZ1 có 50 level Adventure; PvZ2 nhiều thế giới và hàng trăm level | 5 màn trong dữ liệu hiện có | Đang hoãn; chỉ tập trung hoàn thiện một màn mẫu |
| Hình ảnh, hoạt ảnh, âm thanh | Bộ asset được sản xuất hoàn chỉnh | Mới có 2 ảnh Plant, 2 ảnh Zombie và một số UI; background/audio còn thiếu | Cần sản xuất asset nguyên bản |
| Boss & thử thách cuối vùng | Có | Màn 5 có cờ boss cơ bản | Mới ở mức sơ khai; cần boss nhiều pha, pattern và phần thưởng vùng |

## Hạng mục ưu tiên

### P0 — Củng cố vòng chơi cốt lõi
1. Chọn đội hình và cây bắt buộc.
2. Hồi chiêu thẻ có cấu hình theo từng Plant.
3. Thu thập Linh Khí/Linh Đan có phản hồi rõ, thời hạn và cân bằng nguồn cung.
4. Khắc phục và kiểm tra từng kỹ năng Plant/Zombie; không để dữ liệu khai báo một kỹ năng nhưng code chưa thực thi.
5. Kiểm tra chiến thắng/thất bại, pause, tốc độ, chuyển màn, lưu và tải.

### P1 — Nâng chiến dịch
1. Mở rộng thành nhiều vùng, mỗi vùng có cơ chế môi trường/địa hình riêng thật sự ảnh hưởng gameplay.
2. Mỗi vùng có nhiều màn thường, màn thử thách, boss nhiều pha và phần thưởng.
3. Bổ sung Zombie có cơ chế khắc chế rõ ràng, không chỉ tăng HP/tốc độ.
4. Tăng số lượng Plant theo vai trò nhưng duy trì khác biệt chiến thuật và cân bằng.

### P2 — Chế độ phụ và meta-progression
1. Mini-game và puzzle dùng luật chơi biến đổi.
2. Survival/Endless với độ khó leo thang.
3. Shop, mở khóa Plant, nâng cấp bằng tài nguyên.
4. Nâng cấp vĩnh viễn kiểu Seed Packet nhưng dùng hệ thống tu luyện/linh căn riêng.
5. Nhiệm vụ ngày/tuần, nhật ký hành trình, thành tựu và phần thưởng.

### P3 — Hoàn thiện sản phẩm
1. Almanac có lore, animation, điểm mạnh/yếu và lịch sử mở khóa.
2. Vườn Linh Viên có thời gian phát triển, nhiều khu vực, chăm sóc và trang trí.
3. Art, VFX, UI, audio, boss animation và phản hồi chạm nguyên bản.
4. QA trên PC/mobile/Web, lưu trữ và kiểm tra hiệu năng.

## Lưu ý kỹ thuật

- Godot 4.2+ / GDScript tiếp tục là runtime. Python giữ vai trò validator và công cụ tạo nội dung. Van Hien/Prompt được dùng làm tham chiếu cho pipeline và chất lượng dữ liệu, không đưa web app hay backend không liên quan vào vòng lặp trận đấu.
- Các tính năng mới phải đi qua JSON validator, Godot import/parser, headless startup và Web export trong CI.
- CI không thể chứng minh độ vui, độ cân bằng hoặc toàn bộ gameplay. Sau CI vẫn cần mở game và kiểm tra tay theo checklist.
- Số lượng Plant/Zombie/level và trạng thái asset phải được cập nhật trong báo cáo sau mỗi đợt phát triển.
