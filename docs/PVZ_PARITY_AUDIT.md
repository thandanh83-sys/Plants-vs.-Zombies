# Đối chiếu gameplay — Vạn Giới Linh Viên với Plants vs. Zombies 1 và 2

**Nhánh được kiểm tra:** `feat/pvz-core-gameplay-parity`  
**PR:** #13 — bản demo Thư Viện Cổ  
**Phạm vi đối chiếu:** source GDScript, JSON, dữ liệu level, tài liệu và asset trong repository. Đây là đối chiếu source; không phải xác nhận đã chơi thủ công toàn bộ game.

## 1. Mốc tham chiếu

### Plants vs. Zombies 1

Trang sản phẩm chính thức trên Steam mô tả 5 chế độ chính: Adventure, Mini-Games, Puzzle, Survival và Zen Garden; Adventure có 50 màn qua ngày, đêm, sương mù, hồ bơi và mái nhà. Trang này cũng liệt kê Almanac, cửa hàng Crazy Dave, 26 loại Zombie và 49 loại Plant/perennial trong bản được mô tả.

Nguồn: https://store.steampowered.com/app/3590/Plants_vs_Zombies/

### Plants vs. Zombies 2

Trang tính năng chính thức của EA mô tả chiến dịch qua nhiều thế giới, hàng trăm Plant/Zombie, Seed Packets để tăng cấp Plant, Arena/League, Endless Zones, mini-game, sự kiện Piñata Party và nhiệm vụ Travel Log.

Thông cáo ra mắt của EA giải thích Plant Food có thể rơi từ Zombie phát sáng và tạo hiệu ứng tăng sức mạnh tạm thời; trò chơi cũng có power-up điều khiển trực tiếp Zombie bằng thao tác cảm ứng, nhiệm vụ phụ và Challenge Zones.

Nguồn:
- https://www.ea.com/games/plants-vs-zombies/plants-vs-zombies-2/features
- https://news.ea.com/press-releases/press-releases-details/2013/PopCap-Launches-Plants-vs.-Zombies-2-Worldwide/default.aspx

**Cách áp dụng tham chiếu:** học hỏi vòng chơi, vai trò hệ thống và nhịp độ chiến thuật; giữ nguyên chủ đề tiên đạo, ID, nhân vật, hình ảnh, âm thanh, cốt truyện và code nguyên bản của Vạn Giới Linh Viên. Không sao chép asset hoặc mã nguồn độc quyền của hai trò chơi tham chiếu.

## 2. Phạm vi thực tế của repository

Cần phân biệt ba mức:

1. **Có trong code/data:** hệ thống hoặc cấu hình đã tồn tại trong source.
2. **Có trong lát cắt demo:** hệ thống được dùng bởi màn Thư Viện Cổ của PR #13.
3. **Đã xác minh bằng chơi thực tế:** chỉ được xác nhận sau khi mở game và thực hiện thao tác thủ công. CI headless/export không thể chứng minh trải nghiệm gameplay.

PR #13 đang khóa lát cắt demo ở:
- 1 màn: **Thư Viện Cổ**.
- 2 Plant: **Trúc Tiễn**, **Hồng Liên Nổ**.
- 2 Zombie: **Cương Thi Thường**, **Cương Thi Đội Nón**.
- 3 wave có số lượng lần lượt 5, 8 và 10 Zombie.
- 2 ô chọn Plant, 250 Linh Khí và 1 lượt Linh Đan lúc bắt đầu.

Repository có dữ liệu level 1–5 và nhiều JSON Plant/Zombie hơn phạm vi demo. Tuy nhiên, điều đó **không đồng nghĩa** cả năm màn hoặc toàn bộ danh sách nhân vật đã được kiểm thử gameplay ở PR này.

## 3. Bảng đối chiếu theo hệ thống

