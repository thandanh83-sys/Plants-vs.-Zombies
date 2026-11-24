extends Node

var timer := 0.0
var interval := 8.0
var amount := 25

func _ready() -> void:
	if DataLoader.levels_db.has(GameManager.current_level_id):
		interval = float(DataLoader.get_level(GameManager.current_level_id).get("sun_drop_interval", interval))

func _process(delta: float) -> void:
	if GameManager.state != "playing":
		return
	timer += delta
	if timer >= interval:
		timer = 0.0
		GameManager.add_sun(amount)
