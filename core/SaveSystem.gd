extends Node

const SAVE_PATH := "user://savegame.json"
const DEFAULT_DATA := {
	"unlocked_levels": ["level-01-thu-vien"],
	"completed_levels": [],
	"best_sun": 0
}

var save_data: Dictionary = DEFAULT_DATA.duplicate(true)

func _ready() -> void:
	load_game()

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		save_data = DEFAULT_DATA.duplicate(true)
		return save_data
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Không đọc được file lưu; dùng dữ liệu mặc định.")
		save_data = DEFAULT_DATA.duplicate(true)
		return save_data
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK or not json.data is Dictionary:
		push_warning("File lưu không hợp lệ; dùng dữ liệu mặc định.")
		save_data = DEFAULT_DATA.duplicate(true)
		return save_data
	save_data = DEFAULT_DATA.duplicate(true)
	for key in DEFAULT_DATA:
		if json.data.has(key) and typeof(json.data[key]) == typeof(DEFAULT_DATA[key]):
			save_data[key] = json.data[key]
	if save_data["unlocked_levels"].is_empty():
		save_data["unlocked_levels"] = ["level-01-thu-vien"]
	return save_data

func save_game() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Không thể tạo file lưu: " + SAVE_PATH)
		return false
	file.store_string(JSON.stringify(save_data, "\t"))
	return true

func is_level_unlocked(level_id: String) -> bool:
	return level_id in save_data.get("unlocked_levels", [])

func record_level_completed(level_id: String) -> void:
	var completed: Array = save_data.get("completed_levels", [])
	if level_id not in completed:
		completed.append(level_id)
	save_data["completed_levels"] = completed
	var level_ids: Array = DataLoader.get_all_level_ids()
	level_ids.sort()
	var current_index: int = level_ids.find(level_id)
	if current_index >= 0 and current_index + 1 < level_ids.size():
		var next_id := str(level_ids[current_index + 1])
		var unlocked: Array = save_data.get("unlocked_levels", [])
		if next_id not in unlocked:
			unlocked.append(next_id)
		save_data["unlocked_levels"] = unlocked
	save_game()
