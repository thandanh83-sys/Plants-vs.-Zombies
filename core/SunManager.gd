extends Node

var timer := 0.0
var interval := 8.0
var amount := 25

signal lin_khi_dropped(world_position: Vector2, amount: int)

func _ready() -> void:
	interval = maxf(0.1, float(DataLoader.get_setting("sun_drop_interval", interval)))
	amount = maxi(0, int(DataLoader.get_setting("sun_drop_amount", amount)))

func _process(delta: float) -> void:
	if GameManager.state != "playing":
		return
	if str(GameManager.current_level.get("environment", "day")) == "night":
		return
	timer += delta
	if timer >= interval:
		timer = 0.0
		var x_min := float(DataLoader.get_setting("drop_x_min", 360.0))
		var x_max := float(DataLoader.get_setting("drop_x_max", 1120.0))
		var y_min := float(DataLoader.get_setting("drop_y_min", 100.0))
		var y_max := float(DataLoader.get_setting("drop_y_max", 600.0))
		lin_khi_dropped.emit(Vector2(randf_range(x_min, x_max), randf_range(y_min, y_max)), amount)
