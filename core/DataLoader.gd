extends Node

signal data_loaded

var plants_db: Dictionary = {}
var zombies_db: Dictionary = {}
var levels_db: Dictionary = {}

func _ready() -> void:
	_scan_folder("res://data/plants/", plants_db)
	_scan_folder("res://data/zombies/", zombies_db)
	_scan_folder("res://data/levels/", levels_db)
	print("[DataLoader] Đã nạp: %d cây, %d zombie, %d màn" % [plants_db.size(), zombies_db.size(), levels_db.size()])
	data_loaded.emit()

func _scan_folder(folder_path: String, target_dict: Dictionary) -> void:
	if not DirAccess.dir_exists_absolute(folder_path):
		DirAccess.make_dir_recursive_absolute(folder_path)
		return

	var dir := DirAccess.open(folder_path)
	if dir == null:
		push_error("Không thể mở thư mục dữ liệu: " + folder_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var id := file_name.trim_suffix(".json")
			var data := _load_json(folder_path + file_name)
			if not data.is_empty():
				data["id"] = id
				target_dict[id] = data
		file_name = dir.get_next()
	dir.list_dir_end()

func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Không thể đọc: " + path)
		return {}

	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	if error != OK:
		push_error("JSON lỗi tại %s dòng %d" % [path, json.get_error_line()])
		return {}
	if json.data is Dictionary:
		return json.data
	return {}

func get_plant(id: String) -> Dictionary:
	return plants_db.get(id, {})

func get_zombie(id: String) -> Dictionary:
	return zombies_db.get(id, {})

func get_level(id: String) -> Dictionary:
	return levels_db.get(id, {})

func get_all_plant_ids() -> Array:
	return plants_db.keys()

func get_all_zombie_ids() -> Array:
	return zombies_db.keys()

func get_all_level_ids() -> Array:
	return levels_db.keys()

func get_plant_sprite(id: String) -> Texture2D:
	return _load_sprite("res://assets/plants/" + id + ".png")

func get_zombie_sprite(id: String) -> Texture2D:
	return _load_sprite("res://assets/zombies/" + id + ".png")

func _load_sprite(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	return null
