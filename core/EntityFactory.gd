class_name EntityFactory
extends Node

const DEFAULT_PLANT_SCRIPT := "res://behaviors/PlantBehavior.gd"
const DEFAULT_ZOMBIE_SCRIPT := "res://behaviors/ZombieBehavior.gd"

func spawn_plant(plant_id: String, row: int, column: int, world_position: Vector2) -> Node2D:
	var data := DataLoader.get_plant(plant_id)
	if data.is_empty():
		push_warning("Unknown plant ID: " + plant_id)
		return null
	var script_path := str(data.get("behavior_script", DEFAULT_PLANT_SCRIPT))
	var script_resource := load(script_path) as Script
	if script_resource == null:
		push_error("Cannot load plant behavior script: " + script_path)
		return null
	var plant := Area2D.new()
	plant.set_script(script_resource)
	plant.name = plant_id
	plant.call("setup", plant_id, data, row, column)
	get_tree().current_scene.add_child(plant)
	plant.global_position = world_position
	return plant

func spawn_zombie(zombie_id: String, lane: int, spawn_position: Vector2 = Vector2(-1, -1)) -> Node2D:
	var data := DataLoader.get_zombie(zombie_id)
	if data.is_empty():
		push_warning("Unknown zombie ID: " + zombie_id)
		return null
	var script_path := str(data.get("behavior_script", DEFAULT_ZOMBIE_SCRIPT))
	var script_resource := load(script_path) as Script
	if script_resource == null:
		push_error("Cannot load zombie behavior script: " + script_path)
		return null
	var zombie := Area2D.new()
	zombie.set_script(script_resource)
	zombie.name = zombie_id
	zombie.call("setup", zombie_id, data, lane)
	get_tree().current_scene.add_child(zombie)
	if spawn_position.x < 0.0:
		var grid_left := float(DataLoader.get_setting("grid_x", 285.0))
		var cell_width := float(DataLoader.get_setting("cell_width", 88.0))
		spawn_position.x = grid_left + cell_width * float(DataLoader.get_setting("grid_columns", 9)) + 40.0
		spawn_position.y = float(DataLoader.get_setting("grid_y", 148.0)) + lane * float(DataLoader.get_setting("cell_height", 80.0)) + 40.0
	zombie.global_position = spawn_position
	return zombie
