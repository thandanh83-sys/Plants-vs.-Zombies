# ============================================================
# VĂN ĐẠO: BÚT TRẬN — Bullet.gd
# Vị trí: scripts/entities/Bullet.gd
# Vai trò: Đạn mực bay từ phải sang
# ============================================================

extends Area2D
class_name Bullet

# Tốc độ bay (pixel/giây)
var speed: float = 400.0

# Sát thương khi trúng quái
var damage: int = 20

# ============================================================
# SETUP — Gọi sau khi instantiate
# ============================================================
func setup(dmg: int, _lane: int) -> void:
	damage = dmg

# ============================================================
# _ready() — Kết nối va chạm
# ============================================================
func _ready() -> void:
	# z_index cao để đè lên cây
	z_index = 3
	
	# Kết nối signal khi có Area2D khác chạm vào
	area_entered.connect(_on_area_entered)

# ============================================================
# _process() — Bay sang phải
# ============================================================
func _process(delta: float) -> void:
	position.x += speed * delta
	
	# Ra khỏi màn hình → tự xóa
	if position.x > 1400:
		queue_free()

# ============================================================
# XỬ LÝ VA CHẠM
# ============================================================
func _on_area_entered(area: Area2D) -> void:
	# Chỉ quan tâm đến quái
	if not area.is_in_group("enemies"):
		return
	
	# Gây sát thương
	if area.has_method("take_damage"):
		area.take_damage(damage)
	
	# Phát âm thanh
	if AudioManager:
		AudioManager.play_hit()
	
	# Xóa đạn
	queue_free()