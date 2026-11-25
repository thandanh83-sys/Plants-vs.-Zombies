class_name GridManager
extends Node2D

signal grid_clicked(row: int, column: int)

var rows := 5
var columns := 9
var cell_width := 88.0
var cell_height := 80.0
var occupied: Dictionary = {}
var platforms: Dictionary = {}
var obstacles: Dictionary = {}

func _ready() -> void:
	position = Vector2(
		float(DataLoader.get_setting("grid_x", 285.0)),
		float(DataLoader.get_setting("grid_y", 148.0))
	)
	rows = maxi(1, int(DataLoader.get_setting("grid_rows", rows)))
	columns = maxi(1, int(DataLoader.get_setting("grid_columns", columns)))
	cell_width = maxf(1.0, float(DataLoader.get_setting("cell_width", cell_width)))
	cell_height = maxf(1.0, float(DataLoader.get_setting("cell_height", cell_height)))
	queue_redraw()

func configure_level() -> void:
	obstacles.clear()
	var mechanics: Array = GameManager.current_level.get("special_mechanics", [])
	if "graves" in mechanics:
		for row in [0, 2, 4]:
			if row < rows:
				obstacles[Vector2i(row, 4)] = "grave"
	queue_redraw()

func _draw() -> void:
	var water_lanes: Array = GameManager.current_level.get("water_lanes", [])
	var mechanics: Array = GameManager.current_level.get("special_mechanics", [])
	var environment := str(GameManager.current_level.get("environment", "day"))
	for row in range(rows):
		var is_water := row in water_lanes
		for column in range(columns):
			var rect := Rect2(column * cell_width, row * cell_height, cell_width, cell_height)
			var base := Color("7fbac5") if is_water else Color("b8d5ae")
			if environment == "roof":
				base = Color("c9b7a0")
			var color := base.darkened(0.04) if (row + column) % 2 == 1 else base
			draw_rect(rect, color)
			draw_rect(rect, Color(0.12, 0.38, 0.28, 0.65), false, 1.0)
			if environment == "roof":
				var seam_y := rect.position.y + cell_height * 0.72
				draw_line(Vector2(rect.position.x + 5.0, seam_y), Vector2(rect.position.x + cell_width - 5.0, seam_y - 5.0), Color("a28d76"), 2.0)
				if (row + column) % 2 == 0:
					draw_line(Vector2(rect.position.x + cell_width * 0.5, rect.position.y + 5.0), Vector2(rect.position.x + cell_width * 0.5 - 4.0, seam_y - 5.0), Color("ad9880"), 1.0)
	for key in obstacles:
		var center := Vector2((key.y + 0.5) * cell_width, (key.x + 0.5) * cell_height)
		draw_circle(center, 21.0, Color("77756c"))
		draw_arc(center, 21.0, 0.0, TAU, 24, Color("514f49"), 3.0)
	if "fog_covers_three_right_columns" in mechanics:
		var fog_x := maxf(0.0, (columns - 3) * cell_width)
		draw_rect(Rect2(fog_x, 0.0, 3.0 * cell_width, rows * cell_height), Color(0.72, 0.78, 0.82, 0.32))

func is_obscured_by_fog(world_position: Vector2) -> bool:
	var mechanics: Array = GameManager.current_level.get("special_mechanics", [])
	if not mechanics.has("fog_covers_three_right_columns"):
		return false
	var cell := world_to_grid(world_position)
	return cell.x >= 0 and cell.y >= columns - 3

func get_grid_position(row: int, column: int) -> Vector2:
	if not _is_valid_cell(row, column):
		return global_position
	return to_global(Vector2((column + 0.5) * cell_width, (row + 0.5) * cell_height))

func world_to_grid(world_position: Vector2) -> Vector2i:
	var local_position := to_local(world_position)
	var column := floori(local_position.x / cell_width)
	var row := floori(local_position.y / cell_height)
	if not _is_valid_cell(row, column):
		return Vector2i(-1, -1)
	return Vector2i(row, column)

