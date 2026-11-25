extends Node

signal sun_changed(value: int)
signal state_changed(state: String)
signal plant_food_changed(charges: int)

var sun := 50
var plant_food_charges := 1
var current_level_id := ""
var current_level: Dictionary = {}
var state := "menu"

func _ready() -> void:
	if not DataLoader.data_loaded.is_connected(_on_data_loaded):
		DataLoader.data_loaded.connect(_on_data_loaded)
	if not DataLoader.levels_db.is_empty():
		_on_data_loaded()

func _on_data_loaded() -> void:
	if current_level_id.is_empty() and not DataLoader.levels_db.is_empty():
		var level_ids: Array = DataLoader.get_all_level_ids()
		level_ids.sort()
		current_level_id = str(level_ids[0])
		_set_state("menu")

func start_level(level_id: String) -> bool:
	var level: Dictionary = DataLoader.get_level(level_id)
	if level.is_empty():
		push_error("Không tìm thấy màn: " + level_id)
		return false
	current_level_id = level_id
	current_level = level
	sun = int(level.get("starting_sun", DataLoader.get_setting("starting_sun", 50)))
	plant_food_charges = maxi(0, int(level.get("starting_plant_food", DataLoader.get_setting("starting_plant_food", 1))))
	_set_state("playing")
	sun_changed.emit(sun)
	plant_food_changed.emit(plant_food_charges)
	return true

func add_sun(amount: int) -> void:
	set_sun(sun + amount)

func spend_sun(amount: int) -> bool:
	if amount < 0 or sun < amount:
		return false
	set_sun(sun - amount)
	return true

func set_sun(value: int) -> void:
	sun = maxi(0, value)
	sun_changed.emit(sun)

func add_plant_food(amount: int = 1) -> void:
	plant_food_charges += maxi(0, amount)
	plant_food_changed.emit(plant_food_charges)

func spend_plant_food() -> bool:
	if plant_food_charges <= 0:
		return false
	plant_food_charges -= 1
	plant_food_changed.emit(plant_food_charges)
	return true

func win_level() -> void:
	if state != "playing":
		return
	SaveSystem.record_level_completed(current_level_id)
	_set_state("won")

func lose_level() -> void:
	if state == "playing":
		_set_state("lost")

func _set_state(value: String) -> void:
	state = value
	state_changed.emit(state)
