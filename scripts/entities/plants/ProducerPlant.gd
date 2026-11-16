# ============================================================
# VĂN ĐẠO: BÚT TRẬN — ProducerPlant.gd
# Vị trí: scripts/entities/plants/ProducerPlant.gd
# Vai trò: Cây tạo Linh Khí (Nguyễn Trãi)
# ============================================================
# TRIẾT LÝ:
# - ProducerPlant là "nhà máy" tạo tài nguyên.
# - Sinh Sun theo chu kỳ (attack_speed).
# - Không tấn công, không phòng thủ → HP thấp.
# ============================================================

extends Plant
class_name ProducerPlant

# ============================================================
# SIGNALS
# ============================================================
signal sun_generated(sun: Node, at_pos: Vector2)

# ============================================================
# PRELOAD
# ============================================================
const SUN_SCENE_PATH = "res://scenes/entities/Sun.tscn"

# ============================================================
# _perform_action() — OVERRIDE
# ============================================================
func _perform_action() -> void:
	_generate_sun()

# ============================================================
# TẠO LINH KHÍ
# ============================================================
func _generate_sun() -> void:
	# Kiểm tra Sun.tscn có tồn tại không (Đợt 11 sẽ tạo)
	if not ResourceLoader.exists(SUN_SCENE_PATH):
		# Placeholder: Cộng thẳng vào GameManager
		GameManager.add_sun(data.generate_amount)
		print("[ProducerPlant] %s tạo %d Linh Khí (placeholder)" % [
			data.name, data.generate_amount
		])
		sun_generated.emit(null, position)
		return
	
	# Load Sun scene
	var sun_scene = load(SUN_SCENE_PATH)
	var sun = sun_scene.instantiate()
	
	# Đặt vị trí ban đầu = vị trí cây
	sun.global_position = position
	
	# Cấu hình Sun (nếu có method setup)
	if sun.has_method("setup"):
		sun.setup(data.generate_amount, false)  # false = không rơi từ trời
	
	# Add vào scene tree
	get_parent().add_child(sun)
	
	# Phát signal
	sun_generated.emit(sun, position)
	
	# Phát âm thanh (nếu có)
	if AudioManager:
		AudioManager.play_sfx("res://assets/audio/sfx/sun_generate.ogg", 0.5)

# ============================================================
# PLANT FOOD SKILL — Instant Sun
# ============================================================
func activate_plant_food() -> void:
	if data.plant_food_skill.is_empty():
		return
	
	var effect = data.plant_food_skill.get("effect_type", "")
	
	if effect == "instant_sun":
		_instant_sun_skill()

func _instant_sun_skill() -> void:
	var sun_amount = data.plant_food_skill.get("sun_amount", 150)
	var haste_duration = data.plant_food_skill.get("haste_duration", 10.0)
	
	print("[ProducerPlant] %s kích hoạt Instant Sun! (+%d Linh Khí)" % [
		data.name, sun_amount
	])
	
	# 1. Cộng ngay lập tức
	GameManager.add_sun(sun_amount)
	
	# 2. Haste: Giảm attack_speed trong 10 giây
	_apply_haste(haste_duration)

func _apply_haste(duration: float) -> void:
	var original_speed = data.attack_speed
	data.attack_speed = original_speed * 0.5  # Nhanh gấp đôi
	
	print("[ProducerPlant] Haste! Attack speed: %.2f → %.2f" % [
		original_speed, data.attack_speed
	])
	
	# Chờ hết duration
	await get_tree().create_timer(duration).timeout
	
	# Khôi phục
	if is_instance_valid(self) and data != null:
		data.attack_speed = original_speed
		print("[ProducerPlant] Haste kết thúc.")