| Hệ thống | PvZ 1 | PvZ 2 | Vạn Giới Linh Viên hiện tại | Đánh giá |
|---|---|---|---|---|
| Sân theo làn và ô | Cốt lõi toàn bộ gameplay | Kế thừa cốt lõi này | GridManager có lưới 5 hàng × 9 cột, đặt entity theo ô | Đã có nền tảng tương đương |
| Chọn đội hình | Chọn các Seed Packet trước màn | Chọn đội hình trước màn | Có màn chọn đội hình; level demo giới hạn đúng 2 thẻ | Đã có bản cơ bản |
| Tài nguyên khi chơi | Thu thập Sun và cân đối chi phí Plant | Kế thừa Sun economy, thêm các hệ thống phụ | Demo bắt đầu 250 Linh Khí; cấu hình rơi 25 Linh Khí mỗi 8 giây; giá hai Plant là 100 và 150 | Đã có vòng kinh tế cơ bản; demo chưa có Plant sản xuất tài nguyên |
| Hồi chiêu Plant | Có thời gian hồi chiêu Seed Packet | Tiếp tục sử dụng cooldown và nâng cấp Plant | CardManager bắt đầu hồi chiêu sau khi trồng; thời gian đọc từ JSON | Đã có, cần cân bằng bằng chơi thử |
| Plant và vai trò | Nhiều vai trò: tấn công, phòng thủ, tạo Sun, hiệu ứng | Mở rộng roster và biến thể kỹ năng | Demo chỉ có một Plant bắn và một Plant nổ; dữ liệu toàn repository có nhiều loại hơn | Vòng chơi demo còn ít lựa chọn chiến thuật |
| Zombie | Nhiều loại và cơ chế gây áp lực khác nhau | Mở rộng rất nhiều loại và tương tác đặc biệt | Demo có Zombie thường và Zombie có giáp; behavior có nền tảng xử lý giáp, nhảy, bay, triệu hồi và hiệu ứng trạng thái qua dữ liệu | Đủ để thử vòng chơi cơ bản; chưa đủ độ đa dạng |
| Wave | Tăng áp lực theo tiến trình màn | Bổ sung màn thử thách và Endless | WaveManager đọc số lượng, khoảng cách spawn, lane, thời gian nghỉ và boss flag từ JSON | Đã có hệ wave; demo mới có 3 wave tuyến tính |
| Plant Food | Không có hệ thống Plant Food của PvZ2 | Plant Food tạo hiệu ứng riêng cho từng Plant; bản gốc có thể rơi từ Zombie phát sáng | Demo có 1 lượt ban đầu, Trúc Tiễn bắn loạt và Hồng Liên Nổ phá hủy dọc lane | Có hiệu ứng riêng, nhưng chưa có cơ chế Zombie rơi Linh Đan |
| Power-up cảm ứng | Không phải hệ thống đặc trưng của bản đầu | Có thao tác trực tiếp lên Zombie bằng cử chỉ | Có click/chạm để chọn và đặt cây, nhưng không có bộ power-up cảm ứng tác động trực tiếp lên Zombie | Chưa có |
| Địa hình/môi trường | Ngày, đêm, sương mù, hồ bơi, mái nhà | Các thế giới có bối cảnh và luật môi trường riêng | GridManager xử lý nước, yêu cầu bệ, mộ, sương và cách vẽ mái; level 2–5 có JSON môi trường | Có một phần logic; art và cơ chế riêng từng môi trường chưa hoàn thiện |
| Lawn Mower | Công cụ cứu nguy một lần theo lane | Kế thừa các cơ chế cứu nguy theo level | Có LawnMowerBehavior, tự kích hoạt khi Zombie đến ngưỡng và chạy qua lane | Đã có bản cơ bản |
| Almanac | Tra cứu Plant/Zombie và thông tin | Tiếp tục mở rộng danh mục | Có màn tra cứu đọc tên, mô tả, chỉ số, kỹ năng và sprite từ JSON | Đã có bản tra cứu cơ bản; thiếu lore/hoạt ảnh/nội dung biên tập sâu |
| Zen Garden | Chế độ phụ thư giãn | Có nội dung phụ và tiến trình bổ sung | Có 3 chậu; chăm sóc đúng công cụ tăng stage và nhận xu ngay | Mới là mô phỏng đơn giản, chưa có tăng trưởng theo thời gian và hệ vật phẩm |
| Bản đồ/chiến dịch | Adventure 50 màn trong bản Steam được tham chiếu | Nhiều thế giới và hàng trăm màn theo trang EA | Có 5 file level và mở khóa tuần tự; PR hiện chỉ tập trung màn đầu | Khung tiến trình có, chiều sâu chiến dịch còn rất thấp |
| Shop và nâng cấp Plant | Có cửa hàng Crazy Dave và mua vật phẩm | Seed Packets dùng để nâng cấp vĩnh viễn sức mạnh Plant | SaveSystem có coins, unlock ID và lựa chọn đội hình; chưa có shop loop hoặc hệ nâng cấp Plant hoàn chỉnh | Chưa có |
| Mini-game/Puzzle/Survival | Là các chế độ chính thức bên cạnh Adventure | Có mini-game, Challenge Zones và Endless Zones | Chưa có chế độ chơi độc lập | Chưa có |
| Quest/Arena/Event | Không phải trọng tâm bản gốc | Có Travel Log, Arena/League, Piñata Party và sự kiện | Chưa có nhiệm vụ, bảng xếp hạng, sự kiện định kỳ hoặc Endless | Chưa có |
| Boss | Có các màn/cơ chế kết thúc chiến dịch | Boss cuối thế giới là một cột mốc chiến dịch | Level 5 có boss flag và cơ chế nhân hệ số HP/sát thương | Mới ở mức tăng chỉ số; chưa có boss nhiều pha/pattern |
| Lưu tiến trình | Có tiến trình màn và nội dung mở khóa | Có tiến trình chiến dịch và nâng cấp Plant | SaveSystem lưu level mở khóa, màn hoàn thành, best sun, coin, Plant đã mở, đội hình, vườn và tutorial | Có khung lưu; thiếu nhiều vòng tiêu/xài tài nguyên và meta-progression |
| Trình bày/asset | Có bộ hình, hoạt ảnh, âm thanh hoàn chỉnh | Có nhiều nội dung hình ảnh và VFX hơn | 4 sprite demo và một số UI asset đã có; ảnh thẻ Hồng Liên Nổ và nền Thư Viện Cổ chưa có | Còn khoảng cách lớn về độ hoàn thiện hình/âm thanh |

