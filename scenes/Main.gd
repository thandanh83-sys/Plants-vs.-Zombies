extends Control

const VGLTheme = preload("res://core/UITheme.gd")

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
var logo_texture_rect: TextureRect
var restart_button: Button
var _starting_level := false
var _level_run_id := 0
var pause_button: Button
var speed_button: Button
var shovel_button: Button
var almanac_button: Button
var map_button: Button
var wave_progress: ProgressBar
var progress_caption: Label
var wave_banner: Label
var overlay_panel: PanelContainer
var overlay_backdrop: ColorRect
var top_hud_panel: PanelContainer
var wave_panel: PanelContainer
var ghost_preview: Node2D
var ghost_sprite: Sprite2D
var ghost_fallback: Polygon2D
var shovel_mode := false
var _speed_index := 0
var _banner_tween: Tween
var _safe_left := 0.0
var _safe_right := 0.0
var _safe_top := 0.0
var _safe_bottom := 0.0
var world_layer: Node2D
var coins_label: Label
var zen_garden_button: Button
var tutorial_label: Label
var tutorial_skip_button: Button
var _tutorial_step := -1
var _shake_tween: Tween
var _overlay_pause_changed := false
var _overlay_previous_paused := false
var _overlay_previous_time_scale := 1.0
const GAME_SPEEDS := [1.0, 1.5, 2.0]

func _ready() -> void:
	theme = VGLTheme.create_theme()
	_build_background()
	_build_hud()
	_build_tutorial_ui()
	call_deferred("_apply_safe_area")
	world_layer = Node2D.new()
	world_layer.name = "WorldLayer"
	add_child(world_layer)
	grid = GridManager.new()
	grid.name = "GridManager"
	world_layer.add_child(grid)
	factory = EntityFactory.new()
	factory.name = "EntityFactory"
	world_layer.add_child(factory)
	wave_manager = WaveManager.new()
	wave_manager.name = "WaveManager"
	add_child(wave_manager)
	_build_placement_preview()
	GameManager.sun_changed.connect(_on_sun_changed)
	GameManager.state_changed.connect(_on_state_changed)
	GameManager.plant_food_changed.connect(_on_plant_food_changed)
	GameEvents.screen_shake_requested.connect(_on_screen_shake_requested)
	GameEvents.player_coins_changed.connect(_on_coins_changed)
	GameEvents.wave_intensity_changed.connect(AudioManager.set_horde_intensity)
	_on_coins_changed(SaveSystem.get_coins())
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
	top_hud_panel = PanelContainer.new()
	top_hud_panel.name = "TopHudPanel"
	top_hud_panel.position = Vector2(12, 8)
	top_hud_panel.size = Vector2(1256, 132)
	top_hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_hud_panel)

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
	coins_label = Label.new()
	coins_label.position = Vector2(380, 16)
	coins_label.size = Vector2(105, 34)
	coins_label.add_theme_font_size_override("font_size", 18)
	add_child(coins_label)
	zen_garden_button = Button.new()
	zen_garden_button.position = Vector2(490, 12)
	zen_garden_button.size = Vector2(130, 40)
	zen_garden_button.text = "Vườn Thiền"
	zen_garden_button.pressed.connect(_open_zen_garden)
	add_child(zen_garden_button)
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

	pause_button = Button.new()
	pause_button.position = Vector2(20, 96)
	pause_button.size = Vector2(105, 38)
	pause_button.text = "Tạm dừng"
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.pressed.connect(_toggle_pause)
	add_child(pause_button)

	speed_button = Button.new()
	speed_button.position = Vector2(132, 96)
	speed_button.size = Vector2(125, 38)
	speed_button.text = "Tốc độ: 1.0x"
	speed_button.process_mode = Node.PROCESS_MODE_ALWAYS
	speed_button.pressed.connect(_cycle_game_speed)
	add_child(speed_button)

	shovel_button = Button.new()
	shovel_button.position = Vector2(264, 96)
	shovel_button.size = Vector2(108, 38)
	shovel_button.text = "Xẻng"
	shovel_button.tooltip_text = "Chọn xẻng rồi nhấp vào cây cần đào. Không hoàn lại Linh Khí."
	shovel_button.toggle_mode = true
	shovel_button.pressed.connect(_toggle_shovel)
	add_child(shovel_button)

	almanac_button = Button.new()
	almanac_button.position = Vector2(640, 12)
	almanac_button.size = Vector2(100, 40)
	almanac_button.text = "Bách khoa"
	almanac_button.pressed.connect(_open_almanac.bind("plants"))
	add_child(almanac_button)

	map_button = Button.new()
	map_button.position = Vector2(745, 12)
	map_button.size = Vector2(95, 40)
	map_button.text = "Bản đồ"
	map_button.pressed.connect(_open_world_map)
	add_child(map_button)

	wave_panel = PanelContainer.new()
	wave_panel.name = "WaveProgressPanel"
	wave_panel.position = Vector2(922, 628)
	wave_panel.size = Vector2(340, 76)
	wave_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wave_panel)

	wave_progress = ProgressBar.new()
	wave_progress.position = Vector2(940, 665)
	wave_progress.size = Vector2(300, 18)
	wave_progress.show_percentage = false
	wave_progress.min_value = 0.0
	wave_progress.max_value = 1.0
	wave_progress.value = 0.0
	add_child(wave_progress)

	progress_caption = Label.new()
	progress_caption.position = Vector2(940, 640)
	progress_caption.size = Vector2(300, 22)
	progress_caption.text = "TIẾN ĐỘ ĐỢT CƯƠNG THI"
	progress_caption.add_theme_font_size_override("font_size", 13)
	add_child(progress_caption)

	wave_banner = Label.new()
	wave_banner.position = Vector2(360, 315)
	wave_banner.size = Vector2(560, 72)
	wave_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wave_banner.add_theme_font_size_override("font_size", 34)
	wave_banner.add_theme_color_override("font_color", Color("fff0b0"))
	wave_banner.add_theme_color_override("font_shadow_color", Color(0.05, 0.05, 0.05, 0.85))
	wave_banner.add_theme_constant_override("shadow_offset_x", 2)
	wave_banner.add_theme_constant_override("shadow_offset_y", 3)
	wave_banner.modulate.a = 0.0
	wave_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wave_banner)
	_build_logo()

