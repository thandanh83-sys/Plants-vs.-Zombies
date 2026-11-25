extends Area2D

var damage := 20.0
var lane := 0
var speed := 300.0
var piercing := false
var effect := ""
var projectile_color := Color("1f2424")
var knockback := 0.0
var slow_factor := 0.5
var effect_duration := 3.0
var projectile_style := "basic"
var hit_targets: Array[int] = []
var _amplified := false

func setup(projectile_damage: float, projectile_lane: int, can_pierce: bool = false, projectile_effect: String = "", color: Color = Color("1f2424"), push_distance: float = 0.0, slow_multiplier: float = 0.5, duration: float = 3.0, style: String = "basic") -> void:
	damage = projectile_damage
	lane = projectile_lane
	piercing = can_pierce
	effect = projectile_effect
	projectile_color = color
	knockback = maxf(0.0, push_distance)
	slow_factor = clampf(slow_multiplier, 0.0, 1.0)
	effect_duration = maxf(0.0, duration)
	projectile_style = style
	collision_layer = 8
	collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 8.0
	collision.shape = shape
	add_child(collision)
	_add_visual()
	add_to_group("projectiles")

func _add_visual() -> void:
	var body := Polygon2D.new()
	match projectile_style:
		"ink_bullet":
			body.polygon = PackedVector2Array([
				Vector2(-11, -3), Vector2(-7, -7), Vector2(1, -8),
				Vector2(9, -4), Vector2(11, 0), Vector2(7, 5),
				Vector2(-1, 7), Vector2(-9, 3)
			])
			body.color = Color("263d35")
		"arrow":
			body.polygon = PackedVector2Array([
				Vector2(-12, -3), Vector2(4, -3), Vector2(4, -7),
				Vector2(12, 0), Vector2(4, 7), Vector2(4, 3), Vector2(-12, 3)
			])
			body.color = projectile_color
		_:
			body.polygon = PackedVector2Array([
				Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)
			])
			body.color = projectile_color
	add_child(body)

func _process(delta: float) -> void:
	if GameManager.state != "playing":
		return
	global_position.x += speed * delta
	_apply_projectile_amplifiers()
	for zombie in get_tree().get_nodes_in_group("zombies"):
		var instance_id := zombie.get_instance_id()
		if zombie.lane == lane and not hit_targets.has(instance_id) and absf(zombie.global_position.x - global_position.x) <= 24.0:
			hit_targets.append(instance_id)
			zombie.take_damage(damage)
			if effect == "freeze":
				zombie.apply_status("freeze", effect_duration)
			elif effect == "slow":
				zombie.apply_status("slow", effect_duration, slow_factor)
			if knockback > 0.0 and is_instance_valid(zombie):
				zombie.global_position.x += knockback
			if not piercing:
				queue_free()
				return
	if global_position.x > float(DataLoader.get_setting("projectile_right_limit", 1320.0)):
		queue_free()

func _apply_projectile_amplifiers() -> void:
	if _amplified:
		return
	for plant in get_tree().get_nodes_in_group("plants"):
		if plant.lane != lane:
			continue
		var abilities: Dictionary = plant.plant_data.get("abilities", {})
		var multiplier := float(abilities.get("amplifies_projectiles", 1.0))
		if multiplier > 1.0 and absf(plant.global_position.x - global_position.x) <= 18.0:
			damage *= multiplier
			_amplified = true
			return
