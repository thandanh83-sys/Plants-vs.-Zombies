# ============================================================
# VĂN ĐẠO: BÚT TRẬN — SupportPlant.gd
# Vị trí: scripts/entities/plants/SupportPlant.gd
# Vai trò: Cây hỗ trợ (Hồ Chí Minh)
# ============================================================
# TRIẾT LÝ:
# - SupportPlant không tấn công trực tiếp.
# - Aura làm chậm quái xung quanh.
# - Aura buff các cây đồng minh xung quanh.
# - Tạo sức mạnh cộng hưởng khi đặt gần cây khác.
# ============================================================

extends Plant
class_name SupportPlant

# ============================================================
# SIGNALS
# ============================================================
signal aura_activated(center: Vector2, radius: float)

# ============================================================
# BIẾN
# ============================================================
var _aura_timer: float = 0.0
var _buff_targets: Array = []  # Cache các cây được buff

# ============================================================
# _process() — OVERRIDE (aura update liên tục)
# ============================================================
func _process(delta: float) -> void:
	if not _is_initialized or _is_dead:
		return
	
	# Update aura mỗi 0.5 giây (không cần mỗi frame)
	_aura_timer += delta
	if _aura_timer >= 0.5:
		_aura_timer = 0.0
		_update_aura()

# ============================================================
# _perform_action() — OVERRIDE (không làm gì)
# ============================================================
func _perform_action() -> void:
	pass

# ============================================================
# CẬP NHẬT AURA
# ============================================================
func _update_aura() -> void:
	var aura_radius = data.get("aura_range", 3.0) * Const.CELL_SIZE.x
	if aura_radius <= 0:
		return
	
	# 1. Slow quái trong bán kính
	_slow_enemies_in_radius(aura_radius)
	
	# 2. Buff cây đồng minh trong bán kính
	_buff_plants_in_radius(aura_radius)

# ============================================================
# SLOW QUÁI
# ============================================================
func _slow_enemies_in_radius(radius_px: float) -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var slow_amount = data.get("slow_amount", 0.5)
	var slow_duration = data.get("slow_duration", 3.0)
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= radius_px:
			if enemy.has_method("apply_slow"):
				enemy.apply_slow(slow_amount, slow_duration)

# ============================================================
# BUFF CÂY ĐỒNG MINH
# ============================================================
func _buff_plants_in_radius(radius_px: float) -> void:
	# Tìm tất cả cây trong group "plants" (sẽ add khi tạo cây)
	# Hoặc dùng tile.parent để tìm
	var all_plants = get_tree().get_nodes_in_group("plants")
	var buff_speed = data.get("buff_speed", 1.5)
	
	for plant in all_plants:
		if plant == self or not is_instance_valid(plant):
			continue
		if not plant is Plant:
			continue
		
		var distance = global_position.distance_to(plant.global_position)
		if distance <= radius_px:
			# Buff attack_speed (giảm = bắn nhanh hơn)
			if plant.data != null:
				# Lưu speed gốc để khôi phục sau
				if not plant.has_meta("original_attack_speed"):
					plant.set_meta("original_attack_speed", plant.data.attack_speed)
				
				var original = plant.get_meta("original_attack_speed")
				plant.data.attack_speed = original / buff_speed

# ============================================================
# PLANT FOOD — Mass Heal + Invuln
# ============================================================
func activate_plant_food() -> void:
	if data.plant_food_skill.is_empty():
		return
	
	var effect = data.plant_food_skill.get("effect_type", "")
	
	if effect == "mass_heal_invuln":
		var radius = data.plant_food_skill.get("radius", 5.0) * Const.CELL_SIZE.x
		var duration = data.plant_food_skill.get("duration", 5.0)
		
		print("[SupportPlant] %s kích hoạt Mass Heal+Invuln! (%.1f ô, %.1fs)" % [
			data.name, radius / Const.CELL_SIZE.x, duration
		])
		
		_mass_heal_invuln(radius, duration)

func _mass_heal_invuln(radius_px: float, duration: float) -> void:
	var all_plants = get_tree().get_nodes_in_group("plants")
	
	for plant in all_plants:
		if not is_instance_valid(plant):
			continue
		if not plant is Plant:
			continue
		
		var distance = global_position.distance_to(plant.global_position)
		if distance <= radius_px:
			# 1. Hồi đầy máu
			if plant.has_method("heal"):
				plant.heal(plant.data.hp)
			
			# 2. Bất tử (nếu Plant có method set_invulnerable, hoặc dùng meta)
			plant.set_meta("is_invulnerable", true)
	
	# Hiệu ứng
	_play_heal_visual(radius_px)
	
	# Chờ hết duration
	await get_tree().create_timer(duration).timeout
	
	# Tắt bất tử
	for plant in all_plants:
		if is_instance_valid(plant):
			plant.remove_meta("is_invulnerable") if plant.has_meta("is_invulnerable") else null

func _play_heal_visual(radius_px: float) -> void:
	var circle = Node2D.new()
	circle.global_position = global_position
	circle.z_index = 10
	
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()
	for i in range(32):
		var angle = (float(i) / 32) * TAU
		points.append(Vector2(cos(angle), sin(angle)) * radius_px)
	polygon.polygon = points
	polygon.color = Color(Const.COLOR_GOLD.r, Const.COLOR_GOLD.g, Const.COLOR_GOLD.b, 0.4)
	circle.add_child(polygon)
	
	get_parent().add_child(circle)
	
	var tween = create_tween()
	tween.tween_property(polygon, "modulate:a", 0.0, 1.0)
	await tween.finished
	if is_instance_valid(circle):
		circle.queue_free()