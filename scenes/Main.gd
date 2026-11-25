extends Control

var grid: GridManager
var factory: EntityFactory
var wave_manager: WaveManager
var selected_plant_id := ""
var sun_label: Label
var state_label: Label
var plant_food_button: Button
var plant_food_mode := false
var level_selector: OptionButton
var level_start_button: Button
var background_texture: TextureRect
var restart_button: Button
var _starting_level := false

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
	GameManager.plant_food_changed.connect(_on_plant_food_changed)
	CardManager.card_selected.connect(_on_card_selected)
	SunManager.lin_khi_dropped.connect(_on_linh_khi_dropped)
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.all_waves_finished.connect(_on_all_waves_finished)
	_populate_levels()
	var first_unlocked := _first_unlocked_level()
	if not first_unlocked.is_empty():
		_start_level(first_unlocked)
	else:
		state_label.text = "Chưa có màn chơi hợp lệ trong data/levels."

func _build_background() -> void:
	var background := ColorRect.new()
	background.color = Color("d1e6cc")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	background_texture = TextureRect.new()
	background_texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_texture.modulate = Color(1, 1, 1, 0.22)
	add_child(background_texture)

func _build_hud() -> void:
	sun_label = Label.new()
	sun_label.position = Vector2(20, 16)
	sun_label.size = Vector2(160, 34)
	sun_label.add_theme_font_size_override("font_size", 22)
	add_child(sun_label)
	plant_food_button = Button.new()
	plant_food_button.position = Vector2(175, 12)
	plant_food_button.size = Vector2(145, 40)
	plant_food_button.text = "Linh Đan ×1"
	plant_food_button.toggle_mode = true
	plant_food_button.tooltip_text = "Chọn Linh Đan rồi nhấp vào một cây để kích hoạt."
	plant_food_button.pressed.connect(_toggle_plant_food)
	add_child(plant_food_button)
	state_label = Label.new()
	state_label.position = Vector2(20, 56)
	state_label.size = Vector2(300, 30)
	state_label.add_theme_font_size_override("font_size", 16)
	add_child(state_label)
	level_selector = OptionButton.new()
	level_selector.position = Vector2(850, 12)
	level_selector.size = Vector2(245, 40)
	level_selector.item_selected.connect(_on_level_selected)
	add_child(level_selector)
	level_start_button = Button.new()
	level_start_button.position = Vector2(1105, 12)
	level_start_button.size = Vector2(150, 40)
	level_start_button.text = "Vào màn"
	level_start_button.pressed.connect(_start_selected_level)
	add_child(level_start_button)

func _populate_levels() -> void:
	level_selector.clear()
	var ids: Array = DataLoader.get_all_level_ids()
	ids.sort()
	for level_id in ids:
		var level: Dictionary = DataLoader.get_level(str(level_id))
		var index := level_selector.item_count
		level_selector.add_item(str(level.get("name", level_id)))
		level_selector.set_item_metadata(index, str(level_id))
		level_selector.set_item_disabled(index, not SaveSystem.is_level_unlocked(str(level_id)))
	var first_unlocked := _first_unlocked_level()
	if not first_unlocked.is_empty():
		for i in range(level_selector.item_count):
			if str(level_selector.get_item_metadata(i)) == first_unlocked:
				level_selector.select(i)
				break

func _first_unlocked_level() -> String:
	var ids: Array = DataLoader.get_all_level_ids()
	ids.sort()
	for level_id in ids:
		if SaveSystem.is_level_unlocked(str(level_id)):
			return str(level_id)
	return str(ids[0]) if not ids.is_empty() else ""

func _on_level_selected(_index: int) -> void:
	pass

func _start_selected_level() -> void:
	var index := level_selector.selected
	if index < 0 or index >= level_selector.item_count:
		return
	var level_id := str(level_selector.get_item_metadata(index))
	if SaveSystem.is_level_unlocked(level_id):
		_start_level(level_id)

func _start_level(level_id: String) -> void:
	if _starting_level or not GameManager.start_level(level_id):
		return
	_starting_level = true
	wave_manager.stop()
	grid.clear_all()
	grid.configure_level()
	for node in get_tree().get_nodes_in_group("zombies") + get_tree().get_nodes_in_group("projectiles"):
		node.queue_free()
	CardManager.clear_selection()
	selected_plant_id = ""
	plant_food_mode = false
	plant_food_button.button_pressed = false
	_load_level_background(GameManager.current_level)
	CardManager.build_cards(self, GameManager.current_level.get("available_plants", []))
	if CardManager.container != null:
		CardManager.container.position = Vector2(330, 62)
	state_label.text = str(GameManager.current_level.get("name", level_id))
	wave_manager.setup(factory, GameManager.current_level)
	wave_manager.start()
	_starting_level = false

