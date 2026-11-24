extends Node

const SAVE_PATH := "user://savegame.json"

func save_level(level_id: String, won: bool) -> bool:
	var data := {
		"level_id": level_id,
		"won": won,
		"sun": GameManager.sun,
		"saved_at": Time.get_datetime_string_from_system()
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Không thể mở file lưu: " + SAVE_PATH)
		return false
	file.store_string(JSON.stringify(data, "  "))
	return true

func load_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}
	return json.data if json.data is Dictionary else {}
