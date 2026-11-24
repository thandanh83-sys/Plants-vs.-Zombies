class_name EntityFactory
extends Node

func spawn_plant(plant_id: String, row: int, column: int, world_position: Vector2) -> Node2D:
	var data := DataLoader.get_plant(plant_id)
	if data.is_empty():
		push_warning("Thiếu dữ liệu cây: " + plant_id)
		return null
	var plant := Area2D.new()
	plant.set_script(load("res://behaviors/PlantBehavior.gd"))
	plant.setup(plant_id, data, row, column)
	get_tree().current_scene.add_child(plant)
	plant.global_position = world_position
	return plant

func spawn_zombie(zombie_id: String, lane: int) -> Node2D:
	var data := DataLoader.get_zombie(zombie_id)
	if data.is_empty():
		push_warning("Thiếu dữ liệu zombie: " + zombie_id)
		return null
	var zombie := Area2D.new()
	zombie.set_script(load("res://behaviors/ZombieBehavior.gd"))
	zombie.setup(zombie_id, data, lane)
	get_tree().current_scene.add_child(zombie)
	zombie.global_position = Vector2(1235, 148.0 + lane * 80.0 + 40.0)
	return zombie