func _build_logo() -> void:
	var logo_path: String = DataLoader.get_ui_asset("logo", "")
	if logo_path.is_empty() or not ResourceLoader.exists(logo_path):
		return
	logo_texture_rect = TextureRect.new()
	logo_texture_rect.name = "GameLogo"
	logo_texture_rect.position = Vector2(36, 205)
	logo_texture_rect.size = Vector2(210, 210)
	logo_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo_texture_rect.texture = load(logo_path) as Texture2D
	add_child(logo_texture_rect)

func _build_placement_preview() -> void:
	ghost_preview = Node2D.new()
	ghost_preview.name = "PlacementGhost"
	ghost_preview.z_index = 50
	ghost_preview.visible = false
	add_child(ghost_preview)

	ghost_sprite = Sprite2D.new()
	ghost_sprite.centered = true
	ghost_sprite.modulate = Color(1.0, 1.0, 1.0, 0.55)
	ghost_sprite.visible = false
	ghost_preview.add_child(ghost_sprite)

	ghost_fallback = Polygon2D.new()
	ghost_fallback.polygon = PackedVector2Array([
		Vector2(0, -30), Vector2(24, -14), Vector2(20, 22),
		Vector2(-20, 22), Vector2(-24, -14)
	])
	ghost_fallback.color = Color(0.25, 0.85, 0.42, 0.5)
	ghost_preview.add_child(ghost_fallback)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		call_deferred("_apply_safe_area")

