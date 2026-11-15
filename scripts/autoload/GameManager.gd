# ============================================================
# VĂN ĐẠO: BÚT TRẬN — GameManager.gd
# Vị trí: scripts/autoload/GameManager.gd
# Vai trò: Autoload Singleton — Bộ não điều phối game
# Mục đích: Quản lý trạng thái runtime (Sun, thẻ đang chọn, win/lose)
# ============================================================
# TRIẾT LÝ:
# - GameManager KHÔNG đọc JSON trực tiếp. Mọi dữ liệu lấy từ GameData.
# - Mọi thay đổi trạng thái phát signal → UI tự cập nhật.
# - Không chứa logic gameplay (bắn đạn, AI quái) — chỉ điều phối.
# ============================================================

extends Node

# ============================================================
# SIGNALS — Phát tín hiệu khi trạng thái thay đổi
# ============================================================
# Các signal này cho phép UI và các systems khác "lắng nghe"
# mà không cần "hỏi" liên tục.

signal sun_changed(new_amount: int)        # Linh Khí thay đổi
signal card_selected(plant_data: Dictionary)  # Người chơi chọn thẻ
signal card_deselected                     # Bỏ chọn thẻ
signal game_started                        # Game bắt đầu
signal game_won                            # Thắng
signal game_lost                           # Thua

# ============================================================
# ENUM — Định nghĩa các trạng thái game
# ============================================================
enum GameState {
	MENU,       # Đang ở menu chính
	PLAYING,    # Đang chơi
	PAUSED,     # Tạm dừng
	WON,        # Đã thắng
	LOST        # Đã thua
}

# ============================================================
# BIẾN TRẠNG THÁI
# ============================================================

# Trạng thái game hiện tại
var current_state: GameState = GameState.MENU

# Linh Khí hiện có
var current_sun: int = 0

# Thẻ đang được chọn (Dictionary rỗng = chưa chọn)
var selected_card: Dictionary = {}

# Level đang chơi
var current_level_id: String = ""
var current_level_data: Dictionary = {}

# Chỉ số wave hiện tại (0, 1, 2, ...)
var current_wave_index: int = 0

# Số Linh Khí khởi đầu (lấy từ level config)
var initial_sun: int = 150

# Theo dõi Bình Phong Hộ đã dùng chưa (cho hệ thống 3 sao)
var lawnmower_used: bool = false

# ============================================================
# _ready() — Kết nối với GameData
# ============================================================
func _ready() -> void:
	# Chờ GameData load xong
	if not GameData.is_loaded:
		await GameData.data_loaded
	print("[GameManager] Đã kết nối với GameData. Sẵn sàng.")

# ============================================================
# QUẢN LÝ LINH KHÍ (SUN)
# ============================================================

# ------------------------------------------------------------
# Cộng Linh Khí (VD: nhặt được Sun rơi, hoặc Nguyễn Trãi tạo)
# ------------------------------------------------------------
func add_sun(amount: int) -> void:
	if amount <= 0:
		push_warning("[GameManager] add_sun với số âm: %d" % amount)
		return
	
	current_sun += amount
	sun_changed.emit(current_sun)

# ------------------------------------------------------------
# Trừ Linh Khí (VD: trồng cây)
# Trả về true nếu đủ tiền và trừ thành công
# ------------------------------------------------------------
func spend_sun(amount: int) -> bool:
	if amount < 0:
		push_error("[GameManager] spend_sun với số âm: %d" % amount)
		return false
	
	if current_sun < amount:
		return false  # Không đủ tiền
	
	current_sun -= amount
	sun_changed.emit(current_sun)
	return true

# ------------------------------------------------------------
# Kiểm tra có đủ Linh Khí để mua không
# ------------------------------------------------------------
func can_afford(amount: int) -> bool:
	return current_sun >= amount

# ============================================================
# QUẢN LÝ THẺ BÀI (CARD SELECTION)
# ============================================================

# ------------------------------------------------------------
# Chọn thẻ (gọi khi người chơi click vào thẻ trong UI)
# ------------------------------------------------------------
func select_card(plant_data: Dictionary) -> bool:
	if plant_data.is_empty():
		return false
	
	# Kiểm tra đủ tiền
	var cost = plant_data.get("cost", 0)
	if not can_afford(cost):
		push_warning("[GameManager] Không đủ Linh Khí để chọn %s" % plant_data.get("name", "?"))
		return false
	
	# Lưu thẻ đang chọn
	selected_card = plant_data
	card_selected.emit(selected_card)
	return true

# ------------------------------------------------------------
# Bỏ chọn thẻ (gọi khi: trồng xong, hoặc click nút hủy)
# ------------------------------------------------------------
func deselect_card() -> void:
	selected_card = {}
	card_deselected.emit()

