# ============================================================
# VĂN ĐẠO: BÚT TRẬN — Const.gd
# Vị trí: scripts/utils/Const.gd
# Vai trò: Hằng số toàn cục (Global Constants)
# Mục đích: Tập trung mọi con số "magic" về 1 chỗ
# ============================================================
# CÁCH DÙNG:
#   Không cần preload. Chỉ cần gõ:
#     Const.GRID_COLS
#     Const.CELL_SIZE
#     Const.COLOR_JADE
# ============================================================
# TRIẾT LÝ:
# - Mọi con số "ma thuật" (magic number) phải có tên gọi.
# - VD: Thay vì `if x > 5`, viết `if x > Const.GRID_ROWS`.
# - Khi cần đổi → chỉ sửa 1 chỗ, toàn bộ code tự cập nhật.
# ============================================================

class_name Const
extends RefCounted
# ↑ `class_name` cho phép truy cập trực tiếp: `Const.GRID_COLS`
# ↑ `extends RefCounted` vì không cần kế thừa Node (không vào scene tree)

# ============================================================
# SECTION 1: LƯỚI CHIẾN ĐẤU (GRID)
# ============================================================
# Lưới 5 hàng x 9 cột — giống PvZ gốc
# ============================================================

# Số hàng (5 hàng quái có thể đi)
const GRID_ROWS: int = 5

# Số cột (9 cột từ trái sang phải)
const GRID_COLS: int = 9

# Kích thước 1 ô (pixel)
# 5 hàng x 100 = 500 pixel chiều cao → vừa màn hình 720p
const CELL_SIZE: Vector2 = Vector2(100, 100)

# Vị trí gốc của lưới (góc trên trái ô đầu tiên)
# X = 220 để chừa chỗ cho Lawnmower bên trái
# Y = 110 để chừa chỗ cho UI thanh thẻ phía trên
const GRID_ORIGIN: Vector2 = Vector2(220, 110)

# Đường viền (border) giữa các ô
const GRID_LINE_COLOR: Color = Color(0.18, 0.55, 0.34, 0.15)  # Xanh ngọc mờ
const GRID_LINE_WIDTH: float = 1.0

# ============================================================
# SECTION 2: LAYER VẬT LÝ (PHYSICS LAYERS)
# ============================================================
# Godot có 32 layer (1-32). Dùng bit mask để phân loại va chạm.
# VD: Đạn chỉ va chạm với quái, không va chạm với cây.
# ============================================================

# Layer 1: Mặc định (không dùng)
# Layer 2: Quái (Enemy)
# Layer 3: Đạn (Bullet)
# Layer 4: Cây (Plant)
# Layer 5: Linh Khí (Sun)

const LAYER_DEFAULT: int = 1
const LAYER_ENEMY: int = 2
const LAYER_BULLET: int = 4
const LAYER_PLANT: int = 8
const LAYER_SUN: int = 16

# Bit mask để bắn Raycast vào 1 layer cụ thể
# (Dùng cho việc kiểm tra "có quái trong tầm bắn không?")
const MASK_ENEMY_ONLY: int = LAYER_ENEMY
const MASK_ENEMY_AND_PLANT: int = LAYER_ENEMY | LAYER_PLANT

# ============================================================
# SECTION 3: BẢNG MÀU (COLOR PALETTE)
# ============================================================
# Lấy từ CSS Văn Đạo: Bạch Ngọc, Ngọc bích, Vàng cát
# ============================================================

# Nền chính (trắng ngà)
const COLOR_BG_CREAM: Color = Color("#F7FCF9")
const COLOR_BG_PEARL: Color = Color("#E8F4EE")

# Xanh ngọc (chủ đạo)
const COLOR_JADE: Color = Color("#2E8B57")
const COLOR_JADE_LIGHT: Color = Color("#3BAF75")
const COLOR_JADE_MINT: Color = Color("#4FC489")
const COLOR_JADE_DARK: Color = Color("#1A5232")

