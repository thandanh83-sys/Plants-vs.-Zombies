# Danh sách tài nguyên hình ảnh

Trạng thái bên dưới được đối chiếu với các file thực tế trong nhánh demo. Mục chưa đánh dấu là chưa được xác minh hoặc chưa có trong repository; không xem đó là asset đã hoàn tất.

## Plant — `assets/plants/`

- [ ] `da-quang-nam.png` — Dạ Quang Nấm
- [ ] `dia-loi-phu.png` — Địa Lôi Phù
- [ ] `dia-thich.png` — Địa Thích
- [ ] `doc-vu-nam.png` — Độc Vụ Nấm
- [ ] `han-bang-tien.png` — Hàn Băng Tiễn
- [ ] `hoa-long-phu.png` — Hỏa Long Phù
- [x] `hong-lien-no.png` — Hồng Liên Nổ
- [ ] `kim-cang-dai.png` — Kim Cang Đài
- [ ] `kim-cang-thu.png` — Kim Cang Thủ
- [ ] `lien-diep.png` — Liên Diệp
- [ ] `liet-hoa-tru.png` — Liệt Hỏa Trụ
- [ ] `nguyet-quang-nam.png` — Nguyệt Quang Nấm
- [ ] `nhat-nguyet-thao.png` — Nhật Nguyệt Thảo
- [ ] `song-tien-truc.png` — Song Tiễn Trúc
- [ ] `tam-tien-truc.png` — Tam Tiễn Trúc
- [ ] `thuc-nhan-hoa.png` — Thực Nhân Hoa
- [ ] `thuy-nam.png` — Thủy Nấm
- [ ] `tran-hon-phu.png` — Trấn Hồn Phù
- [ ] `tran-son-an.png` — Trấn Sơn Ấn
- [x] `truc-tien.png` — Trúc Tiễn

## Zombie — `assets/zombies/`

- [ ] `cuong-thi-cam-bao.png` — Cương Thi Cầm Báo
- [ ] `cuong-thi-cam-co.png` — Cương Thi Cầm Cờ
- [ ] `cuong-thi-cam-sao.png` — Cương Thi Cầm Sào
- [ ] `cuong-thi-cau-thu.png` — Cương Thi Cầu Thủ
- [ ] `cuong-thi-doi-xo.png` — Cương Thi Đội Xô
- [ ] `cuong-thi-khinh-khi-cau.png` — Cương Thi Khinh Khí Cầu
- [ ] `cuong-thi-nhay-phu.png` — Cương Thi Nhảy Phụ
- [x] `cuong-thi-non.png` — Cương Thi Đội Nón
- [x] `cuong-thi-thuong.png` — Cương Thi Thường
- [ ] `cuong-thi-vu-cong.png` — Cương Thi Vũ Công

## Ảnh thẻ — `assets/ui/seed-packet/`

- [x] `truc-tien.png` — ảnh thẻ Trúc Tiễn
- [ ] `hong-lien-no.png` — ảnh thẻ Hồng Liên Nổ; hiện thẻ dùng sprite Plant làm phương án dự phòng

## Nền màn — `assets/backgrounds/`

- [ ] `thu-vien-co.png` — Thư Viện Cổ; màn demo hiện dùng nền mặc định
- [ ] `rung-truc-dem.png` — Rừng Trúc Đêm
- [ ] `ho-sen-tinh-do.png` — Hồ Sen Tịnh Độ
- [ ] `nui-suong-mu.png` — Núi Sương Mù
- [ ] `dinh-con-lon.png` — Đỉnh Côn Lôn

## Tài nguyên UI dùng chung — `assets/ui/`

- [x] `logo.png`
- [x] `linh-khi.png`

## Quy cách

- Plant/Zombie: PNG nền trong suốt, một nhân vật mỗi file, căn giữa và có khoảng trống quanh viền.
- Ảnh thẻ: cùng tỷ lệ và ngôn ngữ tạo hình trong cùng bộ; không chứa giá, tên hoặc trạng thái vì game render chữ động.
- Background: PNG ngang, không chứa nhân vật, lưới hoặc UI.
- Giữ ID file đồng nhất với JSON; nếu đổi vị trí, cập nhật trường `sprite`, `card_sprite` hoặc `background` tương ứng.