func _apply_safe_area() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var screen_index: int = DisplayServer.window_get_current_screen()
	var screen_size: Vector2i = DisplayServer.screen_get_size(screen_index)
	if screen_size.x <= 0 or screen_size.y <= 0 or viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var safe_rect: Rect2i = DisplayServer.get_display_safe_area()
	var scale_x := viewport_size.x / float(screen_size.x)
	var scale_y := viewport_size.y / float(screen_size.y)
	_safe_left = maxf(0.0, float(safe_rect.position.x) * scale_x)
	_safe_top = maxf(0.0, float(safe_rect.position.y) * scale_y)
	_safe_right = maxf(0.0, float(screen_size.x - safe_rect.end.x) * scale_x)
	_safe_bottom = maxf(0.0, float(screen_size.y - safe_rect.end.y) * scale_y)

	if is_instance_valid(top_hud_panel):
		top_hud_panel.position = Vector2(12.0 + _safe_left, 8.0 + _safe_top)
		top_hud_panel.size = Vector2(maxf(320.0, viewport_size.x - _safe_left - _safe_right - 24.0), 132.0)
	if is_instance_valid(wave_panel):
		wave_panel.position = Vector2(viewport_size.x - _safe_right - 358.0, viewport_size.y - _safe_bottom - 92.0)
	if is_instance_valid(logo_texture_rect):
		logo_texture_rect.position = Vector2(36.0 + _safe_left, 205.0 + _safe_top)
	sun_label.position = Vector2(20.0 + _safe_left, 16.0 + _safe_top)
	plant_food_button.position = Vector2(175.0 + _safe_left, 12.0 + _safe_top)
	state_label.position = Vector2(20.0 + _safe_left, 56.0 + _safe_top)
	coins_label.position = Vector2(380.0 + _safe_left, 16.0 + _safe_top)
	zen_garden_button.position = Vector2(490.0 + _safe_left, 12.0 + _safe_top)
	pause_button.position = Vector2(20.0 + _safe_left, 96.0 + _safe_top)
	speed_button.position = Vector2(132.0 + _safe_left, 96.0 + _safe_top)
	shovel_button.position = Vector2(264.0 + _safe_left, 96.0 + _safe_top)
	almanac_button.position = Vector2(viewport_size.x - _safe_right - 640.0, 12.0 + _safe_top)
	map_button.position = Vector2(viewport_size.x - _safe_right - 535.0, 12.0 + _safe_top)
	level_selector.position = Vector2(viewport_size.x - _safe_right - 430.0, 12.0 + _safe_top)
	level_start_button.position = Vector2(viewport_size.x - _safe_right - 175.0, 12.0 + _safe_top)
	wave_progress.position = Vector2(viewport_size.x - _safe_right - 340.0, viewport_size.y - _safe_bottom - 55.0)
	progress_caption.position = Vector2(viewport_size.x - _safe_right - 340.0, viewport_size.y - _safe_bottom - 80.0)
	wave_banner.position = Vector2(viewport_size.x * 0.5 - 280.0, viewport_size.y * 0.5 - 45.0)
	if is_instance_valid(grid):
		grid.position = Vector2(
			float(DataLoader.get_setting("grid_x", 285.0)) + _safe_left,
			float(DataLoader.get_setting("grid_y", 148.0)) + _safe_top
		)
	if is_instance_valid(CardManager.container):
		CardManager.container.position = Vector2(330.0 + _safe_left, 62.0 + _safe_top)
	if is_instance_valid(tutorial_label):
		tutorial_label.position = Vector2(viewport_size.x * 0.5 - 329.0, viewport_size.y - _safe_bottom - 48.0)
	if is_instance_valid(tutorial_skip_button):
		tutorial_skip_button.position = Vector2(viewport_size.x * 0.5 + 239.0, viewport_size.y - _safe_bottom - 48.0)

func _build_tutorial_ui() -> void:
	tutorial_label = Label.new()
	tutorial_label.position = Vector2(311, 620)
	tutorial_label.size = Vector2(560, 38)
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.add_theme_font_size_override("font_size", 18)
	tutorial_label.add_theme_color_override("font_color", Color("fff4ce"))
	tutorial_label.add_theme_color_override("font_shadow_color", Color(0.08, 0.12, 0.08, 0.9))
	tutorial_label.add_theme_constant_override("shadow_offset_x", 1)
	tutorial_label.add_theme_constant_override("shadow_offset_y", 2)
	tutorial_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_label.visible = false
	add_child(tutorial_label)
	tutorial_skip_button = Button.new()
	tutorial_skip_button.position = Vector2(879, 620)
	tutorial_skip_button.size = Vector2(90, 34)
	tutorial_skip_button.text = "Bỏ qua"
	tutorial_skip_button.visible = false
	tutorial_skip_button.pressed.connect(_skip_tutorial)
	add_child(tutorial_skip_button)

func _begin_tutorial_if_needed() -> void:
	if SaveSystem.is_tutorial_completed():
		tutorial_label.visible = false
		tutorial_skip_button.visible = false
		return
	if _tutorial_step < 0:
		_tutorial_step = 0
	_update_tutorial_display()

func _advance_tutorial(next_step: int) -> void:
	if _tutorial_step < 0 or next_step <= _tutorial_step:
		return
	_tutorial_step = next_step
	if _tutorial_step >= 2:
		_tutorial_step = -1
		SaveSystem.mark_tutorial_completed()
		tutorial_label.visible = false
		tutorial_skip_button.visible = false
	else:
		_update_tutorial_display()

func _update_tutorial_display() -> void:
	if _tutorial_step == 0:
		tutorial_label.text = "HƯỚNG DẪN 1/2: Chọn một thẻ cây trên thanh hạt giống."
	elif _tutorial_step == 1:
		tutorial_label.text = "HƯỚNG DẪN 2/2: Nhấp vào ô trống phù hợp để trồng cây."
	tutorial_label.visible = _tutorial_step >= 0
	tutorial_skip_button.visible = _tutorial_step >= 0

func _skip_tutorial() -> void:
	_tutorial_step = -1
	SaveSystem.mark_tutorial_completed()
	tutorial_label.visible = false
	tutorial_skip_button.visible = false