## 4. Kết luận theo hai phiên bản tham chiếu

### So với PvZ 1

Vạn Giới Linh Viên đã có khung của vòng chơi PvZ cổ điển: chọn đội hình, thu thập tài nguyên, đặt Plant trên lưới, quản lý cooldown, chống Zombie theo lane và kết thúc màn khi thắng/thua. Máy cắt cỏ, Almanac, bản đồ level và Vườn Thiền cũng là những hệ thống có quan hệ chức năng với các thành phần của PvZ1.

Khoảng cách chính không nằm ở việc thiếu thêm một vài Plant/Zombie, mà là **thiếu độ dày của chiến dịch và các chế độ chơi**. PvZ1 được giới thiệu với 5 mode và 50 màn Adventure; Vạn Giới Linh Viên hiện có một lát cắt demo được ưu tiên kiểm tra. Các địa hình trong project mới có logic nền tảng và chưa có đủ art/cơ chế riêng để mang lại chất lượng như các môi trường hoàn chỉnh của PvZ1.

### So với PvZ 2

Vạn Giới Linh Viên đã có một dạng Linh Đan/Plant Food với hiệu ứng riêng từng Plant. Tuy nhiên, đây chưa phải vòng Plant Food giống PvZ2: chưa có Zombie phát sáng làm nguồn rơi vật phẩm, chưa có nhịp thu thập và quyết định dùng Linh Đan trong suốt wave, và chưa có power-up cảm ứng trực tiếp lên Zombie.

Quan trọng hơn, **Seed Packet trong UI hiện là thẻ chọn Plant, không phải hệ nâng cấp Plant bằng Seed Packets của PvZ2**. Project có dữ liệu coins và Plant unlock, nhưng chưa có cửa hàng, yêu cầu tài nguyên, nâng cấp chỉ số/kỹ năng và vòng tiêu hao phần thưởng. World map hiện chỉ là danh sách level tuyến tính, chưa có lớp quest, Arena, event, Endless hoặc tiến trình nhiều thế giới.

