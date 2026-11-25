# Audio

Game không bắt buộc phải có file âm thanh để chạy. `core/AudioManager.gd` tự tạo âm thanh tổng hợp ngắn khi chưa tìm thấy OGG.

Có thể thay âm thanh tổng hợp bằng các file OGG sau:
- `plant.ogg`
- `collect.ogg`
- `explosion.ogg`
- `win.ogg`
- `lose.ogg`

Đặt các file trong thư mục này. `AudioManager.play("plant")` sẽ ưu tiên `plant.ogg` nếu file tồn tại.