func _on_screen_shake_requested(duration: float, magnitude: float) -> void:
	if not is_instance_valid(world_layer):
		return
	if _shake_tween != null and _shake_tween.is_running():
		_shake_tween.kill()
	world_layer.position = Vector2.ZERO
	var total_duration := maxf(0.06, duration)
	var offset_scale := maxf(0.0, magnitude)
	_shake_tween = create_tween()
	for index in range(4):
		var strength := offset_scale * (1.0 - float(index) / 4.0)
		var offset := Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		_shake_tween.tween_property(world_layer, "position", offset, total_duration / 8.0)
		_shake_tween.tween_property(world_layer, "position", Vector2.ZERO, total_duration / 8.0)

func _on_coins_changed(total: int) -> void:
	if is_instance_valid(coins_label):
		coins_label.text = "Xu: %d" % total

func _process(_delta: float) -> void:
	_update_placement_preview()

func _update_placement_preview() -> void:
	if not is_instance_valid(ghost_preview):
		return
	if selected_plant_id.is_empty() or GameManager.state != "playing" or shovel_mode or is_instance_valid(overlay_panel):
		ghost_preview.visible = false
		return
	var cell := grid.world_to_grid(get_global_mouse_position())
	if cell.x < 0 or not grid.can_place_plant(selected_plant_id, cell.x, cell.y):
		ghost_preview.visible = false
		return
	ghost_preview.global_position = grid.get_grid_position(cell.x, cell.y)
	var texture := DataLoader.get_plant_sprite(selected_plant_id)
	if texture != null:
		ghost_sprite.texture = texture
		ghost_sprite.scale = Vector2.ONE * float(DataLoader.get_plant(selected_plant_id).get("sprite_scale", 1.0))
		ghost_sprite.visible = true
		ghost_fallback.visible = false
	else:
		ghost_sprite.visible = false
		ghost_fallback.visible = true
	ghost_preview.visible = true

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

func _toggle_shovel() -> void:
	if GameManager.state != "playing":
		shovel_button.button_pressed = false
		return
	shovel_mode = shovel_button.button_pressed
	if shovel_mode:
		selected_plant_id = ""
		CardManager.clear_selection()
		plant_food_mode = false
		plant_food_button.button_pressed = false
		plant_food_button.text = "Linh Đan ×%d" % GameManager.plant_food_charges
		state_label.text = "Xẻng: nhấp vào cây muốn đào."
	shovel_button.text = "Hủy xẻng" if shovel_mode else "Xẻng"

func _toggle_pause() -> void:
	if GameManager.state != "playing":
		return
	get_tree().paused = not get_tree().paused
	pause_button.text = "Tiếp tục" if get_tree().paused else "Tạm dừng"

func _cycle_game_speed() -> void:
	if GameManager.state != "playing" or get_tree().paused:
		return
	_speed_index = (_speed_index + 1) % GAME_SPEEDS.size()
	Engine.time_scale = float(GAME_SPEEDS[_speed_index])
	speed_button.text = "Tốc độ: %.1fx" % Engine.time_scale

func _reset_game_time() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	if _shake_tween != null and _shake_tween.is_running():
		_shake_tween.kill()
	if is_instance_valid(world_layer):
		world_layer.position = Vector2.ZERO
	_speed_index = 0
	if is_instance_valid(pause_button):
		pause_button.text = "Tạm dừng"
	if is_instance_valid(speed_button):
		speed_button.text = "Tốc độ: 1.0x"
	shovel_mode = false
	if is_instance_valid(shovel_button):
		shovel_button.button_pressed = false
		shovel_button.text = "Xẻng"

func _exit_tree() -> void:
	SaveSystem.save_game()
	Engine.time_scale = 1.0
	get_tree().paused = false

func _start_selected_level() -> void:
	var index := level_selector.selected
	if index < 0 or index >= level_selector.item_count:
		return
	var level_id := str(level_selector.get_item_metadata(index))
	if SaveSystem.is_level_unlocked(level_id):
		_start_level(level_id)

func _clear_sun_pickups() -> void:
	for pickup in get_tree().get_nodes_in_group("sun_pickups"):
		pickup.queue_free()

func _start_level(level_id: String) -> void:
	if _starting_level or not GameManager.start_level(level_id):
		return
	_reset_game_time()
	_starting_level = true
	_level_run_id += 1
	_clear_sun_pickups()
	SunManager.reset()
	wave_manager.stop()
	grid.clear_all()
	grid.configure_level()
	for node in get_tree().get_nodes_in_group("zombies") + get_tree().get_nodes_in_group("projectiles") + get_tree().get_nodes_in_group("lawn_mowers"):
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
	_spawn_lawn_mowers()
	wave_manager.start()
	_begin_tutorial_if_needed()
	_starting_level = false

