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

func setup(id: String, data: Dictionary, row: int) -> void:
	zombie_id = id
	zombie_data = data
	lane = row
	hp = float(data.get("hp", 200))
	speed = float(data.get("speed", 18.0))
	damage = float(data.get("damage", 20))
	attack_rate = max(0.1, float(data.get("attack_rate", 1.0)))
	if data.get("armor", {}) is Dictionary:
		armor_hp = float(data.get("armor", {}).get("hp", 0))
	collision_layer = 4
	collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(34, 58)
	collision.shape = shape
	add_child(collision)
	var texture := DataLoader.get_zombie_sprite(id)
	if texture != null:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.scale = Vector2.ONE * float(data.get("sprite_scale", 1.0))
		add_child(sprite)
	else:
		var fallback := Polygon2D.new()
		fallback.polygon = PackedVector2Array([Vector2(-18, -28), Vector2(18, -28), Vector2(20, 28), Vector2(-20, 28)])
		fallback.color = Color(0.48, 0.50, 0.38)
		add_child(fallback)

func _ready() -> void:
	add_to_group("zombies")

func _process(delta: float) -> void:
	if GameManager.state != "playing":
		return
	attack_timer -= delta
	var target := _find_plant()
	if target != null:
		if attack_timer <= 0.0:
			target.take_damage(damage)
			attack_timer = attack_rate
	else:
		global_position.x -= speed * delta
	if global_position.x < 245.0:
		GameManager.lose_level()

func _find_plant() -> Node:
	for plant in get_tree().get_nodes_in_group("plants"):
		if plant.lane == lane and abs(plant.global_position.x - global_position.x) < 42.0:
			return plant
	return null

func take_damage(amount: float) -> void:
	if armor_hp > 0.0:
		var absorbed := min(armor_hp, amount)
		armor_hp -= absorbed
		amount -= absorbed
	if amount <= 0.0:
		return
	hp -= amount
	if hp <= 0.0:
		remove_from_group("zombies")
		queue_free()
