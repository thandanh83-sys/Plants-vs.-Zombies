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
var slowed_timer := 0.0
var frozen_timer := 0.0
var has_vaulted := false
var is_vaulting := false
var has_summoned := false
var is_boss := false
var status_label: Label
var _slow_factor := 0.5

func setup(id: String, data: Dictionary, row: int) -> void:
	zombie_id = id
	zombie_data = data.duplicate(true)
	lane = row
	hp = maxf(1.0, float(data.get("hp", 200)))
	max_hp = hp
	base_speed = maxf(0.0, float(data.get("speed", 16.0)))
	speed = base_speed
	damage = maxf(0.0, float(data.get("damage", 20)))
	attack_rate = maxf(0.1, float(data.get("attack_rate", 1.0)))
	var armor: Variant = data.get("armor", {})
	if armor is Dictionary:
		armor_hp = maxf(0.0, float(armor.get("hp", 0)))
	collision_layer = 4
	collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(34, 58)
	collision.shape = shape
	add_child(collision)
	var texture: Texture2D = DataLoader.get_zombie_sprite(id)
	if texture != null:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.scale = Vector2.ONE * float(data.get("sprite_scale", 1.0))
		add_child(sprite)
	else:
		_draw_fallback()
	status_label = Label.new()
	status_label.position = Vector2(-32, -48)
	status_label.size = Vector2(64, 18)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(status_label)

func _draw_fallback() -> void:
	var fallback := Polygon2D.new()
	fallback.polygon = PackedVector2Array([Vector2(-18, -30), Vector2(18, -30), Vector2(20, 30), Vector2(-20, 30)])
	match str(zombie_data.get("type", "basic")):
		"armored": fallback.color = Color("70808f")
		"balloon": fallback.color = Color("6f84a4")
		"dancer": fallback.color = Color("a65e84")
		"pole_vaulting": fallback.color = Color("c08a4d")
		_: fallback.color = Color("646843")
	add_child(fallback)

func _ready() -> void:
	add_to_group("zombies")
	call_deferred("_summon_support")

func set_boss_mode() -> void:
	is_boss = true
	var multiplier := maxf(1.0, float(DataLoader.get_setting("boss_hp_multiplier", 3.0)))
	hp *= multiplier
	max_hp = hp
	damage *= maxf(1.0, float(DataLoader.get_setting("boss_damage_multiplier", 1.5)))
	armor_hp *= multiplier
	if is_instance_valid(status_label):
		status_label.text = "BOSS"

func _process(delta: float) -> void:
	if GameManager.state != "playing":
		return
	_update_status(delta)
	attack_timer -= delta
	var abilities := _abilities()
	var is_flying := bool(abilities.get("flies_over_plants", false))
	var target: Node2D = null
	if not is_flying:
		target = _find_plant()
	if target != null:
		if frozen_timer <= 0.0 and attack_timer <= 0.0:
			target.take_damage(damage)
			attack_timer = attack_rate
	elif not is_vaulting:
		if bool(abilities.get("jumps_over_first_plant", false)) and not has_vaulted:
			if _try_vault():
				return
		if frozen_timer <= 0.0:
			global_position.x -= speed * delta
	if is_flying:
		_check_flying_counter(abilities)
	if global_position.x < float(DataLoader.get_setting("zombie_loss_x", 245.0)):
		GameManager.lose_level()

func _abilities() -> Dictionary:
	var value: Variant = zombie_data.get("abilities", {})
	return value if value is Dictionary else {}

func _update_status(delta: float) -> void:
	slowed_timer = maxf(0.0, slowed_timer - delta)
	frozen_timer = maxf(0.0, frozen_timer - delta)
	if frozen_timer > 0.0:
		speed = 0.0
		status_label.text = "ĐÓNG BĂNG"
	elif slowed_timer > 0.0:
		speed = base_speed * _slow_factor
		status_label.text = "CHẬM"
	elif is_boss:
		speed = base_speed
		status_label.text = "BOSS"
	else:
		speed = base_speed
		status_label.text = ""

func apply_status(status: String, duration: float, factor: float = 0.5) -> void:
	if status == "freeze":
		frozen_timer = maxf(frozen_timer, duration)
		slowed_timer = 0.0
	elif status == "slow":
		slowed_timer = maxf(slowed_timer, duration)
		_slow_factor = clampf(factor, 0.05, 1.0)

func _find_plant() -> Node2D:
	for plant in get_tree().get_nodes_in_group("plants"):
		if plant.lane == lane and absf(plant.global_position.x - global_position.x) <= 42.0:
			return plant
	return null

func _try_vault() -> bool:
	for plant in get_tree().get_nodes_in_group("plants"):
		if plant.lane == lane and plant.global_position.x < global_position.x and absf(plant.global_position.x - global_position.x) <= 74.0:
			has_vaulted = true
			is_vaulting = true
			var landing := Vector2(global_position.x - 100.0, global_position.y - 38.0)
			var tween := create_tween()
			tween.tween_property(self, "global_position", landing, 0.18)
			tween.tween_property(self, "global_position:y", landing.y + 38.0, 0.18)
			tween.finished.connect(func(): is_vaulting = false)
			return true
	return false

func _check_flying_counter(abilities: Dictionary) -> void:
	if str(abilities.get("counter", "")) != "spikeweed":
		return
	for plant in get_tree().get_nodes_in_group("plants"):
		if plant.lane != lane or absf(plant.global_position.x - global_position.x) > 34.0:
			continue
		var plant_abilities: Dictionary = plant.plant_data.get("abilities", {})
		if bool(plant_abilities.get("damages_rolling_zombies", false)):
			take_damage(999999.0)
			return

func _summon_support() -> void:
	if has_summoned:
		return
	var abilities := _abilities()
	var summon_id := str(abilities.get("summons", ""))
	var summon_count := maxi(0, int(abilities.get("summon_count", 0)))
	if summon_id.is_empty() or summon_count == 0:
		return
	has_summoned = true
	var entity_factory := get_tree().current_scene.find_child("EntityFactory", true, false)
	if entity_factory == null:
		return
	var row_count := maxi(1, int(DataLoader.get_setting("grid_rows", 5)))
	for i in range(summon_count):
		var offset := i - int((summon_count - 1) / 2)
		entity_factory.spawn_zombie(summon_id, clampi(lane + offset, 0, row_count - 1))

func take_damage(amount: float) -> void:
	var remaining := maxf(0.0, amount)
	if armor_hp > 0.0:
		var absorbed := minf(armor_hp, remaining)
		armor_hp -= absorbed
		remaining -= absorbed
	if remaining > 0.0:
		hp -= remaining
	if armor_hp <= 0.0:
		var faster_speed := float(_abilities().get("speed_after_newspaper_breaks", 0.0))
		if faster_speed > 0.0:
			base_speed = faster_speed
	if hp <= 0.0:
		remove_from_group("zombies")
		queue_free()
