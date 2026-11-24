extends Node

var timer := 0.0
var interval := 8.0
var amount := 25

signal lin_khi_dropped(world_position: Vector2, amount: int)

func _ready() -> void:
	interval = max(0.1, float(DataLoader.get_setting("sun_drop_interval", interval)))
	amount = int(DataLoader.get_setting("sun_drop_amount", amount))

func _process(delta: float) -> void:
	if GameManager.state != "playing":
		return
	if str(GameManager.current_level.get("environment", "day")) == "night":
		return
	timer += delta
	if timer >= interval:
		timer = 0.0
		lin_khi_dropped.emit(Vector2(randf_range(360.0, 1120.0), randf_range(100.0, 600.0)), amount)