# ------------------------------------------------------------
# Kiểm tra có thẻ đang chọn không
# ------------------------------------------------------------
func has_selected_card() -> bool:
	return not selected_card.is_empty()

# ------------------------------------------------------------
# Lấy thẻ đang chọn (nếu không có → Dictionary rỗng)
# ------------------------------------------------------------
func get_selected_card() -> Dictionary:
	return selected_card

# ============================================================
# QUẢN LÝ GAME STATE (START / WIN / LOSE)
# ============================================================

# ------------------------------------------------------------
# Bắt đầu một màn chơi
# ------------------------------------------------------------
func start_level(level_id: String) -> void:
	# Lấy dữ liệu level từ GameData
	var level = GameData.get_level(level_id)
	if level.is_empty():
		push_error("[GameManager] Không tìm thấy level: " + level_id)
		return
	
	# Lưu trạng thái
	current_level_id = level_id
	current_level_data = level
	current_wave_index = 0
	lawnmower_used = false
	
	# Khởi tạo Sun từ level config
	initial_sun = level.get("initial_sun", 150)
	current_sun = initial_sun
	
	# Đổi trạng thái
	current_state = GameState.PLAYING
	
	# Phát tín hiệu
	game_started.emit()
	sun_changed.emit(current_sun)
	
	print("[GameManager] Bắt đầu màn: %s (Linh Khí: %d)" % [
		level.get("name", level_id), initial_sun
	])

# ------------------------------------------------------------
# Xử lý khi thắng màn
# ------------------------------------------------------------
func on_level_won() -> void:
	if current_state != GameState.PLAYING:
		return
	
	current_state = GameState.WON
	game_won.emit()
	
	print("[GameManager] CHIẾN THẮNG màn: %s" % current_level_data.get("name", current_level_id))

# ------------------------------------------------------------
# Xử lý khi thua màn
# ------------------------------------------------------------
func on_level_lost() -> void:
	if current_state != GameState.PLAYING:
		return
	
	current_state = GameState.LOST
	game_lost.emit()
	
	print("[GameManager] THẤT BẠI màn: %s" % current_level_data.get("name", current_level_id))

# ------------------------------------------------------------
# Quay về menu
# ------------------------------------------------------------
func return_to_menu() -> void:
	current_state = GameState.MENU
	current_level_id = ""
	current_level_data = {}
	selected_card = {}
	current_sun = 0
	deselect_card()

# ============================================================
# QUẢN LÝ TIẾN TRÌNH WAVE
# ============================================================

# ------------------------------------------------------------
# Lấy wave ID tiếp theo của màn hiện tại
# Trả về "" nếu đã hết wave
# ------------------------------------------------------------
func get_next_wave_id() -> String:
	if current_level_data.is_empty():
		return ""
	
	var wave_ids: Array = current_level_data.get("waves", [])
	if current_wave_index >= wave_ids.size():
		return ""
	
	return wave_ids[current_wave_index]

# ------------------------------------------------------------
# Đánh dấu wave hiện tại đã xong, chuyển sang wave tiếp
# ------------------------------------------------------------
func advance_wave() -> void:
	current_wave_index += 1
	print("[GameManager] Chuyển sang wave %d" % current_wave_index)

# ------------------------------------------------------------
# Kiểm tra đã hết tất cả wave chưa (điều kiện thắng)
# ------------------------------------------------------------
func is_last_wave() -> bool:
	if current_level_data.is_empty():
		return false
	var wave_ids: Array = current_level_data.get("waves", [])
	return current_wave_index >= wave_ids.size() - 1

# ============================================================
# THEO DÕI BÌNH PHONG HỘ (cho hệ thống 3 sao)
# ============================================================

func mark_lawnmower_used() -> void:
	lawnmower_used = true

func has_used_lawnmower() -> bool:
	return lawnmower_used

# ============================================================
# DEBUG HELPERS
# ============================================================

# ------------------------------------------------------------
# In trạng thái hiện tại (dùng khi debug)
# ------------------------------------------------------------
func debug_print_state() -> void:
	print("")
	print("─".repeat(40))
	print("[GameManager] Trạng thái hiện tại:")
	print("  • State: %s" % GameState.keys()[current_state])
	print("  • Level: %s" % current_level_id)
	print("  • Wave:  %d" % current_wave_index)
	print("  • Sun:   %d" % current_sun)
	print("  • Selected card: %s" % (
		selected_card.get("name", "Không có") if not selected_card.is_empty() else "Không có"
	))
	print("─".repeat(40))
	print("")

# ------------------------------------------------------------
# Nút bấm debug — Simulate các sự kiện
# ------------------------------------------------------------
func debug_add_100_sun() -> void:
	add_sun(100)

func debug_win() -> void:
	on_level_won()

func debug_lose() -> void:
	on_level_lost()
