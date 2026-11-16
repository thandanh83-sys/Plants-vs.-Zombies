# ============================================================
# VĂN ĐẠO: BÚT TRẬN — Plant.gd
# Vị trí: scripts/entities/Plant.gd
# Vai trò: Lớp cha trừu tượng (Abstract Base Class)
# Mục đích: Xử lý hành vi chung (nhận damage, chết), để class con
#           override _perform_action() cho hành động riêng.
# ============================================================
# KIẾN TRÚC:
#   Plant (abstract) ← File này
#   ├── ShooterPlant    (bắn đạn)
#   ├── ProducerPlant   (tạo Linh Khí)
#   ├── WallPlant       (chặn đường)
#   ├── ExplosivePlant  (nổ diện rộng)
#   └── SupportPlant    (buff/làm chậm)
# ============================================================
# TRIẾT LÝ:
# - Code 1 lần hành vi chung ở Plant, tất cả class con thừa hưởng.
# - Class con CHỈ override _perform_action() — không cần viết lại
#   logic nhận damage, chết, hiển thị HP bar.
# ============================================================

extends Node2D
class_name Plant
# ↑ `Node2D` để có position, sprite, z_index
# ↑ `class_name Plant` cho phép dùng type hint ở class con

# ============================================================
# SIGNALS
# ============================================================

# Phát khi cây bị trừ máu (để UI cập nhật HP bar)
signal health_changed(current: int, max_hp: int)

# Phát khi cây chết
signal died(plant: Plant)

# Phát khi cây thực hiện hành động (dùng cho animation/audio)
signal action_performed(plant: Plant)

# ============================================================
# BIẾN TRẠNG THÁI
# ============================================================

# Data của cây (từ PlantData resource)
var data: PlantData

# Máu hiện tại
var current_hp: int = 0

# Tile mà cây đang đứng (để gọi tile.remove_plant() khi chết)
var tile: Tile = null

# Timer tích lũy thời gian để thực hiện hành động
var _action_timer: float = 0.0

# Cây đã chết chưa (tránh die() gọi 2 lần)
var _is_dead: bool = false

# Cây đã sẵn sàng chưa (để tránh _process chạy trước khi initialize)
var _is_initialized: bool = false

# ============================================================
# CHILDREN NODES — Tự tạo trong _ready()
# ============================================================

# Thanh máu (hiển thị trên đầu cây)
var hp_bar_bg: ColorRect
var hp_bar_fill: ColorRect

# Sprite (sẽ thay bằng texture thật ở Đợt sau)
var body_visual: ColorRect

# ============================================================
# _ready() — Khởi tạo visual
# ============================================================
func _ready() -> void:
	# Chỉ tạo visual nếu chưa có data (đã initialize)
	if data == null:
		# Sẽ initialize() sau
		pass
	else:
		_build_visual()

# ============================================================
# INITIALIZE — Gọi sau khi instantiate
# ============================================================
# @param plant_data: PlantData Resource
# @param parent_tile: Tile mà cây đứng lên
# ============================================================
func initialize(plant_data: PlantData, parent_tile: Tile) -> void:
	data = plant_data
	tile = parent_tile
	current_hp = data.hp
	_action_timer = 0.0
	_is_dead = false
	_is_initialized = true
	
	# Đặt tên node cho dễ debug
	name = "Plant_" + data.id
	
	# Set vị trí = tâm tile
	if tile != null:
		position = Const.get_cell_center(tile.grid_pos)
	
	# Set z_index để cây nằm trên tile
	z_index = 1
	
	# Xây dựng visual (sprite, HP bar)
	_build_visual()
	
	# Debug log
	print("[Plant] Đã tạo: %s (%s) — HP: %d" % [data.name, data.title, current_hp])

# ============================================================
# BUILD VISUAL — Tạo sprite + HP bar
# ============================================================
func _build_visual() -> void:
	# Nếu đã có visual rồi → xóa để tạo lại
	if body_visual != null:
		body_visual.queue_free()
	if hp_bar_bg != null:
		hp_bar_bg.queue_free()
	if hp_bar_fill != null:
		hp_bar_fill.queue_free()
	
	# --- Body visual (placeholder) ---
	body_visual = ColorRect.new()
	body_visual.name = "BodyVisual"
	body_visual.color = data.color
	body_visual.size = Const.CELL_SIZE * 0.7  # Chiếm 70% ô
	body_visual.position = -body_visual.size * 0.5  # Căn giữa
	add_child(body_visual)
	
	# Thêm viền (border) cho đẹp
	# Dùng 1 ColorRect khác phía sau làm viền
	var border = ColorRect.new()
	border.name = "Border"
	border.color = Const.COLOR_JADE_DARK
	border.size = body_visual.size + Vector2(4, 4)
	border.position = -border.size * 0.5
	border.z_index = -1
	add_child(border)
	
	# --- HP Bar ---
	_create_hp_bar()

