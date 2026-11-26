extends Node

var container: HBoxContainer
var selected_id := ""
var _buttons: Dictionary = {}
var _recharge_remaining: Dictionary = {}

signal card_selected(plant_id: String)

func build_cards(parent: Control, plant_ids: Array) -> void:
	if is_instance_valid(container):
		container.queue_free()
	container = HBoxContainer.new()
	container.name = "PlantCards"
	container.add_theme_constant_override("separation", 8)
	parent.add_child(container)
	_buttons.clear()
	_recharge_remaining.clear()
	selected_id = ""

	var packet_path: String = DataLoader.get_ui_asset("seed_packet", "")
	var packet: Texture2D = load(packet_path) as Texture2D if not packet_path.is_empty() and ResourceLoader.exists(packet_path) else null
	for raw_id in plant_ids:
		var plant_id := str(raw_id)
		var data: Dictionary = DataLoader.get_plant(plant_id)
		if data.is_empty():
			continue
		var button := Button.new()
		button.name = plant_id
		button.custom_minimum_size = Vector2(132, 72)
		button.text = _get_card_text(plant_id)
		button.toggle_mode = true
		var plant_texture: Texture2D = DataLoader.get_plant_sprite(plant_id)
		var card_icon: Texture2D = plant_texture if plant_texture != null else packet
		if card_icon != null:
			button.icon = card_icon
			button.expand_icon = true
		button.tooltip_text = str(data.get("description", data.get("name", plant_id)))
		button.pressed.connect(_on_card_pressed.bind(plant_id, button))
		container.add_child(button)
		_buttons[plant_id] = button

	if not GameManager.sun_changed.is_connected(update_affordability):
		GameManager.sun_changed.connect(update_affordability)
	update_affordability(GameManager.sun)

func _process(delta: float) -> void:
	if GameManager.state != "playing" or _recharge_remaining.is_empty():
		return

	var needs_refresh := false
	for raw_id in _recharge_remaining.keys():
		var plant_id := str(raw_id)
		var previous_seconds := ceili(float(_recharge_remaining[plant_id]))
		var remaining := maxf(0.0, float(_recharge_remaining[plant_id]) - delta)
		if remaining <= 0.0:
			_recharge_remaining.erase(plant_id)
			needs_refresh = true
		else:
			_recharge_remaining[plant_id] = remaining
			if ceili(remaining) != previous_seconds:
				needs_refresh = true

	if needs_refresh:
		update_affordability(GameManager.sun)

func start_recharge(plant_id: String) -> void:
	var data: Dictionary = DataLoader.get_plant(plant_id)
	if data.is_empty():
		return
	var duration := maxf(0.0, float(data.get("recharge_time", _default_recharge_time(data))))
	if duration <= 0.0:
		_recharge_remaining.erase(plant_id)
	else:
		_recharge_remaining[plant_id] = duration
	update_affordability(GameManager.sun)

func get_recharge_remaining(plant_id: String) -> float:
	return maxf(0.0, float(_recharge_remaining.get(plant_id, 0.0)))

func _default_recharge_time(data: Dictionary) -> float:
	if int(data.get("cost", 0)) == 0:
		return 5.0
	var plant_type := str(data.get("type", "shooter"))
	var abilities: Dictionary = data.get("abilities", {})
	if str(abilities.get("attack", "")) == "eat_zombie":
		return 30.0
	if abilities.has("removes_obstacles"):
		return 25.0
	if plant_type == "exploder":
		return 25.0
	if plant_type == "wall":
		return 15.0
	if plant_type == "producer":
		return 7.5
	if bool(abilities.get("shoot_adjacent_lanes", false)) or int(abilities.get("projectiles_per_attack", 1)) > 1:
		return 15.0
	return 7.5


func _get_card_text(plant_id: String) -> String:
	var data: Dictionary = DataLoader.get_plant(plant_id)
	var name := str(data.get("name", plant_id))
	var cost := int(data.get("cost", 0))
	var remaining := get_recharge_remaining(plant_id)
	if remaining > 0.0:
		return "%s\nHồi chiêu: %ds" % [name, ceili(remaining)]
	return "%s\n%d Linh Khí" % [name, cost]

func update_affordability(sun_amount: int) -> void:
	for raw_id in _buttons:
		var plant_id := str(raw_id)
		var button: Button = _buttons[plant_id]
		var data: Dictionary = DataLoader.get_plant(plant_id)
		var remaining := get_recharge_remaining(plant_id)
		button.text = _get_card_text(plant_id)
		button.disabled = remaining > 0.0 or (int(data.get("cost", 0)) > sun_amount and plant_id != selected_id)

func _on_card_pressed(plant_id: String, pressed_button: Button) -> void:
	if get_recharge_remaining(plant_id) > 0.0:
		pressed_button.button_pressed = false
		return
	if pressed_button.button_pressed:
		for child in container.get_children():
			if child is Button and child != pressed_button:
				child.button_pressed = false
		selected_id = plant_id
		card_selected.emit(plant_id)
	else:
		if selected_id == plant_id:
			selected_id = ""
			card_selected.emit("")

func clear_selection() -> void:
	selected_id = ""
	if is_instance_valid(container):
		for child in container.get_children():
			if child is Button:
				child.button_pressed = false
	update_affordability(GameManager.sun)
