# ============================================================
# VĂN ĐẠO: BÚT TRẬN — SeedPacket.gd
# Vị trí: scripts/ui/SeedPacket.gd
# Vai trò: 1 thẻ bài đơn lẻ (hiển thị cây + cost + cooldown)
# ============================================================

extends PanelContainer
class_name SeedPacket

# ============================================================
# SIGNALS
# ============================================================
signal card_clicked(plant_data: Dictionary)

# ============================================================
# @onready
# ============================================================
@onready var name_label: Label = $VBox/NameLabel
@onready var cost_label: Label = $VBox/CostLabel
@onready var icon_rect: ColorRect = $VBox/IconRect
@onready var cooldown_overlay: ColorRect = $CooldownOverlay

# ============================================================
# BIẾN
# ============================================================
var plant_data: Dictionary = {}
var _cooldown_timer: float = 0.0
var _cooldown_max: float = 5.0
var _is_on_cooldown: bool = false

# ============================================================
# SETUP — Gán dữ liệu
# ============================================================
func setup(data: Dictionary) -> void:
	plant_data = data
	
	# Cập nhật UI
	if name_label:
		name_label.text = data.get("name", "?")
	
	if cost_label:
		cost_label.text = "🌿 %d" % data.get("cost", 0)
	
	if icon_rect:
		var color_str = data.get("color", "#2E8B57")
		if color_str.begins_with("#"):
			icon_rect.color = Color(color_str)

# ============================================================
# _ready()
# ============================================================
func _ready() -> void:
	# Kết nối click
	gui_input.connect(_on_gui_input)
	
	# Ẩn cooldown ban đầu
	if cooldown_overlay:
		cooldown_overlay.visible = false

# ============================================================
# XỬ LÝ CLICK
# ============================================================
func _on_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if not event.pressed:
		return
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	
	# Không cho click nếu đang cooldown
	if _is_on_cooldown:
		return
	
	# Không cho click nếu không đủ tiền
	var cost = plant_data.get("cost", 0)
	if not GameManager.can_afford(cost):
		return
	
	# Phát signal
	card_clicked.emit(plant_data)

# ============================================================
# COOLDOWN
# ============================================================
func start_cooldown(duration: float = 5.0) -> void:
	_is_on_cooldown = true
	_cooldown_max = duration
	_cooldown_timer = duration
	
	if cooldown_overlay:
		cooldown_overlay.visible = true
		cooldown_overlay.size.y = size.y
		cooldown_overlay.position.y = 0

func _process(delta: float) -> void:
	if not _is_on_cooldown:
		return
	
	_cooldown_timer -= delta
	
	if _cooldown_timer <= 0:
		_is_on_cooldown = false
		if cooldown_overlay:
			cooldown_overlay.visible = false
	else:
		# Cập nhật overlay (giảm dần từ trên xuống)
		if cooldown_overlay:
			var ratio = _cooldown_timer / _cooldown_max
			cooldown_overlay.size.y = size.y * ratio