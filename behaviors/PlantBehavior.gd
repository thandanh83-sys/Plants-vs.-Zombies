extends Area2D

signal plant_clicked(plant: Node)

var plant_id := ""
var plant_data: Dictionary = {}
var lane := 0
var column := 0
var hp := 300.0
var max_hp := 300.0
var damage := 20.0
var fire_rate := 1.5
var shoot_timer := 0.0
var producer_timer := 0.0
var special_timer := 0.0
var armed := false
var is_eating := false
var eating_target: Node = null

func setup(id: String, data: Dictionary, row: int, grid_column: int) -> void:
	plant_id = id
	plant_data = data
	lane = row
	column = grid_column
	hp = float(data.get("hp", 300))
	max_hp = hp
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
		_draw_fallback()

func _draw_fallback() -> void:
	var fallback := Polygon2D.new()
	fallback.polygon = PackedVector2Array([Vector2(0, -30), Vector2(24, -14), Vector2(20, 22), Vector2(-20, 22), Vector2(-24, -14)])
	fallback.color = _fallback_color()
	add_child(fallback)

func _fallback_color() -> Color:
	match plant_id:
		"nhat-nguyet-thao": return Color("6cc46a")
		"truc-tien": return Color("2d8f57")
		"kim-cang-thu", "kim-cang-dai": return Color("8c8f62")
		"hong-lien-no", "hoa-long-phu": return Color("d94e4e")
		"han-bang-tien": return Color("79bfe8")
		"doc-vu-nam": return Color("9b77ca")
		_: return Color("3ba55c")

func _ready() -> void:
	add_to_group("plants")
	producer_timer = float(plant_data.get("production_rate", 8.0))
	if plant_id == "dia-loi-phu":
		armed = false
		special_timer = float(plant_data.get("abilities", {}).get("armed_delay", 3.0))

func _process(delta: float) -> void:
	if GameManager.state != "playing":
		return
	shoot_timer -= delta
	producer_timer -= delta
	_special_process(delta)
	var plant_type := str(plant_data.get("type", "shooter"))
	if plant_type == "shooter" and shoot_timer <= 0.0:
		if plant_id == "thuc-nhan-hoa":
			_try_eat_zombie()
		elif _has_zombie_in_range():
			_shoot()
		shoot_timer = fire_rate
	if plant_type in ["producer", "sun"] and producer_timer <= 0.0:
		GameManager.add_sun(int(plant_data.get("sun_amount", 25)))
		producer_timer = max(0.1, float(plant_data.get("production_rate", 8.0)))

func _special_process(delta: float) -> void:
	var zombie := _nearest_zombie()
	if plant_id == "dia-loi-phu":
		special_timer -= delta
		if special_timer <= 0.0:
			armed = true
		if armed and zombie != null and abs(zombie.global_position.x - global_position.x) < 55.0:
			_explode_radius(1800.0, 110.0)
	elif plant_id in ["hong-lien-no", "hoa-long-phu", "tran-son-an"]:
		if zombie != null and abs(zombie.global_position.x - global_position.x) < (140.0 if plant_id == "hoa-long-phu" else 95.0):
			if plant_id == "hoa-long-phu":
				_explode_lane(damage)
			else:
				_explode_radius(damage, 150.0)
	elif plant_id == "dia-thich":
		for target in get_tree().get_nodes_in_group("zombies"):
			if target.lane == lane and abs(target.global_position.x - global_position.x) < 38.0:
				target.take_damage(damage * delta)

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
				nearest = zombie
				nearest_distance = distance
	return nearest

func _shoot() -> void:
	var projectiles := 1
	if plant_id == "song-tien-truc":
		projectiles = 2
	elif plant_id == "tam-tien-truc":
		projectiles = 3
	var lanes_to_shoot: Array[int] = [lane]
	if plant_id == "tam-tien-truc":
		lanes_to_shoot = [lane]
		if lane > 0:
			lanes_to_shoot.append(lane - 1)
		if lane < 4:
			lanes_to_shoot.append(lane + 1)
	for target_lane in lanes_to_shoot:
		for shot_index in range(projectiles):
			var projectile := Area2D.new()
			projectile.set_script(load("res://behaviors/ProjectileBehavior.gd"))
			var shot_damage := damage
			var piercing := plant_id == "doc-vu-nam"
			var effect := ""
			var color := Color("1f2424")
			if plant_id == "han-bang-tien":
				effect = "freeze"
				color = Color("91cdf3")
			elif plant_id == "liet-hoa-tru":
				shot_damage *= 2.0
				color = Color("f08b45")
			elif plant_id == "tam-tien-truc":
				color = Color("63a679")
			projectile.setup(shot_damage, target_lane, piercing, effect, color)
			get_tree().current_scene.add_child(projectile)
			projectile.global_position = global_position + Vector2(28, -6 + shot_index * 5)

func _try_eat_zombie() -> void:
	if is_eating:
		return
	for zombie in get_tree().get_nodes_in_group("zombies"):
		if zombie.lane == lane and abs(zombie.global_position.x - global_position.x) < 58.0:
			is_eating = true
			eating_target = zombie
			var tween := create_tween()
			tween.tween_interval(0.8)
			tween.finished.connect(_finish_eating)
			break

func _finish_eating() -> void:
	if is_instance_valid(eating_target):
		eating_target.take_damage(99999.0)
	is_eating = false
	shoot_timer = 5.0

func _explode_radius(amount: float, radius: float) -> void:
	for target in get_tree().get_nodes_in_group("zombies"):
		if target.global_position.distance_to(global_position) <= radius:
			target.take_damage(amount)
	_remove_self()

func _explode_lane(amount: float) -> void:
	for target in get_tree().get_nodes_in_group("zombies"):
		if target.lane == lane:
			target.take_damage(amount)
	_remove_self()

func activate_plant_food() -> void:
	if plant_id == "nhat-nguyet-thao":
		for i in range(3):
			GameManager.add_sun(int(plant_data.get("sun_amount", 25)))
	elif plant_id == "truc-tien":
		for i in range(30):
			_shoot()
			await get_tree().create_timer(0.05).timeout
	elif plant_id in ["kim-cang-thu", "kim-cang-dai"]:
		hp = max_hp
	elif plant_id == "han-bang-tien":
		for target in get_tree().get_nodes_in_group("zombies"):
			if target.lane == lane:
				target.apply_status("freeze", 3.0)
	elif plant_id == "thuc-nhan-hoa":
		var eaten := 0
		for target in get_tree().get_nodes_in_group("zombies"):
			if target.lane == lane and eaten < 3:
				target.take_damage(99999.0)
				eaten += 1
	elif plant_id in ["hong-lien-no", "dia-loi-phu", "hoa-long-phu", "tran-son-an"]:
		_explode_radius(damage if damage > 0 else 1800.0, 220.0)

func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0.0:
		_remove_self()

func _remove_self() -> void:
	var grid := get_tree().current_scene.find_child("GridManager", true, false)
	if grid != null:
		grid.clear_cell(lane, column)
	remove_from_group("plants")
	queue_free()
