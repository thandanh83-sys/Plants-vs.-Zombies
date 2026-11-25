extends Node

signal data_loaded

var plants_db: Dictionary = {}
var zombies_db: Dictionary = {}
var levels_db: Dictionary = {}
var config_db: Dictionary = {}
var ui_assets_db: Dictionary = {}

func _ready() -> void:
	config_db = _load_json("res://data/config/game-settings.json")
	ui_assets_db = _load_json("res://data/config/ui-assets.json")
	_scan_folder("res://data/plants", plants_db)
	_scan_folder("res://data/zombies", zombies_db)
	_scan_folder("res://data/levels", levels_db)
	_validate_database()
	print("[DataLoader] Loaded %d plants, %d zombies, %d levels" % [plants_db.size(), zombies_db.size(), levels_db.size()])
	data_loaded.emit()

func _scan_folder(folder_path: String, target: Dictionary) -> void:
	var dir := DirAccess.open(folder_path)
	if dir == null:
		push_error("Cannot open data folder: " + folder_path)
		return
	var files: Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.get_extension().to_lower() == "json":
			files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	files.sort()
	for file_name in files:
		var id := file_name.get_basename()
		var data := _load_json(folder_path.path_join(file_name))
		if data.is_empty():
			continue
		data["id"] = id
		target[id] = data

func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing JSON file: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot read JSON: " + path)
		return {}
	var parser := JSON.new()
	var error := parser.parse(file.get_as_text())
	if error != OK:
		push_error("Invalid JSON at %s:%d: %s" % [path, parser.get_error_line(), parser.get_error_message()])
		return {}
	if parser.data is Dictionary:
		return parser.data
	push_error("JSON root must be an object: " + path)
	return {}

func _validate_database() -> void:
	for id in plants_db:
		var data: Dictionary = plants_db[id]
		if str(data.get("name", "")).is_empty() or str(data.get("type", "")).is_empty():
			push_error("Plant %s must define name and type" % id)
		if int(data.get("cost", -1)) < 0 or float(data.get("hp", 0)) <= 0.0:
			push_error("Plant %s has invalid cost or hp" % id)
		if data.has("abilities") and not data["abilities"] is Dictionary:
			push_error("Plant %s abilities must be an object" % id)
	for id in zombies_db:
		var data: Dictionary = zombies_db[id]
		if str(data.get("name", "")).is_empty() or str(data.get("type", "")).is_empty():
			push_error("Zombie %s must define name and type" % id)
		if float(data.get("hp", 0)) <= 0.0 or float(data.get("speed", -1)) < 0.0:
			push_error("Zombie %s has invalid hp or speed" % id)
		if data.has("armor") and not data["armor"] is Dictionary:
			push_error("Zombie %s armor must be an object" % id)
	for level_id in levels_db:
		var level: Dictionary = levels_db[level_id]
		if not level.get("available_plants", []) is Array or not level.get("waves", []) is Array:
			push_error("Level %s must define available_plants and waves arrays" % level_id)
			continue
		for plant_id in level.get("available_plants", []):
			if not plants_db.has(str(plant_id)):
				push_error("Level %s references unknown plant %s" % [level_id, plant_id])
		for wave in level.get("waves", []):
			if not wave is Dictionary:
				push_error("Level %s contains a wave that is not an object" % level_id)
				continue
			for zombie_id in wave.get("zombies", []):
				if not zombies_db.has(str(zombie_id)):
					push_error("Level %s references unknown zombie %s" % [level_id, zombie_id])
	for key in ["logo", "seed_packet", "linh_khi"]:
		var asset_path := str(ui_assets_db.get(key, ""))
		if not asset_path.is_empty() and not ResourceLoader.exists(asset_path):
			push_warning("Configured UI asset is missing: " + asset_path)

func get_plant(id: String) -> Dictionary:
	return plants_db.get(id, {}).duplicate(true)

func get_zombie(id: String) -> Dictionary:
	return zombies_db.get(id, {}).duplicate(true)

func get_level(id: String) -> Dictionary:
	return levels_db.get(id, {}).duplicate(true)

func get_setting(key: String, default_value: Variant = null) -> Variant:
	return config_db.get(key, default_value)

func get_ui_asset(key: String, default_value: String = "") -> String:
	return str(ui_assets_db.get(key, default_value))

func get_all_plant_ids() -> Array:
	var ids := plants_db.keys()
	ids.sort()
	return ids

func get_all_zombie_ids() -> Array:
	var ids := zombies_db.keys()
	ids.sort()
	return ids

func get_all_level_ids() -> Array:
	var ids := levels_db.keys()
	ids.sort()
	return ids

func get_plant_sprite(id: String) -> Texture2D:
	var data := plants_db.get(id, {})
	var path := str(data.get("sprite", "res://assets/plants/%s.png" % id))
	return _load_sprite(path)

func get_zombie_sprite(id: String) -> Texture2D:
	var data := zombies_db.get(id, {})
	var path := str(data.get("sprite", "res://assets/zombies/%s.png" % id))
	return _load_sprite(path)

func _load_sprite(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D
