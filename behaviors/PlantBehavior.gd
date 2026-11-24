extends Area2D

var plant_id := ""
var plant_data: Dictionary = {}
var lane := 0
var column := 0
var hp := 300.0
var damage := 20.0
var fire_rate := 1.5
var shoot_timer := 0.0
var producer_timer := 0.0

func setup(id: String, data: Dictionary, row: int, grid_column: int) -> void:
	plant_id = id
	plant_data = data
	lane = row
	column = grid_column
	hp = float(data.get("hp", 300))
	damage = float(data.get("damage", 20))
	fire_rate = max(0.1, float(data.get("fire_rate", 1.5)))
	collision_layer = 2
	collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 25.0
	collision.shape = shape
	add_child(collision)
	var texture := DataLoader.get_plant_sprite(id)
	if texture != null:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.scale = Vector2.ONE * float(data.get("sprite_scale", 1.0))
		add_child(sprite)
	else:
		var fallback := Polygon2D.new()
		fallback.polygon = PackedVector2Array([Vector2(0, -28), Vector2(22, -12), Vector2(18, 20), Vector2(-18, 20), Vector2(-22, -12)])
		fallback.color = Color(0.20, 0.65, 0.38)
		add_child(fallback)

func _ready() -> void:
	add_to_group("plants")
	producer_timer = float(plant_data.get("production_rate", 8.0))

func _process(delta: float) -> void:
	if GameManager.state != "playing":
		return
	shoot_timer -= delta
	producer_timer -= delta
	var plant_type := str(plant_data.get("type", "shooter"))
	if plant_type == "shooter" and shoot_timer <= 0.0 and _has_zombie_in_range():
		_shoot()
		shoot_timer = fire_rate
	if plant_type in ["producer", "sun"] and producer_timer <= 0.0:
		GameManager.add_sun(int(plant_data.get("sun_amount", 25)))
		producer_timer = max(0.1, float(plant_data.get("production_rate", 8.0)))
	if plant_type == "exploder":
		var zombie := _nearest_zombie()
		if zombie != null and abs(zombie.global_position.x - global_position.x) < 95.0:
			for target in get_tree().get_nodes_in_group("zombies"):
				if abs(target.lane - lane) <= 1 and abs(target.global_position.x - global_position.x) < 110.0:
					target.take_damage(damage)
			remove_from_group("plants")
			queue_free()

func _has_zombie_in_range() -> bool:
	var max_range := float(plant_data.get("range", 9)) * 88.0
	for zombie in get_tree().get_nodes_in_group("zombies"):
		if zombie.lane == lane and zombie.global_position.x > global_position.x and zombie.global_position.x - global_position.x <= max_range:
			return true
	return false

func _nearest_zombie() -> Node:
	var nearest: Node = null
	var nearest_distance := INF
	for zombie in get_tree().get_nodes_in_group("zombies"):
		if zombie.lane == lane:
			var distance := abs(zombie.global_position.x - global_position.x)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest = zombie
	return nearest

func _shoot() -> void:
	var projectile := Area2D.new()
	projectile.set_script(load("res://behaviors/ProjectileBehavior.gd"))
	projectile.setup(damage, lane)
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + Vector2(28, -6)

func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0.0:
		var grid := get_tree().current_scene.find_child("GridManager", true, false)
		if grid != null:
			grid.clear_cell(lane, column)
		remove_from_group("plants")
		queue_free()
