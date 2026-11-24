extends Area2D

var damage := 20.0
var lane := 0
var speed := 260.0
var piercing := false
var effect := ""
var projectile_color := Color("1f2424")

func setup(projectile_damage: float, projectile_lane: int, can_pierce: bool = false, projectile_effect: String = "", color: Color = Color("1f2424")) -> void:
	damage = projectile_damage
	lane = projectile_lane
	piercing = can_pierce
	effect = projectile_effect
	projectile_color = color
	collision_layer = 8
	collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 8.0
	collision.shape = shape
	add_child(collision)
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)])
	body.color = projectile_color
	add_child(body)

func _process(delta: float) -> void:
	if GameManager.state != "playing":
		return
	global_position.x += speed * delta
	for zombie in get_tree().get_nodes_in_group("zombies"):
		if zombie.lane == lane and abs(zombie.global_position.x - global_position.x) < 24.0:
			zombie.take_damage(damage)
			if effect == "freeze":
				zombie.apply_status("freeze", 3.0)
			if not piercing:
				queue_free()
				return
	if global_position.x > 1320.0:
		queue_free()