func _spawn_lawn_mowers() -> void:
	var mower_script := load("res://behaviors/LawnMowerBehavior.gd") as Script
	if mower_script == null:
		push_error("Không tải được LawnMowerBehavior.gd")
		return
	for lane in range(grid.rows):
		var first_cell := grid.get_grid_position(lane, 0)
		var last_cell := grid.get_grid_position(lane, grid.columns - 1)
		var left_edge := first_cell.x - grid.cell_width * 0.5
		var spawn_position := Vector2(left_edge - 30.0, first_cell.y)
		var activation_x := left_edge + grid.cell_width * 0.60
		var exit_x := last_cell.x + grid.cell_width
		var mower := Node2D.new()
		mower.set_script(mower_script)
		mower.name = "LawnMower_Row_%d" % lane
		world_layer.add_child(mower)
		mower.call("setup", lane, spawn_position, activation_x, exit_x)

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
	var pointer_position := Vector2.ZERO
	var primary_pressed := false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pointer_position = event.position
		primary_pressed = event.pressed
	elif event is InputEventScreenTouch:
		pointer_position = event.position
		primary_pressed = event.pressed
	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		return
	else:
		return
	if not primary_pressed or GameManager.state != "playing":
		return

	if shovel_mode:
		var shovel_cell: Vector2i = grid.world_to_grid(pointer_position)
		var removed: Node2D = grid.remove_plant_at(shovel_cell.x, shovel_cell.y) if shovel_cell.x >= 0 else null
		if removed != null:
			if removed.is_in_group("plants"):
				removed.remove_from_group("plants")
			removed.queue_free()
			state_label.text = "Đã đào bỏ cây."
			AudioManager.play("hit")
		else:
			state_label.text = "Ô này không có cây để đào."
		shovel_mode = false
		shovel_button.button_pressed = false
		shovel_button.text = "Xẻng"
		return

	if plant_food_mode:
		for plant in get_tree().get_nodes_in_group("plants"):
			if plant.global_position.distance_to(pointer_position) <= 42.0:
				if not plant.can_activate_plant_food():
					state_label.text = "Cây đang thực hiện Linh Đan."
					return
				if GameManager.spend_plant_food():
					plant.activate_plant_food()
					plant_food_mode = false
					plant_food_button.button_pressed = false
					_on_plant_food_changed(GameManager.plant_food_charges)
				return
		return

	if selected_plant_id.is_empty():
		return
	var cell: Vector2i = grid.world_to_grid(pointer_position)
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
	var pickup_icon_path: String = DataLoader.get_ui_asset("linh_khi", "")
	var pickup_texture: Texture2D = load(pickup_icon_path) as Texture2D if not pickup_icon_path.is_empty() and ResourceLoader.exists(pickup_icon_path) else null
	if pickup_texture != null:
		button.icon = pickup_texture
		button.expand_icon = true
		button.text = ""
	else:
		button.text = "✦"
	button.position = world_position - Vector2(22, 22)
	button.size = Vector2(44, 44)
	button.tooltip_text = "%d Linh Khí" % amount
	button.add_to_group("sun_pickups")
	button.pressed.connect(func():
		GameManager.add_sun(amount)
		AudioManager.play("collect")
		button.queue_free()
	)
	add_child(button)
	var timer := get_tree().create_timer(8.0, false)
	timer.timeout.connect(func():
		if is_instance_valid(button):
			button.queue_free()
	)

func _on_card_selected(plant_id: String) -> void:
	selected_plant_id = plant_id
	plant_food_mode = false
	plant_food_button.button_pressed = false
	if is_instance_valid(shovel_button):
		shovel_mode = false
		shovel_button.button_pressed = false
		shovel_button.text = "Xẻng"
	_update_placement_preview()

func _on_sun_changed(value: int) -> void:
	sun_label.text = "Linh Khí: %d" % value

func _on_plant_food_changed(charges: int) -> void:
	plant_food_button.disabled = charges <= 0
	plant_food_button.text = "Linh Đan ×%d" % charges
	if not plant_food_mode:
		plant_food_button.button_pressed = false

func _on_state_changed(new_state: String) -> void:
	if new_state != "playing":
		_reset_game_time()
		_close_overlay()
	match new_state:
		"lost":
			AudioManager.play("lose")
			state_label.text = "Thất bại — Cương Thi đã đột nhập!"
			_show_restart_button("Thử lại")
		"won":
			AudioManager.play("win")
			state_label.text = "Chiến thắng! Tiến trình đã được lưu."
			_populate_levels()
			_show_restart_button("Chơi lại màn")

