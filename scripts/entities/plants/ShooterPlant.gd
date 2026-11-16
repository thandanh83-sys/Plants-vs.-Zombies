# ============================================================
# VĂN ĐẠO: BÚT TRẬN — ShooterPlant.gd
# Vị trí: scripts/entities/plants/ShooterPlant.gd
# Vai trò: Cây bắn đạn (Nguyễn Du, Lý Bạch)
# ============================================================
# TRIẾT LÝ:
# - ShooterPlant chỉ bắn khi có quái trong tầm.
# - Không bắn mù (lãng phí đạn).
# - Phát hiện quái bằng group "enemies" (Enemy sẽ add vào group này).
# ============================================================

extends Plant
class_name ShooterPlant

# ============================================================
# SIGNALS
# ============================================================
signal bullet_fired(bullet: Node, from_pos: Vector2)

# ============================================================
# PRELOAD
# ============================================================
# Bullet.tscn sẽ tạo ở Đợt 11. Preload an toàn.
const BULLET_SCENE_PATH = "res://scenes/entities/Bullet.tscn"

# ============================================================
# BIẾN TRẠNG THÁI
# ============================================================

# Vị trí bắn (đầu nòng) — tương đối so với cây
var fire_offset: Vector2 = Vector2(30, -10)

# Đang trong trạng thái "machine gun" (Plant Food) không?
var _is_machine_gun_active: bool = false

# ============================================================
# _perform_action() — OVERRIDE từ Plant
# ============================================================
func _perform_action() -> void:
	# Nếu đang machine gun → bỏ qua (machine_gun tự xử lý)
	if _is_machine_gun_active:
		return
	
	# Tìm quái trong cùng hàng
	var target = _find_target_in_row()
	if target == null:
		return  # Không có quái → không bắn
	
	# Bắn đạn
	_shoot_at(target)

# ============================================================
# TÌM QUÁI TRONG CÙNG HÀNG
# ============================================================
func _find_target_in_row() -> Node:
	var my_row = get_grid_pos().y
	if my_row < 0:
		return null
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	# Ưu tiên quái gần nhất (bên phải, trong tầm bắn)
	var nearest_enemy = null
	var nearest_distance = INF
	
	for enemy in enemies:
		# Kiểm tra enemy còn sống
		if not is_instance_valid(enemy):
			continue
		
		# Kiểm tra cùng hàng
		if enemy.has_method("get_grid_pos"):
			var enemy_row = enemy.get_grid_pos().y
			if enemy_row != my_row:
				continue
		elif "grid_row" in enemy:
			if enemy.grid_row != my_row:
				continue
		else:
			continue
		
		# Kiểm tra vị trí (phải ở bên phải cây)
		var enemy_x = enemy.position.x
		var my_x = position.x
		var distance = enemy_x - my_x
		
		if distance <= 0:
			continue  # Quái ở bên trái → bỏ qua
		
		# Kiểm tra trong tầm bắn
		var max_range_px = data.attack_range * Const.CELL_SIZE.x
		if distance > max_range_px:
			continue
		
		# Chọn quái gần nhất
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	
	return nearest_enemy

# ============================================================
# BẮN ĐẠN
# ============================================================
func _shoot_at(target: Node) -> void:
	# Kiểm tra Bullet.tscn có tồn tại không (Đợt 11 sẽ tạo)
	if not ResourceLoader.exists(BULLET_SCENE_PATH):
		# Placeholder: Chưa có Bullet.tscn → bắn "tia" tạm
		_debug_fire_beam(target)
		return
	
	# Load Bullet scene
	var bullet_scene = load(BULLET_SCENE_PATH)
	var bullet = bullet_scene.instantiate()
	
	# Đặt vị trí đầu nòng
	bullet.global_position = global_position + fire_offset
	
	# Truyền damage từ data
	if bullet.has_method("setup"):
		bullet.setup(data.damage, get_grid_pos().y)
	
	# Thêm vào scene tree (cùng parent với cây)
	get_parent().add_child(bullet)
	
	# Phát signal
	bullet_fired.emit(bullet, global_position)
	
	# Phát âm thanh
	if AudioManager:
		AudioManager.play_shoot()

# ============================================================
# DEBUG FIRE BEAM — Khi chưa có Bullet.tscn
# ============================================================
func _debug_fire_beam(target: Node) -> void:
	# Vẽ 1 tia ngắn để test (dùng Line2D tạm)
	var line = Line2D.new()
	line.add_point(global_position + fire_offset)
	line.add_point(target.global_position)
	line.default_color = Const.COLOR_BULLET_INK
	line.width = 3.0
	line.z_index = 5
	get_parent().add_child(line)
	
	# Xóa sau 0.1 giây
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(line):
		line.queue_free()
	
	# Gây damage trực tiếp (vì chưa có bullet va chạm)
	if target.has_method("take_damage"):
		target.take_damage(data.damage)

# ============================================================
# PLANT FOOD SKILL — Kỹ năng Thức Tỉnh
# ============================================================
func activate_plant_food() -> void:
	if data.plant_food_skill.is_empty():
		push_warning("[ShooterPlant] %s không có skill." % data.name)
		return
	
	var effect = data.plant_food_skill.get("effect_type", "")
	
	match effect:
		"machine_gun":
			_machine_gun_skill()
		"piercing_beam":
			_piercing_beam_skill()
		_:
			push_warning("[ShooterPlant] Effect không xác định: " + effect)

# ============================================================
# MACHINE GUN — Bắn liên thanh (Nguyễn Du)
# ============================================================
func _machine_gun_skill() -> void:
	var count = data.plant_food_skill.get("bullet_count", 30)
	var duration = data.plant_food_skill.get("duration", 1.5)
	var interval = duration / count
	
	_is_machine_gun_active = true
	print("[ShooterPlant] %s kích hoạt Machine Gun! (%d đạn trong %.1fs)" % [
		data.name, count, duration
	])
	
	# Bắn liên thanh
	for i in range(count):
		var target = _find_target_in_row()
		if target != null:
			_shoot_at(target)
		await get_tree().create_timer(interval).timeout
	
	_is_machine_gun_active = false

# ============================================================
# PIERCING BEAM — Xuyên thấu (Lý Bạch)
# ============================================================
func _piercing_beam_skill() -> void:
	var damage = data.plant_food_skill.get("damage", 500)
	
	print("[ShooterPlant] %s kích hoạt Piercing Beam! (%d damage)" % [data.name, damage])
	
	# Bắn tia xuyên qua toàn hàng
	var my_row = get_grid_pos().y
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		# Kiểm tra cùng hàng
		if enemy.has_method("get_grid_pos"):
			if enemy.get_grid_pos().y != my_row:
				continue
		
		# Gây damage (nếu có)
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
	
	# Hiệu ứng tia sáng (nếu có)
	_play_piercing_beam_visual()

func _play_piercing_beam_visual() -> void:
	# Vẽ tia sáng xanh xuyên màn hình
	var line = Line2D.new()
	line.add_point(global_position + fire_offset)
	line.add_point(global_position + fire_offset + Vector2(1000, 0))
	line.default_color = Color(0.3, 0.6, 1.0, 0.8)
	line.width = 15.0
	line.z_index = 10
	get_parent().add_child(line)
	
	await get_tree().create_timer(0.3).timeout
	if is_instance_valid(line):
		var tween = create_tween()
		tween.tween_property(line, "modulate:a", 0.0, 0.3)
		await tween.finished
		if is_instance_valid(line):
			line.queue_free()