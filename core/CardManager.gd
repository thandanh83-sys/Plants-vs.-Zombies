extends Node

var container: HBoxContainer
var selected_id := ""
var _buttons: Dictionary = {}

signal card_selected(plant_id: String)

func build_cards(parent: Control, plant_ids: Array) -> void:
	if is_instance_valid(container):
		container.queue_free()
	container = HBoxContainer.new()
	container.name = "PlantCards"
	container.add_theme_constant_override("separation", 8)
	parent.add_child(container)
	_buttons.clear()
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
		button.text = "%s\n%s Linh Khí" % [str(data.get("name", plant_id)), str(data.get("cost", 0))]
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

func update_affordability(sun_amount: int) -> void:
	for plant_id in _buttons:
		var button: Button = _buttons[plant_id]
		var data: Dictionary = DataLoader.get_plant(str(plant_id))
		button.disabled = int(data.get("cost", 0)) > sun_amount and str(plant_id) != selected_id

func _on_card_pressed(plant_id: String, pressed_button: Button) -> void:
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