func _create_overlay(title_text: String) -> VBoxContainer:
	if is_instance_valid(overlay_panel):
		_close_overlay()
	_overlay_previous_paused = get_tree().paused
	_overlay_previous_time_scale = Engine.time_scale
	_overlay_pause_changed = GameManager.state == "playing"
	if _overlay_pause_changed:
		get_tree().paused = true
	overlay_backdrop = ColorRect.new()
	overlay_backdrop.name = "OverlayBackdrop"
	overlay_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_backdrop.color = Color(0.025, 0.055, 0.04, 0.68)
	overlay_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay_backdrop.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay_backdrop.z_index = 99
	add_child(overlay_backdrop)

	overlay_panel = PanelContainer.new()
	overlay_panel.name = "GameInfoOverlay"
	overlay_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	var viewport_size := get_viewport_rect().size
	var panel_size := Vector2(minf(1080.0, viewport_size.x - 36.0), minf(620.0, viewport_size.y - 36.0))
	overlay_panel.size = panel_size
	overlay_panel.custom_minimum_size = panel_size
	overlay_panel.position = (viewport_size - panel_size) * 0.5
	overlay_panel.z_index = 100
	add_child(overlay_panel)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	overlay_panel.add_child(body)
	var header := HBoxContainer.new()
	body.add_child(header)
	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 24)
	header.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	var close_button := Button.new()
	close_button.text = "Đóng"
	close_button.pressed.connect(_close_overlay)
	header.add_child(close_button)
	return body

func _close_overlay() -> void:
	if is_instance_valid(overlay_panel):
		overlay_panel.queue_free()
	if is_instance_valid(overlay_backdrop):
		overlay_backdrop.queue_free()
	overlay_panel = null
	overlay_backdrop = null
	if _overlay_pause_changed:
		if GameManager.state == "playing":
			get_tree().paused = _overlay_previous_paused
			Engine.time_scale = _overlay_previous_time_scale
		_overlay_pause_changed = false
	_update_placement_preview()

func _open_world_map() -> void:
	var body := _create_overlay("BẢN ĐỒ VẠN GIỚI")
	var hint := Label.new()
	hint.text = "Chọn một vùng đã mở khóa để tiếp tục hành trình."
	body.add_child(hint)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(maxf(260.0, overlay_panel.size.x - 60.0), maxf(180.0, overlay_panel.size.y - 150.0))
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	scroll.add_child(row)
	var ids: Array = DataLoader.get_all_level_ids()
	for index in range(ids.size()):
		var level_id := str(ids[index])
		var level: Dictionary = DataLoader.get_level(level_id)
		var unlocked := SaveSystem.is_level_unlocked(level_id)
		var completed: Array = SaveSystem.save_data.get("completed_levels", [])
		var is_completed := level_id in completed
		var status := "ĐÃ HOÀN THÀNH" if is_completed else ("ĐÃ MỞ KHÓA" if unlocked else "CHƯA MỞ")
		var card := Button.new()
		card.custom_minimum_size = Vector2(190, 285)
		card.text = "%02d\n%s\n\n%s" % [index + 1, str(level.get("name", level_id)), status]
		card.disabled = not unlocked
		card.pressed.connect(_select_map_level.bind(level_id))
		row.add_child(card)

func _select_map_level(level_id: String) -> void:
	_close_overlay()
	for index in range(level_selector.item_count):
		if str(level_selector.get_item_metadata(index)) == level_id:
			level_selector.select(index)
			break
	_start_level(level_id)

func _open_zen_garden() -> void:
	var body := _create_overlay("VƯỜN THIỀN")
	var summary := Label.new()
	summary.text = "Xu hiện có: %d — Chăm đúng nhu cầu để cây trưởng thành và nhận 10 xu." % SaveSystem.get_coins()
	summary.add_theme_font_size_override("font_size", 17)
	body.add_child(summary)
	var hint := Label.new()
	hint.text = "Gieo cây vào chậu trống. Mỗi chậu sẽ yêu cầu một công cụ chăm sóc khác nhau."
	body.add_child(hint)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(maxf(260.0, overlay_panel.size.x - 60.0), maxf(180.0, overlay_panel.size.y - 150.0))
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(row)
	for pot_index in range(ZenGardenManager.POT_COUNT):
		_build_zen_garden_pot_card(pot_index, row)

