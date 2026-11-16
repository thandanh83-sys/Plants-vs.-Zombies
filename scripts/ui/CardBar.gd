# ============================================================
# VĂN ĐẠO: BÚT TRẬN — CardBar.gd
# Vị trí: scripts/ui/CardBar.gd
# Vai trò: Thanh chứa nhiều thẻ bài (dưới HUD)
# ============================================================

extends PanelContainer
class_name CardBar

# ============================================================
# @onready
# ============================================================
@onready var cards_container: HBoxContainer = $ScrollContainer/CardsContainer

# ============================================================
# PRELOAD
# ============================================================
const SEED_PACKET_SCENE = preload("res://scenes/ui/SeedPacket.tscn")

# ============================================================
# BIẾN
# ============================================================
var _card_widgets: Array = []  # Lưu các SeedPacket để tìm theo id

# ============================================================
# _ready()
# ============================================================
func _ready() -> void:
	GameManager.game_started.connect(_on_game_started)
	GameManager.card_selected.connect(_on_card_selected)
	GameManager.card_deselected.connect(_on_card_deselected)

# ============================================================
# KHI GAME BẮT ĐẦU → Tạo thẻ
# ============================================================
func _on_game_started() -> void:
	_build_cards()

func _build_cards() -> void:
	# Xóa thẻ cũ
	for child in cards_container.get_children():
		child.queue_free()
	_card_widgets.clear()
	
	# Lấy danh sách cây có sẵn của level
	var plants = GameData.get_plants_for_level(GameManager.current_level_id)
	if plants.is_empty():
		push_warning("[CardBar] Không có cây cho level này")
		return
	
	# Tạo SeedPacket cho mỗi cây
	for plant_data in plants:
		var packet = SEED_PACKET_SCENE.instantiate()
		cards_container.add_child(packet)
		packet.setup(plant_data)
		packet.card_clicked.connect(_on_packet_clicked)
		_card_widgets.append(packet)

# ============================================================
# XỬ LÝ CLICK THẺ BÀI
# ============================================================
func _on_packet_clicked(plant_data: Dictionary) -> void:
	# Chọn thẻ qua GameManager
	var success = GameManager.select_card(plant_data)
	if success:
		print("[CardBar] Đã chọn: %s" % plant_data.get("name", "?"))

# ============================================================
# HIGHLIGHT THẺ ĐANG CHỌN
# ============================================================
func _on_card_selected(plant_data: Dictionary) -> void:
	var selected_id = plant_data.get("id", "")
	for packet in _card_widgets:
		if packet.plant_data.get("id", "") == selected_id:
			packet.modulate = Color(1.3, 1.3, 1.3, 1.0)
		else:
			packet.modulate = Color(1, 1, 1, 1)

func _on_card_deselected() -> void:
	for packet in _card_widgets:
		packet.modulate = Color(1, 1, 1, 1)

# ============================================================
# KHI ĐẶT CÂY XONG → Cooldown
# ============================================================
func start_card_cooldown(plant_id: String, duration: float = 5.0) -> void:
	for packet in _card_widgets:
		if packet.plant_data.get("id", "") == plant_id:
			packet.start_cooldown(duration)
			return