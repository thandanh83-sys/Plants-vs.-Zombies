extends Node

signal garden_changed

const POT_COUNT := 3
const NEED_TYPES: Array[String] = ["water", "fertilizer", "bug_spray", "music"]

func _ready() -> void:
	_normalize_pots()

func get_pots() -> Array:
	var value: Variant = SaveSystem.save_data.get("zen_garden_pots", [])
	if value is Array:
		return value.duplicate(true)
	return []

func plant_seed(pot_index: int, plant_id: String) -> bool:
	if pot_index < 0 or pot_index >= POT_COUNT:
		return false
	if DataLoader.get_plant(plant_id).is_empty():
		return false
	var pots := get_pots()
	var pot: Dictionary = pots[pot_index]
	if not str(pot.get("plant_id", "")).is_empty():
		return false
	pot["plant_id"] = plant_id
	pot["growth_stage"] = 1
	pot["need"] = _random_need()
	pots[pot_index] = pot
	SaveSystem.save_data["zen_garden_pots"] = pots
	SaveSystem.save_game()
	garden_changed.emit()
	return true

func fulfill_need(pot_index: int, tool_type: String) -> bool:
	if pot_index < 0 or pot_index >= POT_COUNT or not NEED_TYPES.has(tool_type):
		return false
	var pots := get_pots()
	var pot: Dictionary = pots[pot_index]
	if str(pot.get("plant_id", "")).is_empty():
		return false
	if str(pot.get("need", "")) != tool_type:
		return false
	pot["growth_stage"] = mini(3, int(pot.get("growth_stage", 1)) + 1)
	pot["need"] = _random_need()
	pots[pot_index] = pot
	SaveSystem.save_data["zen_garden_pots"] = pots
	SaveSystem.add_coins(10)
	SaveSystem.save_game()
	garden_changed.emit()
	return true

func _normalize_pots() -> void:
	var raw: Variant = SaveSystem.save_data.get("zen_garden_pots", [])
	var source: Array = raw if raw is Array else []
	var normalized: Array = []
	for index in range(POT_COUNT):
		var pot: Dictionary = {}
		if index < source.size():
			var raw_pot: Variant = source[index]
			if raw_pot is Dictionary:
				pot = raw_pot.duplicate(true)
		var plant_id := str(pot.get("plant_id", ""))
		pot["plant_id"] = plant_id
		pot["growth_stage"] = clampi(int(pot.get("growth_stage", 0 if plant_id.is_empty() else 1)), 0, 3)
		var need := str(pot.get("need", ""))
		if plant_id.is_empty():
			pot["need"] = ""
			pot["growth_stage"] = 0
		elif not NEED_TYPES.has(need):
			pot["need"] = _random_need()
		normalized.append(pot)
	SaveSystem.save_data["zen_garden_pots"] = normalized
	SaveSystem.save_game()

func _random_need() -> String:
	return NEED_TYPES[randi_range(0, NEED_TYPES.size() - 1)]