func is_empty(row: int, column: int) -> bool:
	var key := Vector2i(row, column)
	return _is_valid_cell(row, column) and not occupied.has(key) and not obstacles.has(key)

func can_place_plant(plant_id: String, row: int, column: int) -> bool:
	if not is_empty(row, column):
		return false
	var data: Dictionary = DataLoader.get_plant(plant_id)
	if data.is_empty():
		return false
	var abilities: Dictionary = data.get("abilities", {})
	var water_lanes: Array = GameManager.current_level.get("water_lanes", [])
	var is_water := row in water_lanes
	var is_platform := bool(abilities.get("supports_aquatic_plants", false))
	var requires_water := bool(abilities.get("requires_water", false)) or bool(abilities.get("water_only", false))
	var lily_pad_required: bool = "lily_pad_required" in GameManager.current_level.get("special_mechanics", [])
	var key := Vector2i(row, column)
	if bool(abilities.get("night_only", false)) and str(GameManager.current_level.get("environment", "")) != "night":
		return false
	if requires_water and not is_water:
		return false
	if is_platform:
		return is_water and not platforms.has(key)
	if is_water:
		return platforms.has(key) if lily_pad_required else true
	return not requires_water

func set_occupied(row: int, column: int, entity: Node, is_platform: bool = false) -> bool:
	var key := Vector2i(row, column)
	if not is_empty(row, column):
		return false
	if is_platform:
		if platforms.has(key):
			return false
		platforms[key] = weakref(entity)
	else:
		var water_lanes: Array = GameManager.current_level.get("water_lanes", [])
		var lily_pad_required: bool = "lily_pad_required" in GameManager.current_level.get("special_mechanics", [])
		if row in water_lanes and lily_pad_required and not platforms.has(key):
			return false
		occupied[key] = weakref(entity)
	return true

func get_plant_at(row: int, column: int) -> Node2D:
	if not _is_valid_cell(row, column):
		return null
	var key := Vector2i(row, column)
	if occupied.has(key):
		var occupied_reference: WeakRef = occupied[key]
		var occupied_node := occupied_reference.get_ref()
		if occupied_node is Node2D:
			return occupied_node
	if platforms.has(key):
		var platform_reference: WeakRef = platforms[key]
		var platform_node := platform_reference.get_ref()
		if platform_node is Node2D:
			return platform_node
	return null

func remove_plant_at(row: int, column: int) -> Node2D:
	if not _is_valid_cell(row, column):
		return null
	var key := Vector2i(row, column)
	# Remove the top plant first; the aquatic platform underneath remains.
	if occupied.has(key):
		var occupied_reference: WeakRef = occupied[key]
		occupied.erase(key)
		var occupied_node := occupied_reference.get_ref()
		return occupied_node if occupied_node is Node2D else null
	if platforms.has(key):
		var platform_reference: WeakRef = platforms[key]
		platforms.erase(key)
		var platform_node := platform_reference.get_ref()
		return platform_node if platform_node is Node2D else null
	return null

func clear_cell(row: int, column: int, is_platform: bool = false) -> void:
	var key := Vector2i(row, column)
	if is_platform:
		platforms.erase(key)
		if occupied.has(key):
			var reference: WeakRef = occupied[key]
			if reference.get_ref() != null:
				reference.get_ref().queue_free()
			occupied.erase(key)
	else:
		occupied.erase(key)

func remove_obstacles(kind: String = "grave", max_targets: int = 3) -> int:
	var removed := 0
	for key in obstacles.keys():
		if removed >= max_targets:
			break
		if str(obstacles[key]) == kind:
			obstacles.erase(key)
			removed += 1
	queue_redraw()
	return removed

func clear_all() -> void:
	for collection in [occupied, platforms]:
		for key in collection.keys():
			var reference: WeakRef = collection[key]
			if reference.get_ref() != null:
				reference.get_ref().queue_free()
		collection.clear()
	obstacles.clear()

func _is_valid_cell(row: int, column: int) -> bool:
	return row >= 0 and row < rows and column >= 0 and column < columns
