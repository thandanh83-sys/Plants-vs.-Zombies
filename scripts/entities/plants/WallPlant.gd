# ============================================================
# VĂN ĐẠO: BÚT TRẬN — WallPlant.gd
# Vị trí: scripts/entities/plants/WallPlant.gd
# Vai trò: Cây phòng thủ (Nam Cao)
# ============================================================
# TRIẾT LÝ:
# - WallPlant KHÔNG làm gì cả. Chỉ đứng đó chịu đòn.
# - HP cực cao (4000) → chặn địch rất lâu.
# - _perform_action() để trống → không tốn CPU.
# ============================================================

extends Plant
class_name WallPlant

# ============================================================
# BIẾN TRẠNG THÁI
# ============================================================
var _is_shielded: bool = false

# ============================================================
# _perform_action() — OVERRIDE (không làm gì)
# ============================================================
func _perform_action() -> void:
	# WallPlant không có hành động định kỳ.
	# Đây là điểm mạnh: không tốn CPU cho cây này.
	pass

# ============================================================
# PLANT FOOD — Heal + Shield
# ============================================================
func activate_plant_food() -> void:
	if data.plant_food_skill.is_empty():
		return
	
	var effect = data.plant_food_skill.get("effect_type", "")
	
	if effect == "heal_shield":
		_heal_shield_skill()

func _heal_shield_skill() -> void:
	var heal_amount = data.plant_food_skill.get("heal_amount", 2000)
	var duration = data.plant_food_skill.get("duration", 10.0)
	
	print("[WallPlant] %s kích hoạt Heal+Shield! (+%d HP, bất tử %.1fs)" % [
		data.name, heal_amount, duration
	])
	
	# 1. Hồi máu
	heal(heal_amount)
	
	# 2. Bật shield (bất tử)
	_is_shielded = true
	
	# 3. Visual: đổi màu body sang vàng gold
	if body_visual != null:
		var original_color = body_visual.color
		body_visual.color = Const.COLOR_GOLD
		
		# Chờ hết duration
		await get_tree().create_timer(duration).timeout
		
		# Khôi phục
		if is_instance_valid(self) and body_visual != null:
			body_visual.color = original_color
			_is_shielded = false
			print("[WallPlant] Shield kết thúc.")
	else:
		await get_tree().create_timer(duration).timeout
		_is_shielded = false

# ============================================================
# TAKE DAMAGE — OVERRIDE (chặn damage khi shield)
# ============================================================
func take_damage(amount: int) -> void:
	if _is_shielded:
		print("[WallPlant] %s đang shield — miễn nhiễm!" % data.name)
		return
	
	super.take_damage(amount)