# ============================================================
# VĂN ĐẠO: BÚT TRẬN — GameData.gd
# Vị trí: scripts/autoload/GameData.gd
# Vai trò: Autoload Singleton (chạy xuyên suốt game)
# Mục đích: Load toàn bộ dữ liệu JSON, cung cấp API truy vấn
# ============================================================
# TRIẾT LÝ:
# - CHỈ ĐỌC dữ liệu (read-only). Không bao giờ ghi đè JSON.
# - Cache kết quả vào Dictionary để truy vấn O(1).
# - Nếu load lỗi → fallback về Dictionary rỗng, không crash game.
# ============================================================

extends Node

# ------------------------------------------------------------
# SIGNAL — Phát tín hiệu khi load xong
# ------------------------------------------------------------
# Các scene khác có thể kết nối vào signal này để biết
# khi nào dữ liệu đã sẵn sàng (tránh race condition).
signal data_loaded

# ------------------------------------------------------------
# BIẾN LƯU TRỮ DỮ LIỆU
# ------------------------------------------------------------
# Sử dụng Dictionary với key = id của đối tượng
# VD: plants["nguyen-du"] = { toàn bộ data cây Nguyễn Du }
# ------------------------------------------------------------

# Dictionary: id → data của cây
var plants: Dictionary = {}

# Dictionary: id → data của quái
var enemies: Dictionary = {}

# Dictionary: id → data của wave
var waves: Dictionary = {}

# Dictionary: id → data của level
var levels: Dictionary = {}

# Dictionary config chung (difficulty_curve, spawn_interval...)
var plants_config: Dictionary = {}
var enemies_config: Dictionary = {}
var waves_config: Dictionary = {}

# Trạng thái load
var is_loaded: bool = false

# ------------------------------------------------------------
# HÀM _ready() — Chạy 1 LẦN khi game khởi động
# ------------------------------------------------------------
func _ready() -> void:
	print("[GameData] Bắt đầu load dữ liệu...")
	_load_all_data()
	is_loaded = true
	_print_summary()
	data_loaded.emit()

# ------------------------------------------------------------
# HÀM LOAD TOÀN BỘ DỮ LIỆU
# ------------------------------------------------------------
func _load_all_data() -> void:
	# Load từng file, nếu lỗi thì dùng Dictionary rỗng
	_load_plants()
	_load_enemies()
	_load_waves()
	_load_levels()

# ------------------------------------------------------------
# LOAD PLANTS (Cây)
# ------------------------------------------------------------
func _load_plants() -> void:
	var data = _read_json_file("res://data/plants.json")
	if data.is_empty():
		push_error("[GameData] Không load được plants.json")
		return
	
	# data["plants"] là Array, cần chuyển thành Dictionary keyed by id
	var plants_array: Array = data.get("plants", [])
	for plant_data in plants_array:
		if plant_data is Dictionary and plant_data.has("id"):
			plants[plant_data["id"]] = plant_data
	
	# Lưu config riêng (nếu có)
	plants_config = data.get("config", {})

# ------------------------------------------------------------
# LOAD ENEMIES (Quái)
# ------------------------------------------------------------
func _load_enemies() -> void:
	var data = _read_json_file("res://data/enemies.json")
	if data.is_empty():
		push_error("[GameData] Không load được enemies.json")
		return
	
	var enemies_array: Array = data.get("enemies", [])
	for enemy_data in enemies_array:
		if enemy_data is Dictionary and enemy_data.has("id"):
			enemies[enemy_data["id"]] = enemy_data
	
	enemies_config = data.get("config", {})

# ------------------------------------------------------------
# LOAD WAVES (Sóng quái)
# ------------------------------------------------------------
func _load_waves() -> void:
	var data = _read_json_file("res://data/waves.json")
	if data.is_empty():
		push_error("[GameData] Không load được waves.json")
		return
	
	var waves_array: Array = data.get("waves", [])
	for wave_data in waves_array:
		if wave_data is Dictionary and wave_data.has("id"):
			waves[wave_data["id"]] = wave_data
	
	waves_config = data.get("config", {})

# ------------------------------------------------------------
# LOAD LEVELS (Màn chơi)
# ------------------------------------------------------------
func _load_levels() -> void:
	var data = _read_json_file("res://data/levels.json")
	if data.is_empty():
		push_error("[GameData] Không load được levels.json")
		return
	
	var levels_array: Array = data.get("levels", [])
	for level_data in levels_array:
		if level_data is Dictionary and level_data.has("id"):
			levels[level_data["id"]] = level_data