func _build_zen_garden_pot_card(pot_index: int, parent: HBoxContainer) -> void:
	var pots := ZenGardenManager.get_pots()
	if pot_index >= pots.size():
		return
	var pot: Dictionary = pots[pot_index]
	var plant_id := str(pot.get("plant_id", ""))
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(310, 320)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(card)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	card.add_child(layout)
	var title := Label.new()
	title.text = "CHẬU %d" % (pot_index + 1)
	title.add_theme_font_size_override("font_size", 20)
	layout.add_child(title)
	var feedback := Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(feedback)
	if plant_id.is_empty():
		var selector := OptionButton.new()
		selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var plant_ids: Array = DataLoader.get_all_plant_ids()
		for id_value in plant_ids:
			var id := str(id_value)
			var plant_data: Dictionary = DataLoader.get_plant(id)
			selector.add_item(str(plant_data.get("name", id)))
			selector.set_item_metadata(selector.item_count - 1, id)
		if selector.item_count > 0:
			selector.select(0)
		layout.add_child(selector)
		var sow_button := Button.new()
		sow_button.text = "Gieo cây vào chậu"
		sow_button.pressed.connect(_plant_zen_pot.bind(pot_index, selector, feedback))
		layout.add_child(sow_button)
		return

	var plant_data: Dictionary = DataLoader.get_plant(plant_id)
	var stage := int(pot.get("growth_stage", 1))
	var need := str(pot.get("need", "water"))
	var plant_label := Label.new()
	plant_label.text = "%s\nGiai đoạn: %d/3" % [str(plant_data.get("name", plant_id)), stage]
	plant_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	plant_label.add_theme_font_size_override("font_size", 18)
	layout.add_child(plant_label)
	var need_label := Label.new()
	need_label.text = "Nhu cầu: %s" % _zen_need_name(need)
	need_label.add_theme_color_override("font_color", Color("497c42"))
	layout.add_child(need_label)
	var tools := GridContainer.new()
	tools.columns = 2
	tools.add_theme_constant_override("h_separation", 8)
	tools.add_theme_constant_override("v_separation", 8)
	layout.add_child(tools)
	var tool_data := [
		["Tưới nước", "water"],
		["Bón phân", "fertilizer"],
		["Trừ sâu", "bug_spray"],
		["Phát nhạc", "music"]
	]
	for item in tool_data:
		var tool_button := Button.new()
		tool_button.text = str(item[0])
		tool_button.custom_minimum_size = Vector2(125, 42)
		tool_button.pressed.connect(_use_zen_garden_tool.bind(pot_index, str(item[1]), feedback))
		tools.add_child(tool_button)

func _plant_zen_pot(pot_index: int, selector: OptionButton, feedback: Label) -> void:
	if selector.item_count == 0 or selector.selected < 0:
		feedback.text = "Không có dữ liệu cây để gieo."
		return
	var plant_id := str(selector.get_item_metadata(selector.selected))
	if ZenGardenManager.plant_seed(pot_index, plant_id):
		_refresh_zen_garden()
	else:
		feedback.text = "Không thể gieo cây vào chậu này."

func _use_zen_garden_tool(pot_index: int, tool_type: String, feedback: Label) -> void:
	if ZenGardenManager.fulfill_need(pot_index, tool_type):
		_refresh_zen_garden()
		return
	var pots := ZenGardenManager.get_pots()
	if pot_index >= 0 and pot_index < pots.size():
		var pot: Dictionary = pots[pot_index]
		feedback.text = "Chưa đúng công cụ. Cây cần: %s." % _zen_need_name(str(pot.get("need", "")))
	else:
		feedback.text = "Chậu không hợp lệ."

func _zen_need_name(need: String) -> String:
	match need:
		"water": return "Tưới nước"
		"fertilizer": return "Bón phân"
		"bug_spray": return "Thuốc trừ sâu"
		"music": return "Âm nhạc"
		_: return "Chưa có"

func _refresh_zen_garden() -> void:
	_close_overlay()
	_open_zen_garden()

