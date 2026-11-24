extends Node

signal sun_changed(value: int)
signal state_changed(state: String)

var sun := 50
var current_level_id := ""
var current_level: Dictionary = {}
var state := "menu"

func _ready() -> void:
	if is_instance_valid(DataLoader):
		DataLoader.data_loaded.connect(_on_data_loaded)
		if not DataLoader.plants_db.is_empty() or not DataLoader.levels_db.is_empty():
			_on_data_loaded()

func _on_data_loaded() -> void:
	if current_level_id.is_empty() and not DataLoader.levels_db.is_empty():
		start_level(DataLoader.levels_db.keys()[0])

func start_level(level_id: String) -> void:
	var level := DataLoader.get_level(level_id)
	if level.is_empty():
		push_error("Không tìm thấy màn: " + level_id)
		return
	current_level_id = level_id
	current_level = level
	sun = int(level.get("starting_sun", 50))
	_set_state("playing")
	sun_changed.emit(sun)

func add_sun(amount: int) -> void:
	set_sun(sun + amount)

func spend_sun(amount: int) -> bool:
	if sun < amount:
		return false
	set_sun(sun - amount)
	return true

func set_sun(value: int) -> void:
	sun = max(0, value)
	sun_changed.emit(sun)

func _set_state(value: String) -> void:
	state = value
	state_changed.emit(state)
