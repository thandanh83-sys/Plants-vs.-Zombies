extends Node

const SAVE_PATH := "user://savegame.json"

var save_data: Dictionary = {
	"unlocked_levels": ["level-01-thu-vien"],
	"completed_levels": [],
	"best_sun": 0
}

func _ready() -> void:
	load_game()

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return save_data
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Không đọc được file lưu; dùng dữ liệu mặc định.")
		return save_data
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK or not json.data is Dictionary:
		push_warning("File lưu không hợp lệ; dùng dữ liệu mặc định.")
		return save_data
	save_data = json.data
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
	save_game()
