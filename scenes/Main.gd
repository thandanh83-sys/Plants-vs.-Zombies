extends Control

var grid: GridManager
var factory: EntityFactory
var wave_manager: WaveManager
var selected_plant_id := ""
var sun_label: Label
var state_label: Label

func _ready() -> void:
	_build_background()
	_build_hud()

	grid = GridManager.new()
	grid.name = "GridManager"
	add_child(grid)

	factory = EntityFactory.new()
	factory.name = "EntityFactory"
	add_child(factory)

	wave_manager = WaveManager.new()
	wave_manager.name = "WaveManager"
	add_child(wave_manager)

	GameManager.sun_changed.connect(_on_sun_changed)
	GameManager.state_changed.connect(_on_state_changed)
	CardManager.card_selected.connect(_on_card_selected)

	var level_id := "level-01-thu-vien"
	if not DataLoader.levels_db.is_empty():
		level_id = str(DataLoader.levels_db.keys()[0])

	GameManager.start_level(level_id)
	var level := DataLoader.get_level(level_id)
	CardManager.build_cards(self, level.get("available_plants", []))
	if CardManager.container:
		CardManager.container.position = Vector2(285, 70)
	wave_manager.setup(factory, level)
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.all_waves_finished.connect(_on_all_waves_finished)
	wave_manager.start()

func _build_background() -> void:
	var background := ColorRect.new()
	background.color = Color(0.82, 0.90, 0.80)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

func _build_hud() -> void:
	sun_label = Label.new()
	sun_label.name = "SunLabel"
	sun_label.position = Vector2(24, 18)
	sun_label.size = Vector2(220, 44)
	sun_label.text = "Linh Khí: 50"
	sun_label.add_theme_font_size_override("font_size", 24)
	add_child(sun_label)

	state_label = Label.new()
	state_label.name = "StateLabel"
	state_label.position = Vector2(24, 58)
	state_label.size = Vector2(220, 44)
	state_label.text = ""
	add_child(state_label)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if GameManager.state != "playing" or selected_plant_id.is_empty():
			return
		var cell := grid.world_to_grid(event.position)
		if cell.x < 0:
			return
		if not grid.is_empty(cell.x, cell.y):
			return

		var data := DataLoader.get_plant(selected_plant_id)
		var cost := int(data.get("cost", 0))
		if not GameManager.spend_sun(cost):
			state_label.text = "Không đủ Linh Khí"
			return

		var world_position := grid.get_grid_position(cell.x, cell.y)
		var plant := factory.spawn_plant(selected_plant_id, cell.x, cell.y, world_position)
		if plant:
			grid.set_occupied(cell.x, cell.y, plant)
			AudioManager.play("plant")
			CardManager.clear_selection()
			selected_plant_id = ""

func _on_card_selected(plant_id: String) -> void:
	selected_plant_id = plant_id

func _on_sun_changed(value: int) -> void:
	sun_label.text = "Linh Khí: %d" % value

func _on_state_changed(state: String) -> void:
	if state == "lost":
		state_label.text = "Thất bại — Zombie đã đột nhập!"

func _on_wave_started(wave_number: int) -> void:
	state_label.text = "Sóng %d" % wave_number

func _on_all_waves_finished() -> void:
	await get_tree().create_timer(1.0).timeout
	if get_tree().get_nodes_in_group("zombies").is_empty():
		GameManager._set_state("won")
		state_label.text = "Chiến thắng!"
