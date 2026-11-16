# ============================================================
# VĂN ĐẠO: BÚT TRẬN — WaveManager.gd
# Vị trí: scripts/managers/WaveManager.gd
# Vai trò: Sinh quái theo đợt (waves.json)
# ============================================================

extends Node
class_name WaveManager

# ============================================================
# SIGNALS
# ============================================================
signal wave_started(wave_id: String)
signal wave_completed(wave_id: String)
signal all_waves_completed

# ============================================================
# BIẾN
# ============================================================
var _enemy_queue: Array = []       # Danh sách quái chờ sinh
var _spawn_timer: float = 0.0       # Đồng hồ sinh quái
var _is_spawning: bool = false
var _enemy_scene: PackedScene = null

# ============================================================
# _ready()
# ============================================================
func _ready() -> void:
	# Load Enemy scene
	if ResourceLoader.exists("res://scenes/entities/Enemy.tscn"):
		_enemy_scene = load("res://scenes/entities/Enemy.tscn")
	
	# Kết nối với GameManager
	if GameManager:
		GameManager.game_started.connect(_on_game_started)

# ============================================================
# KHI GAME BẮT ĐẦU → Sinh wave đầu tiên
# ============================================================
func _on_game_started() -> void:
	_start_next_wave()

# ============================================================
# BẮT ĐẦU WAVE MỚI
# ============================================================
func _start_next_wave() -> void:
	var wave_id = GameManager.get_next_wave_id()
	
	# Hết wave → thắng
	if wave_id == "":
		all_waves_completed.emit()
		GameManager.on_level_won()
		return
	
	var wave_data = GameData.get_wave(wave_id)
	if wave_data.is_empty():
		push_error("[WaveManager] Không tìm thấy wave: " + wave_id)
		return
	
	_prepare_wave(wave_data)
	wave_started.emit(wave_id)
	_is_spawning = true
	
	print("[WaveManager] Bắt đầu: %s" % wave_data.get("name", wave_id))

# ============================================================
# CHUẨN BỊ HÀNG ĐỢI QUÁI
# ============================================================
func _prepare_wave(wave_data: Dictionary) -> void:
	_enemy_queue.clear()
	_spawn_timer = 0.0
	
	var enemies = wave_data.get("enemies", [])
	var delay_acc = 0.0
	
	for group in enemies:
		delay_acc += group.get("delay", 0.0)
		var type = group.get("type", "")
		var count = group.get("count", 1)
		
		for i in range(count):
			_enemy_queue.append({
				"type": type,
				"time": delay_acc + i * 1.5
			})
	
	# Sắp xếp theo thời gian
	_enemy_queue.sort_custom(func(a, b): return a.time < b.time)

# ============================================================
# _process() — Sinh quái theo lịch
# ============================================================
func _process(delta: float) -> void:
	if not _is_spawning:
		return
	
	_spawn_timer += delta
	
	# Sinh tất cả quái đã đến giờ
	while _enemy_queue.size() > 0 and _spawn_timer >= _enemy_queue[0].time:
		var enemy_info = _enemy_queue.pop_front()
		_spawn_enemy(enemy_info.type)
	
	# Hết hàng đợi → chờ wave tiếp theo
	if _enemy_queue.size() == 0:
		_is_spawning = false
		_wait_for_next_wave()

# ============================================================
# SINH 1 QUÁI
# ============================================================
func _spawn_enemy(type: String) -> void:
	if _enemy_scene == null:
		push_warning("[WaveManager] Enemy scene chưa có")
		return
	
	# Lấy data
	var enemy_data = GameData.get_enemy(type)
	if enemy_data.is_empty():
		return
	
	# Tạo instance
	var enemy = _enemy_scene.instantiate()
	
	# Chọn hàng ngẫu nhiên
	var lane = randi() % Const.GRID_ROWS
	
	# Đặt vị trí: mép phải, đúng hàng
	enemy.position = Vector2(1100, Const.get_cell_center(Vector2i(0, lane)).y)
	
	# Setup
	if enemy.has_method("setup"):
		enemy.setup(enemy_data, lane)
	
	get_parent().add_child(enemy)

# ============================================================
# CHỜ WAVE TIẾP THEO
# ============================================================
func _wait_for_next_wave() -> void:
	var wave_id = GameManager.get_next_wave_id()
	var wave_data = GameData.get_wave(wave_id)
	var delay = wave_data.get("delay_before_next", 8.0)
	
	wave_completed.emit(wave_id)
	GameManager.advance_wave()
	
	print("[WaveManager] Wave xong. Chờ %.1fs..." % delay)
	await get_tree().create_timer(delay).timeout
	_start_next_wave()