# ============================================================
# HP BAR — Thanh máu trên đầu cây
# ============================================================
func _create_hp_bar() -> void:
	# Background (nền đen)
	hp_bar_bg = ColorRect.new()
	hp_bar_bg.name = "HpBarBG"
	hp_bar_bg.color = Color(0.1, 0.1, 0.1, 0.7)
	hp_bar_bg.size = Vector2(60, 6)
	hp_bar_bg.position = Vector2(-30, -Const.CELL_SIZE.y * 0.45)
	add_child(hp_bar_bg)
	
	# Fill (phần máu còn lại, màu xanh)
	hp_bar_fill = ColorRect.new()
	hp_bar_fill.name = "HpBarFill"
	hp_bar_fill.color = Const.COLOR_JADE_LIGHT
	hp_bar_fill.size = Vector2(60, 6)
	hp_bar_fill.position = Vector2.ZERO
	hp_bar_bg.add_child(hp_bar_fill)
	
	# Ẩn HP bar nếu máu đầy (chỉ hiện khi bị đánh)
	_update_hp_bar_visibility()

# ============================================================
# _process() — Chạy mỗi frame
# ============================================================
func _process(delta: float) -> void:
	# Chỉ xử lý khi đã initialize và chưa chết
	if not _is_initialized or _is_dead:
		return
	
	# Cộng dồn thời gian
	_action_timer += delta
	
	# Đã đến lúc thực hiện hành động chưa?
	if _action_timer >= data.attack_speed:
		_action_timer = 0.0
		_perform_action()
		action_performed.emit(self)

# ============================================================
# _perform_action() — HÀM TRỪU TƯỢNG
# ============================================================
# Class con BẮT BUỘC override hàm này.
# Nếu không override → in warning.
# ============================================================
func _perform_action() -> void:
	push_warning("[Plant] _perform_action() chưa được override ở class: " + get_script().resource_path)

# ============================================================
# TAKE DAMAGE — Nhận sát thương
# ============================================================
func take_damage(amount: int) -> void:
	if _is_dead or amount <= 0:
		return
	
	current_hp -= amount
	
	# Kẹp về 0 (không âm)
	if current_hp < 0:
		current_hp = 0
	
	# Cập nhật visual
	_update_hp_bar()
	health_changed.emit(current_hp, data.hp)
	
	# Kiểm tra chết
	if current_hp <= 0:
		_die()

# ============================================================
# HEAL — Hồi máu (dùng cho Plant Food)
# ============================================================
func heal(amount: int) -> void:
	if _is_dead or amount <= 0:
		return
	
	current_hp = min(current_hp + amount, data.hp)
	_update_hp_bar()
	health_changed.emit(current_hp, data.hp)

# ============================================================
# _die() — Xử lý khi cây chết
# ============================================================
func _die() -> void:
	if _is_dead:
		return
	_is_dead = true
	
	print("[Plant] %s đã chết!" % data.name)
	
	# Xóa khỏi tile
	if tile != null and is_instance_valid(tile):
		tile.remove_plant()
	
	# Phát signal
	died.emit(self)
	
	# Hiệu ứng chết (mờ dần)
	_play_death_animation()

# ============================================================
# DEATH ANIMATION — Hiệu ứng chết
# ============================================================
func _play_death_animation() -> void:
	if body_visual == null:
		queue_free()
		return
	
	# Tween: Mờ dần và thu nhỏ trong 0.3s
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(body_visual, "modulate:a", 0.0, 0.3)
	tween.tween_property(body_visual, "scale", Vector2(0.5, 0.5), 0.3)
	
	# Đợi tween xong rồi xóa
	await tween.finished
	queue_free()

# ============================================================
# HP BAR UPDATE
# ============================================================
func _update_hp_bar() -> void:
	if hp_bar_fill == null or data == null:
		return
	
	# Tính % máu còn lại
	var ratio = float(current_hp) / float(data.hp)
	ratio = clampf(ratio, 0.0, 1.0)
	
	# Cập nhật chiều rộng fill
	hp_bar_fill.size.x = 60.0 * ratio
	
	# Đổi màu theo máu (xanh → vàng → đỏ)
	if ratio > 0.5:
		hp_bar_fill.color = Const.COLOR_JADE_LIGHT  # Xanh (>50%)
	elif ratio > 0.25:
		hp_bar_fill.color = Const.COLOR_GOLD        # Vàng (25-50%)
	else:
		hp_bar_fill.color = Const.COLOR_RED_LIGHT   # Đỏ (<25%)
	
	_update_hp_bar_visibility()

# ============================================================
# HP BAR VISIBILITY
# ============================================================
func _update_hp_bar_visibility() -> void:
	if hp_bar_bg == null:
		return
	
	# Chỉ hiện HP bar khi máu < 100%
	var show = current_hp < data.hp
	hp_bar_bg.visible = show

# ============================================================
# PLANT FOOD — Kỹ năng Thức Tỉnh (override ở class con)
# ============================================================
func activate_plant_food() -> void:
	# Mặc định không làm gì. Class con override nếu có skill.
	push_warning("[Plant] %s không có Plant Food skill." % data.name)

# ============================================================
# PUBLIC API
# ============================================================

# Lấy % máu còn lại (0.0 → 1.0)
func get_health_ratio() -> float:
	if data == null or data.hp <= 0:
		return 0.0
	return float(current_hp) / float(data.hp)

# Kiểm tra cây còn sống không
func is_alive() -> bool:
	return not _is_dead and current_hp > 0

# Lấy grid_pos của cây
func get_grid_pos() -> Vector2i:
	if tile == null:
		return Vector2i(-1, -1)
	return tile.grid_pos

# ============================================================
# DEBUG
# ============================================================
func _to_string() -> String:
	if data == null:
		return "Plant(no data)"
	return "Plant(%s, hp=%d/%d)" % [data.name, current_hp, data.hp]