# ------------------------------------------------------------
# HÀM HELPER — Đọc file JSON
# ------------------------------------------------------------
# Trả về Dictionary. Nếu lỗi → trả về Dictionary rỗng.
# ------------------------------------------------------------
func _read_json_file(path: String) -> Dictionary:
	# Kiểm tra file tồn tại không
	if not FileAccess.file_exists(path):
		push_error("[GameData] File không tồn tại: " + path)
		return {}
	
	# Mở file
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[GameData] Không mở được file: " + path)
		return {}
	
	# Đọc toàn bộ text
	var content = file.get_as_text()
	file.close()
	
	# Parse JSON
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		push_error("[GameData] Lỗi parse JSON ở %s (dòng %d): %s" % [
			path, json.get_error_line(), json.get_error_message()
		])
		return {}
	
	# Kiểm tra kiểu dữ liệu
	var data = json.data
	if not data is Dictionary:
		push_error("[GameData] JSON không phải Dictionary: " + path)
		return {}
	
	return data

# ============================================================
# PUBLIC API — Truy vấn dữ liệu
# ============================================================
# Các hàm dưới đây là "giao diện công khai" cho GameManager
# và các scene khác sử dụng.
# ============================================================

# ------------------------------------------------------------
# Lấy data của một cây theo id
# ------------------------------------------------------------
func get_plant(plant_id: String) -> Dictionary:
	if not plants.has(plant_id):
		push_warning("[GameData] Không tìm thấy cây: " + plant_id)
		return {}
	return plants[plant_id]

# ------------------------------------------------------------
# Lấy data của một quái theo id
# ------------------------------------------------------------
func get_enemy(enemy_id: String) -> Dictionary:
	if not enemies.has(enemy_id):
		push_warning("[GameData] Không tìm thấy quái: " + enemy_id)
		return {}
	return enemies[enemy_id]

# ------------------------------------------------------------
# Lấy data của một wave theo id
# ------------------------------------------------------------
func get_wave(wave_id: String) -> Dictionary:
	if not waves.has(wave_id):
		push_warning("[GameData] Không tìm thấy wave: " + wave_id)
		return {}
	return waves[wave_id]

# ------------------------------------------------------------
# Lấy data của một level theo id
# ------------------------------------------------------------
func get_level(level_id: String) -> Dictionary:
	if not levels.has(level_id):
		push_warning("[GameData] Không tìm thấy level: " + level_id)
		return {}
	return levels[level_id]

# ------------------------------------------------------------
# Lấy tất cả cây có sẵn trong một màn
# ------------------------------------------------------------
# Trả về Array[Dictionary] — danh sách data các cây
func get_plants_for_level(level_id: String) -> Array:
	var level = get_level(level_id)
	if level.is_empty():
		return []
	
	var available: Array = []
	var plant_ids: Array = level.get("available_plants", [])
	for plant_id in plant_ids:
		var plant = get_plant(plant_id)
		if not plant.is_empty():
			available.append(plant)
	return available

# ------------------------------------------------------------
# Lấy danh sách wave ID của một màn
# ------------------------------------------------------------
func get_waves_for_level(level_id: String) -> Array:
	var level = get_level(level_id)
	return level.get("waves", [])

# ------------------------------------------------------------
# Lấy toàn bộ ID của tất cả cây (dùng cho debug)
# ------------------------------------------------------------
func get_all_plant_ids() -> Array:
	return plants.keys()

# ------------------------------------------------------------
# Lấy toàn bộ ID của tất cả level (dùng cho menu chọn màn)
# ------------------------------------------------------------
func get_all_level_ids() -> Array:
	return levels.keys()

# ------------------------------------------------------------
# Tìm cây theo tên hiển thị (VD: "Nguyễn Du")
# ------------------------------------------------------------
func find_plant_by_name(plant_name: String) -> Dictionary:
	for plant_id in plants:
		var plant = plants[plant_id]
		if plant.get("name", "") == plant_name:
			return plant
	return {}

# ============================================================
# DEBUG — In tóm tắt dữ liệu ra Console
# ============================================================
func _print_summary() -> void:
	print("")
	print("═".repeat(60))
	print("  [GameData] DỮ LIỆU ĐÃ LOAD THÀNH CÔNG")
	print("═".repeat(60))
	print("  • Cây (Plants):     %d" % plants.size())
	print("  • Quái (Enemies):   %d" % enemies.size())
	print("  • Sóng (Waves):     %d" % waves.size())
	print("  • Màn (Levels):     %d" % levels.size())
	print("═".repeat(60))
	
	# In danh sách cây (nếu chạy ở debug mode)
	if OS.is_debug_build():
		print("  Danh sách cây:")
		for plant_id in plants:
			var p = plants[plant_id]
			print("    • %s (%s) — Cost: %d, HP: %d" % [
				p.get("name", "?"),
				p.get("title", "?"),
				p.get("cost", 0),
				p.get("hp", 0)
			])
	print("")
