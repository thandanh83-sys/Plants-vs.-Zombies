extends Node2D

var lane := 0
var move_speed := 950.0
var trigger_x := 0.0
var destroy_x := 0.0
var is_active := false
var hit_zombie_ids: Dictionary = {}

func setup(row: int, spawn_position: Vector2, activation_position_x: float, exit_position_x: float) -> void:
	lane = row
	global_position = spawn_position
	trigger_x = activation_position_x
	destroy_x = exit_position_x
	z_index = 8
	add_to_group("lawn_mowers")
	queue_redraw()

func _process(delta: float) -> void:
	if GameManager.state != "playing":
		return
	if not is_active:
		for zombie in get_tree().get_nodes_in_group("zombies"):
			if is_instance_valid(zombie) and zombie.lane == lane and zombie.global_position.x <= trigger_x:
				_activate()
				break
	if not is_active:
		return
	global_position.x += move_speed * delta
	for zombie in get_tree().get_nodes_in_group("zombies"):
		if not is_instance_valid(zombie) or zombie.lane != lane:
			continue
		var instance_id := zombie.get_instance_id()
		if hit_zombie_ids.has(instance_id):
			continue
		if absf(zombie.global_position.x - global_position.x) <= 66.0:
			hit_zombie_ids[instance_id] = true
			zombie.take_damage(1000000.0)
	if global_position.x >= destroy_x:
		queue_free()

func _activate() -> void:
	is_active = true
	AudioManager.play("explosion")
	GameEvents.screen_shake_requested.emit(0.16, 5.0)

func _draw() -> void:
	draw_rect(Rect2(Vector2(-24, -11), Vector2(48, 18)), Color("527c3c"))
	draw_rect(Rect2(Vector2(-18, -16), Vector2(34, 7)), Color("9bc45e"))
	draw_circle(Vector2(-15, 9), 7.0, Color("353535"))
	draw_circle(Vector2(15, 9), 7.0, Color("353535"))
	draw_line(Vector2(-5, -15), Vector2(7, -23), Color("d9d5ba"), 3.0)
	draw_line(Vector2(7, -23), Vector2(17, -23), Color("d9d5ba"), 3.0)
