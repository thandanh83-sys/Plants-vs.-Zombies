# ============================================================
# VĂN ĐẠO: BÚT TRẬN — Tile.gd
# Vị trí: scripts/grid/Tile.gd
# Vai trò: Đại diện cho 1 ô đất trong lưới 5x9
# Mục đích: Nhận click chuột, hiển thị viền, lưu cây đang trồng
# ============================================================
# TRIẾT LÝ:
# - Tile chỉ biết về CHÍNH NÓ (grid_pos, is_occupied).
# - Không quyết định đặt cây gì → gọi GridManager.
# - Không tự trừ tiền → gọi GameManager.
# - Tile là "người lính", GridManager là "chỉ huy".
# ============================================================

extends Area2D
class_name Tile
# ↑ class_name cho phép dùng kiểu `Tile` ở các script khác

# ============================================================
# SIGNALS — Báo cáo sự kiện
# ============================================================

# Phát khi người chơi click vào ô này
# Tham số là chính Tile (để GridManager biết ô nào bị click)
signal tile_clicked(tile: Tile)

# Phát khi có cây được đặt vào ô
signal plant_placed(tile: Tile, plant: Node)

# Phát khi cây bị xóa khỏi ô
signal plant_removed(tile: Tile)

# ============================================================
# BIẾN TRẠNG THÁI
# ============================================================

# Vị trí của ô trong lưới (VD: Vector2i(2, 3) = cột 2, hàng 3)
var grid_pos: Vector2i = Vector2i(-1, -1)

# Ô đã có cây chưa?
var is_occupied: bool = false

# Tham chiếu đến cây đang trồng trong ô (null nếu trống)
var current_plant: Node = null

# Trạng thái hover (chuột đang ở trên ô)
var is_hovered: bool = false

# Trạng thái highlight (khi người chơi đang chọn thẻ)
var is_highlighted: bool = false

# ============================================================
# VISUAL — Hình ảnh hiển thị
# ============================================================
# Chúng ta dùng _draw() để vẽ viền thay vì thêm Sprite node.
# Lý do: tiết kiệm 45 nodes (mỗi ô 1 node) → nhẹ hơn.
# ============================================================

func _draw() -> void:
	# Lấy kích thước ô từ Const
	var size = Const.CELL_SIZE
	var rect = Rect2(Vector2.ZERO, size)
	
	# Màu viền phụ thuộc vào trạng thái
	var border_color: Color
	var fill_color: Color
	
	if is_occupied:
		# Ô đã có cây → viền mờ hơn
		border_color = Const.GRID_LINE_COLOR
		fill_color = Color(0, 0, 0, 0)  # Trong suốt
	elif is_highlighted:
		# Đang chọn thẻ + ô trống → viền sáng xanh
		border_color = Const.COLOR_JADE_LIGHT
		fill_color = Color(Const.COLOR_JADE_LIGHT.r, Const.COLOR_JADE_LIGHT.g, Const.COLOR_JADE_LIGHT.b, 0.15)
	elif is_hovered:
		# Chuột hover → viền vàng
		border_color = Const.COLOR_GOLD
		fill_color = Color(Const.COLOR_GOLD.r, Const.COLOR_GOLD.g, Const.COLOR_GOLD.b, 0.1)
	else:
		# Bình thường → viền mờ
		border_color = Const.GRID_LINE_COLOR
		fill_color = Color(0, 0, 0, 0)
	
	# Vẽ nền (fill)
	if fill_color.a > 0:
		draw_rect(rect, fill_color, true)
	
	# Vẽ viền (border)
	draw_rect(rect, border_color, false, Const.GRID_LINE_WIDTH)

# ============================================================
# _ready() — Khởi tạo khi scene load
# ============================================================
func _ready() -> void:
	# Kết nối signal input_event (Area2D cung cấp sẵn)
	# Signal này phát khi có click chuột VÀO VÙNG CollisionShape
	input_event.connect(_on_input_event)
	
	# Kết nối mouse_entered/exited để xử lý hover
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Set z_index để Tile luôn ở dưới Plant
	# (Plant sẽ đặt ở z_index cao hơn)
	z_index = 0

# ============================================================
# XỬ LÝ CLICK CHUỘT
# ============================================================
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Chỉ xử lý click chuột trái
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_clicked()

# ============================================================
# HÀM XỬ LÝ CLICK CHÍNH
# ============================================================
func _on_clicked() -> void:
	# Nếu game không ở trạng thái PLAYING → bỏ qua
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	# Phát signal để GridManager xử lý
	tile_clicked.emit(self)

# ============================================================
# XỬ LÝ HOVER
# ============================================================
func _on_mouse_entered() -> void:
	is_hovered = true
	queue_redraw()  # Vẽ lại để cập nhật màu

func _on_mouse_exited() -> void:
	is_hovered = false
	queue_redraw()

# ============================================================
# PUBLIC API — Đặt / Xóa cây
# ============================================================

# ------------------------------------------------------------
# Đặt cây vào ô này (gọi từ GridManager)
# ------------------------------------------------------------
func place_plant(plant: Node) -> void:
	if is_occupied:
		push_warning("[Tile] Ô (%d,%d) đã có cây rồi!" % [grid_pos.x, grid_pos.y])
		return
	
	current_plant = plant
	is_occupied = true
	
	# Gắn plant vào scene tree của tile (hoặc parent tùy GridManager)
	# Ở đây, GridManager sẽ tự add_child → ta không làm ở đây
	
	# Cập nhật visual
	queue_redraw()
	
	# Phát signal
	plant_placed.emit(self, plant)

# ------------------------------------------------------------
# Xóa cây khỏi ô (gọi khi cây chết hoặc dùng xẻng)
# ------------------------------------------------------------
func remove_plant() -> void:
	if not is_occupied:
		return
	
	# Xóa node cây khỏi scene tree
	if is_instance_valid(current_plant):
		current_plant.queue_free()
	
	current_plant = null
	is_occupied = false
	
	queue_redraw()
	plant_removed.emit(self)

# ------------------------------------------------------------
# Lấy cây hiện tại (null nếu trống)
# ------------------------------------------------------------
func get_plant() -> Node:
	return current_plant

# ------------------------------------------------------------
# Đặt trạng thái highlight (khi người chơi chọn thẻ)
# ------------------------------------------------------------
func set_highlight(enabled: bool) -> void:
	if is_highlighted == enabled:
		return
	is_highlighted = enabled
	queue_redraw()

# ============================================================
# DEBUG
# ============================================================
func _to_string() -> String:
	return "Tile(%d,%d, occupied=%s)" % [grid_pos.x, grid_pos.y, is_occupied]