func _load_level_background(level: Dictionary) -> void:
	var path := str(level.get("background", ""))
	background_texture.texture = load(path) as Texture2D if not path.is_empty() and ResourceLoader.exists(path) else null
	grid.queue_redraw()

func _toggle_plant_food() -> void:
	if GameManager.plant_food_charges <= 0:
		return
	plant_food_mode = not plant_food_mode
	plant_food_button.button_pressed = plant_food_mode
	plant_food_button.text = "Chọn cây..." if plant_food_mode else "Linh Đan ×%d" % GameManager.plant_food_charges
	selected_plant_id = ""
	CardManager.clear_selection()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if GameManager.state != "playing":
		return
	if plant_food_mode:
		for plant in get_tree().get_nodes_in_group("plants"):
			if plant.global_position.distance_to(event.position) <= 42.0:
				if GameManager.spend_plant_food():
					plant.activate_plant_food()
				plant_food_mode = false
				plant_food_button.button_pressed = false
				_on_plant_food_changed(GameManager.plant_food_charges)
				return
		return
	if selected_plant_id.is_empty():
		return
	var cell: Vector2i = grid.world_to_grid(event.position)
	if cell.x < 0 or not grid.can_place_plant(selected_plant_id, cell.x, cell.y):
		state_label.text = "Ô này không phù hợp với loại cây đã chọn."
		return
	var data: Dictionary = DataLoader.get_plant(selected_plant_id)
	var cost := int(data.get("cost", 0))
	if not GameManager.spend_sun(cost):
		state_label.text = "Không đủ Linh Khí"
		return
	var abilities: Dictionary = data.get("abilities", {})
	var is_platform := bool(abilities.get("supports_aquatic_plants", false))
	var plant := factory.spawn_plant(selected_plant_id, cell.x, cell.y, grid.get_grid_position(cell.x, cell.y))
	if plant == null or not grid.set_occupied(cell.x, cell.y, plant, is_platform):
		if is_instance_valid(plant):
			plant.queue_free()
		GameManager.add_sun(cost)
		return
	AudioManager.play("plant")
	CardManager.clear_selection()
	selected_plant_id = ""

func _on_linh_khi_dropped(world_position: Vector2, amount: int) -> void:
	var button := Button.new()
	button.text = "✦"
	button.position = world_position - Vector2(22, 22)
	button.size = Vector2(44, 44)
	button.tooltip_text = "%d Linh Khí" % amount
	button.pressed.connect(func():
		GameManager.add_sun(amount)
		button.queue_free()
	)
	add_child(button)
	var timer := get_tree().create_timer(8.0)
	timer.timeout.connect(func():
		if is_instance_valid(button):
			button.queue_free()
	)

func _on_card_selected(plant_id: String) -> void:
	selected_plant_id = plant_id
	plant_food_mode = false
	plant_food_button.button_pressed = false

func _on_sun_changed(value: int) -> void:
	sun_label.text = "Linh Khí: %d" % value

func _on_plant_food_changed(charges: int) -> void:
	plant_food_button.disabled = charges <= 0
	plant_food_button.text = "Linh Đan ×%d" % charges
	if not plant_food_mode:
		plant_food_button.button_pressed = false

func _on_state_changed(new_state: String) -> void:
	match new_state:
		"lost":
			state_label.text = "Thất bại — Cương Thi đã đột nhập!"
			_show_restart_button("Thử lại")
		"won":
			state_label.text = "Chiến thắng! Tiến trình đã được lưu."
			_populate_levels()
			_show_restart_button("Chơi lại màn")

func _show_restart_button(label_text: String) -> void:
	if is_instance_valid(restart_button):
		restart_button.queue_free()
	restart_button = Button.new()
	restart_button.text = label_text
	restart_button.position = Vector2(500, 330)
	restart_button.size = Vector2(280, 64)
	restart_button.pressed.connect(func():
		_start_level(GameManager.current_level_id)
		restart_button.queue_free()
	)
	add_child(restart_button)

func _on_wave_started(wave_number: int) -> void:
	state_label.text = "%s — Sóng %d" % [str(GameManager.current_level.get("name", "")), wave_number]

func _on_all_waves_finished() -> void:
	while GameManager.state == "playing" and not get_tree().get_nodes_in_group("zombies").is_empty():
		await get_tree().create_timer(0.25).timeout
	if GameManager.state == "playing":
		GameManager.win_level()
