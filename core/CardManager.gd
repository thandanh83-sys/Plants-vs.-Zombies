extends Node

signal card_selected(plant_id: String)

var container: HBoxContainer
var selected_id := ""

func build_cards(parent: Control, plant_ids: Array) -> void:
	if is_instance_valid(container):
		container.queue_free()

	container = HBoxContainer.new()
	container.name = "PlantCards"
	container.add_theme_constant_override("separation", 8)
	parent.add_child(container)

	for plant_id in plant_ids:
		var data := DataLoader.get_plant(str(plant_id))
		if data.is_empty():
			continue

		var button := Button.new()
		button.name = str(plant_id)
		button.custom_minimum_size = Vector2(132, 72)
		button.text = "%s\n%s Linh Khí" % [str(data.get("name", plant_id)), str(data.get("cost", 0))]
		button.toggle_mode = true
		button.pressed.connect(_on_card_pressed.bind(str(plant_id), button))
		container.add_child(button)

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
