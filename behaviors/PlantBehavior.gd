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
var producer_interval := 8.0
var producer_amount := 25
var plant_age_seconds := 0.0
var growth_stage_index := 0
var armed := false
var is_eating := false
var eating_target: Node2D
var is_platform := false
var _food_busy := false
var _hit_flash_tween: Tween

func setup(id: String, data: Dictionary, row: int, grid_column: int) -> void:
	plant_id = id
	plant_data = data.duplicate(true)
	lane = row
	column = grid_column
	hp = maxf(1.0, float(data.get("hp", 300)))
	max_hp = hp
	damage = maxf(0.0, float(data.get("damage", 20)))
	fire_rate = maxf(0.1, float(data.get("fire_rate", 1.5)))
	producer_interval = maxf(0.1, float(data.get("production_rate", 8.0)))
	producer_amount = maxi(0, int(data.get("sun_amount", 25)))
	var abilities: Dictionary = data.get("abilities", {})
	is_platform = bool(abilities.get("supports_aquatic_plants", false))
	collision_layer = 2
	collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 28.0
	collision.shape = shape
	add_child(collision)
	var texture: Texture2D = DataLoader.get_plant_sprite(id)
	if texture != null:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.scale = Vector2.ONE * float(data.get("sprite_scale", 1.0))
		add_child(sprite)
	else:
		_draw_fallback()

func _ready() -> void:
	add_to_group("plants")
	producer_timer = producer_interval
	var abilities := _abilities()
	if abilities.has("removes_obstacles"):
		var grid := get_tree().current_scene.find_child("GridManager", true, false)
		if grid != null:
			grid.remove_obstacles(str(abilities.get("removes_obstacles", "grave")), int(abilities.get("max_targets", 1)))
	if abilities.has("armed_delay"):
		armed = false
		await get_tree().create_timer(maxf(0.0, float(abilities.get("armed_delay", 3.0))), false).timeout
		if is_inside_tree():
			armed = true

func _draw_fallback() -> void:
	var fallback := Polygon2D.new()
	fallback.polygon = PackedVector2Array([Vector2(0, -30), Vector2(24, -14), Vector2(20, 22), Vector2(-20, 22), Vector2(-24, -14)])
	match str(plant_data.get("category", "")):
		"nam": fallback.color = Color("9b77ca")
		"phu", "an": fallback.color = Color("d94e4e")
		"tien": fallback.color = Color("79bfe8")
		"phong", "thich": fallback.color = Color("8c8f62")
		"hoa": fallback.color = Color("e47762")
		_: fallback.color = Color("3ba55c")
	add_child(fallback)

func _process(delta: float) -> void:
	if GameManager.state != "playing":
		return
	plant_age_seconds += delta
	_update_growth_stage()
	var plant_type := str(plant_data.get("type", "shooter"))
	if plant_type == "producer" or plant_type == "sun":
		producer_timer -= delta
		if producer_timer <= 0.0:
			GameManager.add_sun(producer_amount)
			producer_timer = producer_interval
	if plant_type == "shooter":
		shoot_timer -= delta
		if shoot_timer <= 0.0:
			if str(_abilities().get("attack", "")) == "eat_zombie":
				_try_eat_zombie()
			elif _has_zombie_in_range():
				_shoot()
			shoot_timer = fire_rate
	_process_contact_abilities(delta)

func _update_growth_stage() -> void:
	var stages: Variant = _abilities().get("growth_stages", [])
	if not stages is Array:
		return
	while growth_stage_index < stages.size():
		var stage_value: Variant = stages[growth_stage_index]
		if not stage_value is Dictionary:
			growth_stage_index += 1
			continue
		var stage: Dictionary = stage_value
		if plant_age_seconds < float(stage.get("after_seconds", INF)):
			break
		producer_amount = maxi(0, int(stage.get("sun_amount", producer_amount)))
		producer_interval = maxf(0.1, float(stage.get("production_rate", producer_interval)))
		producer_timer = minf(producer_timer, producer_interval)
		growth_stage_index += 1

func _abilities() -> Dictionary:
	var value: Variant = plant_data.get("abilities", {})
	return value if value is Dictionary else {}