# Vàng cát (điểm nhấn)
const COLOR_GOLD: Color = Color("#C9A96E")
const COLOR_GOLD_DARK: Color = Color("#A8863D")

# Đỏ (cảnh báo, máu quái)
const COLOR_RED_DANGER: Color = Color("#9C3A3A")
const COLOR_RED_LIGHT: Color = Color("#E74C3C")

# Chữ (text)
const COLOR_TEXT_MAIN: Color = Color("#112A20")
const COLOR_TEXT_MUTED: Color = Color("#4A6B5D")

# Hiệu ứng
const COLOR_SUN_GLOW: Color = Color("#FFD966")  # Linh Khí phát sáng
const COLOR_BULLET_INK: Color = Color("#2E8B57")  # Đạn mực
const COLOR_EXPLOSION: Color = Color("#A86B6B")  # Mực nổ

# ============================================================
# SECTION 4: GAMEPLAY BALANCE (CÂN BẰNG GAME)
# ============================================================

# Số Linh Khí mặc định khi bắt đầu
const DEFAULT_INITIAL_SUN: int = 150

# Linh Khí sinh ra mỗi lần từ Nguyễn Trãi
const SUN_GENERATE_AMOUNT: int = 25

# Tốc độ rơi của Linh Khí từ trên trời (pixel/giây)
const SUN_FALL_SPEED: float = 80.0

# Thời gian tồn tại của Sun nếu không nhặt (giây)
const SUN_LIFETIME: float = 8.0

# Sát thương của Bình Phong Hộ (Lawnmower) — phải giết mọi quái
const LAWNMOWER_DAMAGE: int = 999999

# ============================================================
# SECTION 5: TIMING (THỜI GIAN)
# ============================================================

# Delay mặc định giữa các wave (giây)
const WAVE_INTERMISSION: float = 8.0

# Delay giữa các wave lớn (trước boss)
const WAVE_BOSS_INTERMISSION: float = 15.0

# Thời gian cooldown sau khi đặt thẻ (giây) — tránh spam
const CARD_PLACEMENT_COOLDOWN: float = 0.5

# Thời gian hiệu ứng chuyển cảnh (giây)
const TRANSITION_DURATION: float = 0.3

# ============================================================
# SECTION 6: UI (GIAO DIỆN)
# ============================================================

# Chiều cao thanh thẻ bài phía trên
const CARD_BAR_HEIGHT: int = 90

# Kích thước thẻ bài (Card)
const CARD_SIZE: Vector2 = Vector2(80, 80)

# Khoảng cách giữa các thẻ bài
const CARD_SPACING: int = 10

# Kích thước nút "Bắt đầu" trong menu
const BUTTON_SIZE: Vector2 = Vector2(200, 60)

# ============================================================
# SECTION 7: AUDIO (ÂM THANH)
# ============================================================

# Âm lượng mặc định (0.0 → 1.0)
const VOLUME_MASTER: float = 0.8
const VOLUME_BGM: float = 0.5
const VOLUME_SFX: float = 0.8

# Tốc độ fade giữa các BGM (giây)
const BGM_FADE_DURATION: float = 1.5

# ============================================================
# SECTION 8: SCENE PATHS (ĐƯỜNG DẪN SCENE)
# ============================================================
# Tập trung đường dẫn để tránh typo, dễ refactor
# ============================================================

const SCENE_MAIN: String = "res://scenes/Main.tscn"
const SCENE_GRID: String = "res://scenes/grid/GridManager.tscn"
const SCENE_TILE: String = "res://scenes/grid/Tile.tscn"
const SCENE_PLANT: String = "res://scenes/entities/Plant.tscn"
const SCENE_ENEMY: String = "res://scenes/entities/Enemy.tscn"
const SCENE_BULLET: String = "res://scenes/entities/Bullet.tscn"
const SCENE_SUN: String = "res://scenes/entities/Sun.tscn"

