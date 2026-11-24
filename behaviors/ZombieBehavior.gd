extends Area2D

var zombie_id := ""
var zombie_data: Dictionary = {}
var lane := 0
var hp := 200.0
var armor_hp := 0.0
var speed := 18.0
var damage := 20.0
var attack_rate := 1.0
var attack_timer := 0.0

var fallback_shape: Polygon2D

func setup(id: String, data: Dictionary, row: int) -> void:
	zombie_id = id
	zombie_data = data
	lane = row
	hp = float(data.get("hp", 200))
	speed = float(data.get("speed", 18.0))
	damage = float(data.get("damage", 20))
	attack_rate = float(data.get("attack_rate", 1.0))
	if data.has("armor"):
		armor_hp = float(data["armor"].get("hp", 0))

	collision_layer = 4
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(34, 58)
	collision.shape = shape
	add_child(collision)

	fallback_shape = Polygon2D.new()
	fallback_shape.polygon = PackedVector2Array([Vector2(-18,-28), Vector2(18,-28), Vector2(20,28), Vector2(-20,28)])
	fallback_shape.color = Color(0.48, 0.50, 0.38)
	add_child(fallback_shape)

	var texture := DataLoader.get_zombie_sprite(id)
	if texture:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.scale = Vector2.ONE * float(data.get("sprite_scale", 1.0))
		fallback_shape.queue_free()
		add_child(sprite)

func _ready() -> void:
	add_to_group("zombies")

func _process(delta: float) -> void:
	attack_timer -= delta
	var target := _find_plant()
	if target:
		if attack_timer <= 0:
			target.take_damage(damage)
			attack_timer = attack_rate
	else:
		global_position.x -= speed * delta

	if global_position.x < -40:
		queue_free()
		GameManager._set_state("lost")

func _find_plant() -> Node:
	for plant in get_tree().get_nodes_in_group("plants"):
		if plant.lane == lane and abs(plant.global_position.x - global_position.x) < 42:
			return plant
	return null

func take_damage(amount: float) -> void:
	if armor_hp > 0:
		var absorbed := min(armor_hp, amount)
		armor_hp -= absorbed
		amount -= absorbed
	if amount <= 0:
		return
	hp -= amount
	if hp <= 0:
		remove_from_group("zombies")
		queue_free()