func _process_contact_abilities(delta: float) -> void:
	var abilities := _abilities()
	var nearest := _nearest_zombie()
	if abilities.has("armed_delay"):
		if not armed:
			return
		if nearest != null and absf(nearest.global_position.x - global_position.x) <= float(plant_data.get("trigger_range", 50.0)):
			_explode(damage, float(abilities.get("area_radius", 55.0)), str(abilities.get("area", "radius")))
		return
	if str(plant_data.get("type", "")) == "exploder" and nearest != null:
		if absf(nearest.global_position.x - global_position.x) <= float(plant_data.get("trigger_range", 95.0)):
			var target_mode := str(abilities.get("target", ""))
			if target_mode == "nearest_zombie":
				nearest.take_damage(damage)
				_remove_self()
			else:
				_explode(damage, float(abilities.get("area_radius", 150.0)), str(abilities.get("area", "radius")))
			return
	var contact_damage := float(abilities.get("damage_per_second", 0.0))
	if contact_damage > 0.0:
		for zombie in get_tree().get_nodes_in_group("zombies"):
			if zombie.lane == lane and absf(zombie.global_position.x - global_position.x) <= 42.0:
				zombie.take_damage(contact_damage * delta)

func _is_zombie_visible(zombie: Node2D) -> bool:
	var grid := get_tree().current_scene.find_child("GridManager", true, false)
	if grid != null and grid.has_method("is_obscured_by_fog"):
		return not grid.is_obscured_by_fog(zombie.global_position)
	return true

func _target_lanes() -> Array[int]:
	var result: Array[int] = [lane]
	if bool(_abilities().get("shoot_adjacent_lanes", false)):
		var row_count := maxi(1, int(DataLoader.get_setting("grid_rows", 5)))
		result.clear()
		for target_lane in range(maxi(0, lane - 1), mini(row_count - 1, lane + 1) + 1):
			result.append(target_lane)
	return result

func _has_zombie_in_range() -> bool:
	var range_cells := maxf(0.0, float(plant_data.get("range", 9)))
	var cell_width := maxf(1.0, float(DataLoader.get_setting("cell_width", 88.0)))
	var target_lanes := _target_lanes()
	for zombie in get_tree().get_nodes_in_group("zombies"):
		if zombie.lane in target_lanes and _is_zombie_visible(zombie) and zombie.global_position.x > global_position.x and zombie.global_position.x - global_position.x <= range_cells * cell_width:
			return true
	return false

func _nearest_zombie() -> Node2D:
	var nearest: Node2D
	var nearest_distance := INF
	for zombie in get_tree().get_nodes_in_group("zombies"):
		if zombie.lane == lane and _is_zombie_visible(zombie):
			var distance := absf(zombie.global_position.x - global_position.x)
			if distance < nearest_distance:
				nearest = zombie
				nearest_distance = distance
	return nearest

func _shoot() -> void:
	var abilities := _abilities()
	var projectile_count := maxi(1, int(abilities.get("projectiles_per_attack", 1)))
	var lanes := _target_lanes()
	var projectile_script := load("res://behaviors/ProjectileBehavior.gd") as Script
	if projectile_script == null:
		push_error("Không tải được ProjectileBehavior.gd")
		return
	var piercing := bool(abilities.get("pierces_targets", false))
	var effect := str(abilities.get("status", ""))
	var slow_factor := float(abilities.get("slow_factor", 0.5))
	var duration := float(abilities.get("duration", 3.0))
	var knockback := float(abilities.get("knockback", 0.0))
	var projectile_style := str(plant_data.get("projectile", "basic"))
	var color := Color("1f2424")
	if effect in ["slow", "freeze"]:
		color = Color("91cdf3")
	if str(abilities.get("element", "")) == "fire":
		color = Color("f08b45")
	for target_lane in lanes:
		for shot_index in range(projectile_count):
			var projectile := Area2D.new()
			projectile.set_script(projectile_script)
			var world_parent: Node = get_parent() if get_parent() != null else get_tree().current_scene
			world_parent.add_child(projectile)
			projectile.setup(damage, target_lane, piercing, effect, color, knockback, slow_factor, duration, projectile_style)
			projectile.global_position = global_position + Vector2(28, -6 + shot_index * 5)

