class_name EntityFactory
extends Node

func spawn_plant(plant_id: String, row: int, column: int, world_position: Vector2) -> Node2D:
	var data := DataLoader.get_plant(plant_id)
	if data.is_empty():
		return null

	var plant_script := load("res://behaviors/PlantBehavior.gd")
	var plant: Node2D = Area2D.new()
	plant.set_script(plant_script)
	plant.setup(plant_id, data, row, column)
	plant.global_position = world_position
	get_tree().current_scene.add_child(plant)
	return plant

func spawn_zombie(zombie_id: String, lane: int) -> Node2D:
	var data := DataLoader.get_zombie(zombie_id)
	if data.is_empty():
		push_warning("Thiếu dữ liệu zombie: " + zombie_id)
		return null

	var zombie_script := load("res://behaviors/ZombieBehavior.gd")
	var zombie: Node2D = Area2D.new()
	zombie.set_script(zombie_script)
	zombie.setup(zombie_id, data, lane)
	zombie.global_position = Vector2(1235, 148.0 + lane * 80.0 + 40.0)
	get_tree().current_scene.add_child(zombie)
	return zombie
