extends Area2D

var zombie_id := ""
var zombie_data: Dictionary = {}
var lane := 0
var hp := 200.0
var max_hp := 200.0
var armor_hp := 0.0
var speed := 16.0
var base_speed := 16.0
var damage := 20.0
var attack_rate := 1.0
var attack_timer := 0.0
var newspaper_broken := false
var slowed_timer := 0.0
var frozen_timer := 0.0
var has_vaulted := false
var status_label: Label

func setup(id: String, data: Dictionary, row: int) -> void:
	zombie_id = id
	zombie_data = data
	lane = row
	hp = float(data.get("hp", 200))
	max_hp = hp
	base_speed = float(data.get("speed", 16.0))
	speed = base_speed
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
		_draw_fallback()
	status_label = Label.new()
	status_label.position = Vector2(-24, -46)
	status_label.size = Vector2(48, 18)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(status_label)

func _draw_fallback() -> void:
	var fallback := Polygon2D.new()
	fallback.polygon = PackedVector2Array([Vector2(-18, -30), Vector2(18, -30), Vector2(20, 30), Vector2(-20, 30)])
	match zombie_id:
		"cuong-thi-doi-xo", "cuong-thi-cau-thu": fallback.color = Color("70808f")
		"cuong-thi-khinh-khi-cau": fallback.color = Color("6f84a4")
		"cuong-thi-vu-cong": fallback.color = Color("a65e84")
		_: fallback.color = Color("646843")
	add_child(fallback)

func _ready() -> void:
	add_to_group("zombies")
	if zombie_id == "cuong-thi-vu-cong":
		call_deferred("_summon_backup_dancers")

func _process(delta: float) -> void:
	if GameManager.state != "playing":
		return
	_update_status(delta)
	attack_timer -= delta
	var target := _find_plant()
	if target != null:
		if frozen_timer <= 0.0 and attack_timer <= 0.0:
			target.take_damage(damage)
			attack_timer = attack_rate
	else:
		if zombie_id == "cuong-thi-cam-sao" and not has_vaulted:
			_try_vault()
		if frozen_timer <= 0.0:
			global_position.x -= speed * delta
	if zombie_id == "cuong-thi-khinh-khi-cau":
		for plant in get_tree().get_nodes_in_group("plants"):
			if plant.lane == lane and plant.plant_id == "dia-thich" and abs(plant.global_position.x - global_position.x) < 50.0:
				take_damage(9999.0)
				break
	if global_position.x < 245.0:
		GameManager.lose_level()

func _update_status(delta: float) -> void:
	if slowed_timer > 0.0:
		slowed_timer -= delta
	if frozen_timer > 0.0:
		frozen_timer -= delta
	if frozen_timer > 0.0:
		speed = 0.0
		status_label.text = "BĂNG"
	elif slowed_timer > 0.0:
		speed = base_speed * 0.5
		status_label.text = "CHẬM"
	else:
		speed = base_speed
		status_label.text = ""

func apply_status(status: String, duration: float) -> void:
	if status == "freeze":
		frozen_timer = duration
		slowed_timer = 0.0
	elif status == "slow":
		slowed_timer = duration

func _try_vault() -> void:
	for plant in get_tree().get_nodes_in_group("plants"):
		if plant.lane == lane and abs(plant.global_position.x - global_position.x) < 74.0:
			has_vaulted = true
			global_position.x -= 95.0
			var tween := create_tween()
			tween.tween_property(self, "global_position:y", global_position.y - 45.0, 0.18)
			tween.tween_property(self, "global_position:y", global_position.y, 0.18)
			break

func _find_plant() -> Node:
	for plant in get_tree().get_nodes_in_group("plants"):
		if plant.lane == lane and abs(plant.global_position.x - global_position.x) < 42.0:
			return plant
	return null

func _summon_backup_dancers() -> void:
	for offset in [-2, -1, 1, 2]:
		var backup_lane := clampi(lane + offset, 0, 4)
		var entity_factory := get_tree().current_scene.find_child("EntityFactory", true, false)
		if entity_factory:
			entity_factory.spawn_zombie("cuong-thi-nhay-phu", backup_lane)

func take_damage(amount: float) -> void:
	if armor_hp > 0.0:
		var absorbed := min(armor_hp, amount)
		armor_hp -= absorbed
		amount -= absorbed
	if amount <= 0.0:
		return
	hp -= amount
	if zombie_id == "cuong-thi-cam-bao" and armor_hp <= 0.0 and not newspaper_broken:
		newspaper_broken = true
		base_speed *= 2.0
	if hp <= 0.0:
		remove_from_group("zombies")
		queue_free()
