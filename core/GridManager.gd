class_name GridManager
extends Node2D

signal grid_clicked(row: int, column: int)

const ROWS := 5
const COLUMNS := 9
const CELL_WIDTH := 88.0
const CELL_HEIGHT := 80.0

var occupied: Dictionary = {}

func _ready() -> void:
	position = Vector2(285, 148)
	queue_redraw()

func _draw() -> void:
	for row in range(ROWS):
		for column in range(COLUMNS):
			var rect := Rect2(column * CELL_WIDTH, row * CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT)
			var color := Color(0.18, 0.55, 0.38, 0.28)
			if (row + column) % 2:
				color = Color(0.22, 0.62, 0.46, 0.30)
			draw_rect(rect, color)
			draw_rect(rect, Color(0.12, 0.38, 0.28, 0.9), false, 1.0)

func get_grid_position(row: int, column: int) -> Vector2:
	return position + Vector2(column * CELL_WIDTH + CELL_WIDTH * 0.5, row * CELL_HEIGHT + CELL_HEIGHT * 0.5)

func world_to_grid(world_position: Vector2) -> Vector2i:
	var local_position := world_position - position
	var column := int(floor(local_position.x / CELL_WIDTH))
	var row := int(floor(local_position.y / CELL_HEIGHT))
	if row < 0 or row >= ROWS or column < 0 or column >= COLUMNS:
		return Vector2i(-1, -1)
	return Vector2i(row, column)

func is_empty(row: int, column: int) -> bool:
	return not occupied.has(Vector2i(row, column))

func set_occupied(row: int, column: int, entity: Node) -> void:
	occupied[Vector2i(row, column)] = entity

func clear_cell(row: int, column: int) -> void:
	occupied.erase(Vector2i(row, column))
