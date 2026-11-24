extends Node2D

signal grid_clicked(row: int, column: int)

var rows := 5
var columns := 9
var cell_width := 88.0
var cell_height := 80.0
var occupied: Dictionary = {}

func _ready() -> void:
	position = Vector2(285, 148)
	rows = int(DataLoader.get_setting("grid_rows", rows))
	columns = int(DataLoader.get_setting("grid_columns", columns))
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
	return to_global(Vector2(column * cell_width + cell_width * 0.5, row * cell_height + cell_height * 0.5))

func world_to_grid(world_position: Vector2) -> Vector2i:
	var local_position := to_local(world_position)
	var column := int(floor(local_position.x / cell_width))
	var row := int(floor(local_position.y / cell_height))
	if row < 0 or row >= rows or column < 0 or column >= columns:
		return Vector2i(-1, -1)
	return Vector2i(row, column)

func is_empty(row: int, column: int) -> bool:
	return row >= 0 and row < rows and column >= 0 and column < columns and not occupied.has(Vector2i(row, column))

func set_occupied(row: int, column: int, entity: Node) -> void:
	occupied[Vector2i(row, column)] = entity

func clear_cell(row: int, column: int) -> void:
	occupied.erase(Vector2i(row, column))
