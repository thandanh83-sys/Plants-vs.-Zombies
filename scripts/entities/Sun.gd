# ============================================================
# VĂN ĐẠO: BÚT TRẬN — Sun.gd
# Vị trí: scripts/entities/Sun.gd
# Vai trò: Linh Khí (tài nguyên) — Click để nhặt
# ============================================================

extends Area2D
class_name Sun

# Giá trị cộng khi nhặt
var value: int = 25

# Tốc độ rơi (pixel/giây)
var fall_speed: float = 80.0

# Có đang rơi từ trời không?
var is_falling: bool = false

# Vị trí y đích (dừng rơi)
var target_y: float = 0.0

# ============================================================
# SETUP — Gọi sau khi instantiate
# ============================================================
# @param amount: giá trị Linh Khí
# @param falls_from_sky: có rơi từ trời không
# ============================================================
func setup(amount: int, falls_from_sky: bool) -> void:
	value = amount
	is_falling = falls_from_sky

# ============================================================
# _ready()
# ============================================================
func _ready() -> void:
	# z_index cao nhất để luôn click được
	z_index = 10
	
	# Kết nối click
	input_event.connect(_on_input_event)
	
	# Nếu rơi từ trời → đặt target_y
	if is_falling:
		target_y = position.y + randf_range(100, 400)
	
	# Tự xóa sau 8 giây nếu không nhặt
	get_tree().create_timer(Const.SUN_LIFETIME).timeout.connect(_auto_destroy)

# ============================================================
# _process() — Rơi xuống
# ============================================================
func _process(delta: float) -> void:
	if is_falling and position.y < target_y:
		position.y += fall_speed * delta

# ============================================================
# XỬ LÝ CLICK
# ============================================================
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_collect()

# ============================================================
# NHẶT LINH KHÍ
# ============================================================
func _collect() -> void:
	GameManager.add_sun(value)
	
	if AudioManager:
		AudioManager.play_sun_pickup()
	
	queue_free()

# ============================================================
# TỰ XÓA SAU 8 GIÂY
# ============================================================
func _auto_destroy() -> void:
	if is_instance_valid(self):
		queue_free()