func _open_almanac(kind: String = "plants") -> void:
	var body := _create_overlay("BÁCH KHOA LINH VIÊN")
	var tabs := HBoxContainer.new()
	body.add_child(tabs)
	var plants_tab := Button.new()
	plants_tab.text = "Linh Thực"
	plants_tab.toggle_mode = true
	plants_tab.button_pressed = kind == "plants"
	plants_tab.pressed.connect(_open_almanac.bind("plants"))
	tabs.add_child(plants_tab)
	var zombies_tab := Button.new()
	zombies_tab.text = "Cương Thi"
	zombies_tab.toggle_mode = true
	zombies_tab.button_pressed = kind == "zombies"
	zombies_tab.pressed.connect(_open_almanac.bind("zombies"))
	tabs.add_child(zombies_tab)

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	body.add_child(content)
	var list_scroll := ScrollContainer.new()
	list_scroll.custom_minimum_size = Vector2(minf(320.0, maxf(120.0, overlay_panel.size.x * 0.32)), maxf(180.0, overlay_panel.size.y - 150.0))
	list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(list_scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_scroll.add_child(list)

	var detail_panel := PanelContainer.new()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(detail_panel)
	var detail_layout := VBoxContainer.new()
	detail_panel.add_child(detail_layout)
	var detail_image := TextureRect.new()
	detail_image.custom_minimum_size = Vector2(150, 150)
	detail_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	detail_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	detail_layout.add_child(detail_image)
	var detail_text := Label.new()
	detail_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_text.add_theme_font_size_override("font_size", 17)
	detail_layout.add_child(detail_text)
	_populate_almanac_list(kind, list, detail_text, detail_image)

func _populate_almanac_list(kind: String, list: VBoxContainer, detail_text: Label, detail_image: TextureRect) -> void:
	var ids: Array = DataLoader.get_all_plant_ids() if kind == "plants" else DataLoader.get_all_zombie_ids()
	for entity_id_value in ids:
		var entity_id := str(entity_id_value)
		var data: Dictionary = DataLoader.get_plant(entity_id) if kind == "plants" else DataLoader.get_zombie(entity_id)
		var entry_button := Button.new()
		entry_button.text = str(data.get("name", entity_id))
		entry_button.custom_minimum_size = Vector2(285, 42)
		entry_button.pressed.connect(_show_almanac_entry.bind(kind, entity_id, detail_text, detail_image))
		list.add_child(entry_button)
	if not ids.is_empty():
		_show_almanac_entry(kind, str(ids[0]), detail_text, detail_image)

func _show_almanac_entry(kind: String, entity_id: String, detail_text: Label, detail_image: TextureRect) -> void:
	var data: Dictionary = DataLoader.get_plant(entity_id) if kind == "plants" else DataLoader.get_zombie(entity_id)
	var lines: PackedStringArray = []
	lines.append(str(data.get("name", entity_id)))
	lines.append("Loại: %s" % str(data.get("type", "Chưa phân loại")))
	if kind == "plants":
		lines.append("Giá: %d Linh Khí" % int(data.get("cost", 0)))
		lines.append("Sinh lực: %.0f" % float(data.get("hp", 0)))
		lines.append("Sát thương: %.0f" % float(data.get("damage", 0)))
		lines.append("Tốc độ đánh: %.2f giây" % float(data.get("fire_rate", 0)))
		var abilities: Dictionary = data.get("abilities", {})
		if not abilities.is_empty():
			lines.append("Kỹ năng: %s" % str(abilities.keys()))
	else:
		lines.append("Sinh lực: %.0f" % float(data.get("hp", 0)))
		lines.append("Tốc độ: %.1f" % float(data.get("speed", 0)))
		lines.append("Sát thương: %.0f" % float(data.get("damage", 0)))
		var armor: Dictionary = data.get("armor", {})
		if not armor.is_empty():
			lines.append("Giáp: %.0f" % float(armor.get("hp", 0)))
		var abilities: Dictionary = data.get("abilities", {})
		if not abilities.is_empty():
			lines.append("Kỹ năng: %s" % str(abilities.keys()))
	lines.append("")
	lines.append(str(data.get("description", "Chưa có mô tả cho mục này.")))
	detail_text.text = "\n".join(lines)
	detail_image.texture = DataLoader.get_plant_sprite(entity_id) if kind == "plants" else DataLoader.get_zombie_sprite(entity_id)

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
	var waves: Array = GameManager.current_level.get("waves", [])
	wave_progress.max_value = maxf(1.0, float(waves.size()))
	wave_progress.value = clampf(float(wave_number), 0.0, wave_progress.max_value)
	state_label.text = "%s — Sóng %d/%d" % [str(GameManager.current_level.get("name", "")), wave_number, waves.size()]
	for wave_value in waves:
		if not wave_value is Dictionary:
			continue
		var wave: Dictionary = wave_value
		if int(wave.get("wave_number", 1)) != wave_number:
			continue
		if bool(wave.get("boss", false)):
			_show_wave_banner("ĐẠI CƯƠNG THI XUẤT HIỆN!", Color("ff7878"))
		elif bool(wave.get("is_final", false)):
			_show_wave_banner("SÓNG CUỐI!", Color("ffca6b"))
		elif int(wave.get("count", 0)) >= 10:
			_show_wave_banner("ĐỢT CƯƠNG THI LỚN ĐANG ĐẾN!", Color("ffe28a"))
		break

func _show_wave_banner(message: String, tint: Color) -> void:
	wave_banner.text = message
	wave_banner.add_theme_color_override("font_color", tint)
	wave_banner.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if _banner_tween != null and _banner_tween.is_running():
		_banner_tween.kill()
	_banner_tween = create_tween()
	_banner_tween.tween_interval(1.35)
	_banner_tween.tween_property(wave_banner, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.55)

func _on_all_waves_finished() -> void:
	wave_progress.value = wave_progress.max_value
	var run_id := _level_run_id
	var level_id := GameManager.current_level_id
	while run_id == _level_run_id and GameManager.state == "playing" and not get_tree().get_nodes_in_group("zombies").is_empty():
		await get_tree().create_timer(0.25, false).timeout
	if run_id == _level_run_id and GameManager.state == "playing" and GameManager.current_level_id == level_id:
		GameManager.win_level()
