extends Node2D

signal grid_clicked(row: int, column: int)

var rows := 5
var columns := 9
var cell_width := 88.0
var cell_height := 80.0
var occupied: Dictionary = {}

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

func _draw() -> void:
	for row in range(rows):
		for column in range(columns):
			var rect := Rect2(column * cell_width, row * cell_height, cell_width, cell_height)
			var color := Color(0.18, 0.55, 0.38, 0.28)
			if (row + column) % 2 == 1:
				color = Color(0.22, 0.62, 0.46, 0.30)
			draw_rect(rect, color)
			draw_rect(rect, Color(0.12, 0.38, 0.28, 0.9), false, 1.0)

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
	return _is_valid_cell(row, column) and not occupied.has(Vector2i(row, column))

func set_occupied(row: int, column: int, entity: Node) -> bool:
	if not _is_valid_cell(row, column) or not is_empty(row, column):
		return false
	occupied[Vector2i(row, column)] = weakref(entity)
	return true

func clear_cell(row: int, column: int) -> void:
	occupied.erase(Vector2i(row, column))

func _is_valid_cell(row: int, column: int) -> bool:
	return row >= 0 and row < rows and column >= 0 and column < columns