func _try_eat_zombie() -> void:
	if is_eating:
		return
	for zombie in get_tree().get_nodes_in_group("zombies"):
		if zombie.lane == lane and _is_zombie_visible(zombie) and absf(zombie.global_position.x - global_position.x) <= 58.0:
			is_eating = true
			eating_target = zombie
			await get_tree().create_timer(maxf(0.1, float(_abilities().get("eat_time", 5.0))), false).timeout
			if is_inside_tree() and is_instance_valid(eating_target):
				eating_target.take_damage(999999.0)
			is_eating = false
			eating_target = null
			shoot_timer = fire_rate
			return

func _explode(amount: float, radius: float, area: String) -> void:
	AudioManager.play("explosion")
	GameEvents.screen_shake_requested.emit(0.22, 7.0)
	var effect_script := load("res://behaviors/EffectBehavior.gd") as Script
	if effect_script != null:
		var world_parent: Node = get_parent() if get_parent() != null else get_tree().current_scene
		var effect_controller := Node.new()
		effect_controller.set_script(effect_script)
		world_parent.add_child(effect_controller)
		effect_controller.connect("finished", Callable(effect_controller, "queue_free"))
		effect_controller.call("play_effect", world_parent, global_position, Color("f08b45"))
	if area == "lane":
		for target in get_tree().get_nodes_in_group("zombies"):
			if target.lane == lane:
				target.take_damage(amount)
	else:
		for target in get_tree().get_nodes_in_group("zombies"):
			if target.global_position.distance_to(global_position) <= radius:
				target.take_damage(amount)
	_remove_self()

func can_activate_plant_food() -> bool:
	return not _food_busy and is_inside_tree()

func activate_plant_food() -> bool:
	if not can_activate_plant_food():
		return false
	_food_busy = true
	var abilities := _abilities()
	var food: Variant = plant_data.get("plant_food", abilities.get("plant_food", ""))
	if food is Dictionary:
		var count := maxi(1, int(food.get("projectiles", food.get("count", 10))))
		var interval := maxf(0.01, float(food.get("interval", 0.05)))
		for i in range(count):
			if not is_inside_tree():
				break
			_shoot()
			await get_tree().create_timer(interval, false).timeout
	elif food is String:
		match str(food):
			"restore_full_hp":
				hp = max_hp
			"freeze_lane":
				for target in get_tree().get_nodes_in_group("zombies"):
					if target.lane == lane:
						target.apply_status("freeze", 3.0)
			"eat_three_zombies":
				var eaten := 0
				for target in get_tree().get_nodes_in_group("zombies"):
					if target.lane == lane and eaten < 3:
						target.take_damage(999999.0)
						eaten += 1
			"lane_explosion":
				_explode(maxf(damage, 1800.0), 0.0, "lane")
			"heavy_smash":
				var nearest := _nearest_zombie()
				if nearest != null:
					nearest.take_damage(maxf(damage, 1800.0))
	else:
		if str(plant_data.get("type", "")) == "shooter":
			for i in range(8):
				if not is_inside_tree():
					break
				_shoot()
				await get_tree().create_timer(0.06, false).timeout
		else:
			hp = max_hp
	_food_busy = false
	return true

func take_damage(amount: float) -> void:
	var applied := maxf(0.0, amount)
	if applied <= 0.0:
		return
	_flash_damage()
	hp -= applied
	if hp <= 0.0:
		_remove_self()

func _flash_damage() -> void:
	if _hit_flash_tween != null and _hit_flash_tween.is_running():
		_hit_flash_tween.kill()
	_hit_flash_tween = create_tween()
	_hit_flash_tween.tween_property(self, "modulate", Color(1.0, 0.62, 0.62, 1.0), 0.035)
	_hit_flash_tween.tween_property(self, "modulate", Color.WHITE, 0.09)

func _remove_self() -> void:
	var grid := get_tree().current_scene.find_child("GridManager", true, false)
	if grid != null:
		grid.clear_cell(lane, column, is_platform)
	remove_from_group("plants")
	queue_free()
