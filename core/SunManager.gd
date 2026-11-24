extends Node

var timer := 0.0
var interval := 8.0
var amount := 25

func _ready() -> void:
	interval = max(0.1, float(DataLoader.get_setting("sun_drop_interval", interval)))
	amount = int(DataLoader.get_setting("sun_drop_amount", amount))

func _process(delta: float) -> void:
	if GameManager.state != "playing":
		return
	timer += delta
	if timer >= interval:
		timer = 0.0
		GameManager.add_sun(amount)
