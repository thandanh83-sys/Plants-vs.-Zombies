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
	var level_ids := DataLoader.get_all_level_ids()
	level_ids.sort()
	if level_ids.is_empty():
		state_label.text = "Chưa có dữ liệu màn chơi trong data/levels."
		return
	var level_id := str(level_ids[0])
	if not GameManager.start_level(level_id):
		return
	_on_sun_changed(GameManager.sun)
	var level := DataLoader.get_level(level_id)
	CardManager.build_cards(self, level.get("available_plants", []))
	if CardManager.container != null:
		CardManager.container.position = Vector2(285, 62)
	wave_manager.setup(factory, level)
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.all_waves_finished.connect(_on_all_waves_finished)
	wave_manager.start()

func _build_background() -> void:
	var background := ColorRect.new()
	background.color = Color(0.82, 0.90, 0.80)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	move_child(background, 0)

func _build_hud() -> void:
	sun_label = Label.new()
	sun_label.name = "SunLabel"
	sun_label.position = Vector2(24, 18)
	sun_label.size = Vector2(240, 40)
	sun_label.add_theme_font_size_override("font_size", 24)
	add_child(sun_label)
	state_label = Label.new()
	state_label.name = "StateLabel"
	state_label.position = Vector2(24, 58)
	state_label.size = Vector2(250, 40)
	add_child(state_label)

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if GameManager.state != "playing" or selected_plant_id.is_empty():
		return
	var cell := grid.world_to_grid(event.position)
	if cell.x < 0 or not grid.is_empty(cell.x, cell.y):
		return
	var data := DataLoader.get_plant(selected_plant_id)
	var cost := int(data.get("cost", 0))
	if not GameManager.spend_sun(cost):
		state_label.text = "Không đủ Linh Khí"
		return
	var plant := factory.spawn_plant(selected_plant_id, cell.x, cell.y, grid.get_grid_position(cell.x, cell.y))
	if plant == null:
		GameManager.add_sun(cost)
		return
	grid.set_occupied(cell.x, cell.y, plant)
	AudioManager.play("plant")
	CardManager.clear_selection()
	selected_plant_id = ""

func _on_card_selected(plant_id: String) -> void:
	selected_plant_id = plant_id

func _on_sun_changed(value: int) -> void:
	sun_label.text = "Linh Khí: %d" % value

func _on_state_changed(new_state: String) -> void:
	match new_state:
		"lost": state_label.text = "Thất bại — Zombie đã đột nhập!"
		"won": state_label.text = "Chiến thắng! Màn đã được lưu."

func _on_wave_started(wave_number: int) -> void:
	state_label.text = "Sóng %d" % wave_number

func _on_all_waves_finished() -> void:
	while GameManager.state == "playing" and not get_tree().get_nodes_in_group("zombies").is_empty():
		await get_tree().create_timer(0.25).timeout
	if GameManager.state == "playing":
		GameManager.win_level()
