# ============================================================
# VĂN ĐẠO: BÚT TRẬN — HUD.gd
# Vị trí: scripts/ui/HUD.gd
# Vai trò: Hiển thị Linh Khí, Wave, Level name
# ============================================================

extends CanvasLayer
class_name HUD

# ============================================================
# @onready — Tự tìm node con
# ============================================================
@onready var sun_label: Label = $TopBar/SunPanel/SunLabel
@onready var wave_label: Label = $TopBar/WavePanel/WaveLabel
@onready var level_label: Label = $TopBar/LevelLabel

# ============================================================
# _ready() — Kết nối signal
# ============================================================
func _ready() -> void:
	# Kết nối với GameManager
	GameManager.sun_changed.connect(_on_sun_changed)
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_won.connect(_on_game_won)
	GameManager.game_lost.connect(_on_game_lost)
	
	# Khởi tạo giá trị ban đầu
	_on_sun_changed(GameManager.current_sun)

# ============================================================
# CẬP NHẬT SUN KHI THAY ĐỔI
# ============================================================
func _on_sun_changed(new_amount: int) -> void:
	if sun_label:
		sun_label.text = "☀ %d" % new_amount

# ============================================================
# KHI GAME BẮT ĐẦU
# ============================================================
func _on_game_started() -> void:
	var level = GameManager.current_level_data
	if level_label:
		level_label.text = level.get("name", "Màn ?")
	
	_update_wave_label()

# ============================================================
# CẬP NHẬT WAVE LABEL
# ============================================================
func _update_wave_label() -> void:
	if wave_label == null:
		return
	
	var level = GameManager.current_level_data
	var total_waves = level.get("waves", []).size()
	var current = GameManager.current_wave_index + 1
	
	if current > total_waves:
		wave_label.text = "Đã xong!"
	else:
		wave_label.text = "Wave %d / %d" % [current, total_waves]

# ============================================================
# WIN/LOSE OVERLAY
# ============================================================
func _on_game_won() -> void:
	_show_overlay("CHIẾN THẮNG!", Const.COLOR_GOLD)

func _on_game_lost() -> void:
	_show_overlay("THẤT BẠI", Const.COLOR_RED_DANGER)

func _show_overlay(text: String, color: Color) -> void:
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 72)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(label)