# ============================================================
# SECTION 9: LEVEL KEYS (KEY STRINGS)
# ============================================================
# Dùng thay vì gõ "available_plants", "initial_sun"... để tránh typo
# ============================================================

const KEY_LEVEL_ID: String = "id"
const KEY_LEVEL_NAME: String = "name"
const KEY_LEVEL_WAVES: String = "waves"
const KEY_LEVEL_AVAILABLE_PLANTS: String = "available_plants"
const KEY_LEVEL_INITIAL_SUN: String = "initial_sun"
const KEY_LEVEL_REWARD: String = "reward"

const KEY_PLANT_ID: String = "id"
const KEY_PLANT_NAME: String = "name"
const KEY_PLANT_COST: String = "cost"
const KEY_PLANT_HP: String = "hp"
const KEY_PLANT_DAMAGE: String = "damage"
const KEY_PLANT_ATTACK_SPEED: String = "attack_speed"

const KEY_ENEMY_ID: String = "id"
const KEY_ENEMY_HP: String = "hp"
const KEY_ENEMY_SPEED: String = "speed"
const KEY_ENEMY_DAMAGE: String = "damage"

# ============================================================
# SECTION 10: HELPER METHODS (HÀM TIỆN ÍCH)
# ============================================================

# ------------------------------------------------------------
# Chuyển grid position (Vector2i) sang world position (Vector2)
# ------------------------------------------------------------
# VD: Vector2i(0, 0) → Vector2(220, 110) (góc trên trái ô 0,0)
#     Vector2i(2, 3) → Vector2(420, 410) (ô cột 2, hàng 3)
# ------------------------------------------------------------
static func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return GRID_ORIGIN + Vector2(
		grid_pos.x * CELL_SIZE.x,
		grid_pos.y * CELL_SIZE.y
	)

# ------------------------------------------------------------
# Chuyển world position (Vector2) sang grid position (Vector2i)
# ------------------------------------------------------------
# VD: Vector2(250, 150) → Vector2i(0, 0) (thuộc ô 0,0)
# Trả về Vector2i(-1, -1) nếu nằm ngoài lưới
# ------------------------------------------------------------
static func world_to_grid(world_pos: Vector2) -> Vector2i:
	var relative = world_pos - GRID_ORIGIN
	if relative.x < 0 or relative.y < 0:
		return Vector2i(-1, -1)
	
	var col = int(relative.x / CELL_SIZE.x)
	var row = int(relative.y / CELL_SIZE.y)
	
	if col >= GRID_COLS or row >= GRID_ROWS:
		return Vector2i(-1, -1)
	
	return Vector2i(col, row)

# ------------------------------------------------------------
# Lấy tâm của một ô lưới (dùng để đặt cây giữa ô)
# ------------------------------------------------------------
static func get_cell_center(grid_pos: Vector2i) -> Vector2:
	return grid_to_world(grid_pos) + CELL_SIZE * 0.5

# ------------------------------------------------------------
# Kiểm tra grid_pos có hợp lệ không (nằm trong lưới)
# ------------------------------------------------------------
static func is_valid_grid_pos(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_COLS \
		and grid_pos.y >= 0 and grid_pos.y < GRID_ROWS

# ------------------------------------------------------------
# Debug: In ra thông tin toàn bộ hằng số (dùng khi cần)
# ------------------------------------------------------------
static func debug_print() -> void:
	print("")
	print("═".repeat(50))
	print("  [Const] HẰNG SỐ TOÀN CỤC")
	print("═".repeat(50))
	print("  Lưới: %d hàng × %d cột" % [GRID_ROWS, GRID_COLS])
	print("  Ô: %s px" % str(CELL_SIZE))
	print("  Gốc: %s" % str(GRID_ORIGIN))
	print("  Sun khởi đầu: %d" % DEFAULT_INITIAL_SUN)
	print("  Layer Enemy: %d" % LAYER_ENEMY)
	print("═".repeat(50))
	print("")
