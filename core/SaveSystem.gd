extends Node

signal coins_changed(total: int)

const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := 2
const DEFAULT_DATA := {
	"save_version": SAVE_VERSION,
	"unlocked_levels": ["level-01-thu-vien"],
	"completed_levels": [],
	"best_sun": 0,
	"coins": 0,
	"unlocked_plant_ids": [],
	"zen_garden_pots": [],
	"tutorial_completed": false
}

var save_data: Dictionary = DEFAULT_DATA.duplicate(true)

func _ready() -> void:
	load_game()

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		save_data = DEFAULT_DATA.duplicate(true)
		_emit_coins_changed()
		return save_data
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Không đọc được file lưu; dùng dữ liệu mặc định.")
		save_data = DEFAULT_DATA.duplicate(true)
		_emit_coins_changed()
		return save_data
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK or not json.data is Dictionary:
		push_warning("File lưu không hợp lệ; dùng dữ liệu mặc định.")
		save_data = DEFAULT_DATA.duplicate(true)
		_emit_coins_changed()
		return save_data
	var loaded: Dictionary = json.data
	save_data = DEFAULT_DATA.duplicate(true)
	for key in DEFAULT_DATA:
		if loaded.has(key) and typeof(loaded[key]) == typeof(DEFAULT_DATA[key]):
			save_data[key] = loaded[key]
	if not (save_data["unlocked_levels"] is Array):
		save_data["unlocked_levels"] = ["level-01-thu-vien"]
	if not (save_data["completed_levels"] is Array):
		save_data["completed_levels"] = []
	if not (save_data["unlocked_plant_ids"] is Array):
		save_data["unlocked_plant_ids"] = []
	if not (save_data["zen_garden_pots"] is Array):
		save_data["zen_garden_pots"] = []
	if save_data["unlocked_levels"].is_empty():
		save_data["unlocked_levels"] = ["level-01-thu-vien"]
	save_data["coins"] = maxi(0, int(save_data.get("coins", 0)))
	save_data["best_sun"] = maxi(0, int(save_data.get("best_sun", 0)))
	save_data["save_version"] = SAVE_VERSION
	_emit_coins_changed()
	return save_data

func save_game() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Không thể tạo file lưu: " + SAVE_PATH)
		return false
	file.store_string(JSON.stringify(save_data, "\t"))
	file.flush()
	file.close()
	return true

func get_coins() -> int:
	return maxi(0, int(save_data.get("coins", 0)))

func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	save_data["coins"] = get_coins() + amount
	_emit_coins_changed()
	save_game()

func spend_coins(amount: int) -> bool:
	if amount < 0 or get_coins() < amount:
		return false
	save_data["coins"] = get_coins() - amount
	_emit_coins_changed()
	save_game()
	return true

func is_plant_unlocked(plant_id: String) -> bool:
	return plant_id in save_data.get("unlocked_plant_ids", [])

func unlock_plant(plant_id: String) -> bool:
	if DataLoader.get_plant(plant_id).is_empty():
		return false
	var unlocked: Array = save_data.get("unlocked_plant_ids", [])
	if plant_id in unlocked:
		return false
	unlocked.append(plant_id)
	save_data["unlocked_plant_ids"] = unlocked
	save_game()
	return true

func mark_tutorial_completed() -> void:
	save_data["tutorial_completed"] = true
	save_game()

func is_tutorial_completed() -> bool:
	return bool(save_data.get("tutorial_completed", false))

func is_level_unlocked(level_id: String) -> bool:
	return level_id in save_data.get("unlocked_levels", [])

func record_level_completed(level_id: String, remaining_sun: int = 0) -> void:
	var completed: Array = save_data.get("completed_levels", [])
	if level_id not in completed:
		completed.append(level_id)
	save_data["completed_levels"] = completed
	save_data["best_sun"] = maxi(int(save_data.get("best_sun", 0)), maxi(0, remaining_sun))
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

func _emit_coins_changed() -> void:
	coins_changed.emit(get_coins())
	GameEvents.player_coins_changed.emit(get_coins())

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_game()