## 5. Các việc nên ưu tiên

### P0 — Chốt chất lượng vòng chơi demo

1. Chơi thử trọn ba wave và ghi lại thời gian hoàn thành, lượng Linh Khí thu được, số Plant có thể đặt và tỉ lệ sống sót.
2. Kiểm tra Hồng Liên Nổ ở tình huống nhiều Zombie; xác minh tầm kích nổ, sát thương và thời điểm tự hủy.
3. Kiểm tra hai hiệu ứng Linh Đan, số lượt tiêu hao và phản hồi khi chọn sai mục tiêu.
4. Kiểm tra thắng/thua, chơi lại, pause, tốc độ, lưu và tải sau khi thoát.
5. Hoàn thiện ảnh thẻ Hồng Liên Nổ và nền Thư Viện Cổ; không khai báo đường dẫn asset chưa có.

### P1 — Nâng độ sâu gameplay

1. Thêm Plant có vai trò sản xuất Linh Khí và phòng thủ để người chơi phải lựa chọn chiến thuật thay vì chỉ có bắn/nổ.
2. Tạo thêm loại Zombie có cơ chế khắc chế rõ ràng; tăng áp lực qua phối hợp loại Zombie, lane và nhịp wave, không chỉ tăng HP.
3. Thiết kế nguồn Linh Đan trong trận và giới hạn/tần suất rơi sao cho người chơi phải chọn thời điểm sử dụng.
4. Làm rõ từng môi trường: đêm, nước, sương, mộ và mái phải thay đổi cách bố trí hoặc chiến thuật; không chỉ đổi màu nền.

### P2 — Tiến trình dài hạn theo tinh thần PvZ2

1. Shop và phần thưởng dùng coins/Linh Thạch theo economy được thiết kế rõ.
2. Hệ nâng cấp Plant lâu dài với dữ liệu riêng, không lẫn với thẻ chọn Plant trong trận.
3. Mở khóa vùng/màn theo điều kiện, phần thưởng và các thử thách cuối vùng.
4. Mini-game, Puzzle và Survival/Endless.

### P3 — Nội dung mở rộng

1. Nhiệm vụ, thành tựu, sự kiện và chế độ thi đấu điểm nếu thực sự phù hợp với hướng phát triển.
2. Vườn Linh Viên có tăng trưởng theo thời gian, chăm sóc, vật phẩm và trang trí.
3. Almanac có lore, điểm mạnh/yếu và hoạt ảnh nguyên bản.
4. Hoàn thiện VFX, animation, audio, UI và QA đa thiết bị.

## 6. Ranh giới kỹ thuật

- Godot/GDScript là runtime; JSON là nguồn cấu hình Plant, Zombie, level và setting.
- `DataLoader` tải và kiểm tra dữ liệu; `EntityFactory` hỗ trợ `behavior_script`; `GridManager` quản lý ô/địa hình; `WaveManager` điều phối wave; `GameManager` sở hữu trạng thái và tài nguyên.
- `CardManager` quản lý UI thẻ, khả năng chi trả và hồi chiêu; nó không nên sở hữu logic trừ Linh Khí hoặc đặt Plant.
- `Main.gd` hiện vẫn là controller lớn cho giao diện, input và luồng đặt Plant. Tách UI controller và level controller nên là đợt refactor riêng sau khi demo ổn định.
- Không đưa mã nguồn Unity, dịch vụ web hoặc backend không cần thiết vào runtime Godot.
- CI có thể kiểm tra unit tests, JSON, import/parser, khởi động headless và export Web; CI không xác minh được độ vui, cân bằng hoặc việc toàn bộ thao tác chạy đúng khi chơi thực tế.

**Kết luận:** Vạn Giới Linh Viên hiện là một prototype có vòng chơi cơ bản chịu ảnh hưởng thể loại của PvZ1 và một phần ý tưởng Plant Food từ PvZ2. Chưa thể gọi là tương đương về độ rộng hoặc độ hoàn thiện với PvZ1/PvZ2. Hướng phù hợp là hoàn thiện lát cắt demo trước, sau đó xây campaign/meta-progression trên kiến trúc JSON hiện có.
