# ============================================================
# VĂN ĐẠO: BÚT TRẬN — PlantData.gd
# Vị trí: scripts/entities/PlantData.gd
# Vai trò: Resource chứa chỉ số của 1 cây
# Mục đích: Tách biệt DATA (chỉ số) và LOGIC (hành vi)
# ============================================================
# CÁCH DÙNG:
#   var data = PlantData.from_dict(plant_json)
#   print(data.hp)     # 300
#   print(data.cost)   # 100
# ============================================================
# TRIẾT LÝ:
# - PlantData KHÔNG chứa logic gameplay (không bắn đạn, không tạo sun).
# - PlantData chỉ là "container" cho các con số.
# - Có thể lưu ra file .tres để designer chỉnh sửa bằng Editor.
# ============================================================

extends Resource
class_name PlantData
# ↑ `Resource` cho phép lưu ra file .tres, edit trong Inspector
# ↑ `class_name` cho phép dùng làm type hint: `var data: PlantData`

# ============================================================
# SECTION 1: THÔNG TIN ĐỊNH DANH
# ============================================================

# ID duy nhất (VD: "nguyen-du", "ho-xuan-huong")
@export var id: String = ""

# Tên hiển thị (VD: "Nguyễn Du")
@export var name: String = ""

# Biệt hiệu (VD: "Bút Phong")
@export var title: String = ""

# Mô tả ngắn (hiển thị trong tooltip)
@export_multiline var description: String = ""

# Câu danh ngôn của tác giả (hiển thị khi click)
@export_multiline var quote: String = ""

# ============================================================
# SECTION 2: LOẠI CÂY & VAI TRÒ
# ============================================================

# Loại cây — quyết định class con nào sẽ dùng
# "shooter", "producer", "wall", "explosive", "support"
@export var plant_type: String = "shooter"

# Vai trò chiến thuật (chỉ để hiển thị, không ảnh hưởng logic)
# "damage_dealer", "resource_generator", "defender", "aoe_damage", "buffer"
@export var role: String = "damage_dealer"

# ============================================================
# SECTION 3: CHỈ SỐ CƠ BẢN
# ============================================================

# Giá Linh Khí để trồng
@export_range(0, 500, 25) var cost: int = 100

# Máu tối đa
@export_range(1, 10000, 50) var hp: int = 300

# Sát thương mỗi đòn (0 nếu không tấn công)
@export_range(0, 5000, 5) var damage: int = 20

# Số giây giữa 2 đòn đánh (càng nhỏ càng nhanh)
@export_range(0.1, 20.0, 0.1) var attack_speed: float = 1.4

# Tầm bắn (số ô, 1 ô = 100px)
@export_range(0, 20, 1) var attack_range: int = 15

# ============================================================
# SECTION 4: CHỈ SỐ ĐẶC BIỆT (TÙY LOẠI CÂY)
# ============================================================

# Cho ProducerPlant: lượng Linh Khí tạo ra mỗi lần
@export_range(0, 500, 5) var generate_amount: int = 25

# Cho ExplosivePlant: bán kính nổ (số ô)
@export_range(0.0, 10.0, 0.1) var explosion_radius: float = 2.5

# Cho SupportPlant: hệ số làm chậm (0.5 = giảm 50% tốc độ)
@export_range(0.0, 1.0, 0.05) var slow_amount: float = 0.5

# Cho SupportPlant: thời gian làm chậm (giây)
@export_range(0.0, 30.0, 0.5) var slow_duration: float = 3.0

# ============================================================
# SECTION 5: VISUAL
# ============================================================

# Màu chủ đạo (dùng cho placeholder sprite)
@export var color: Color = Color("#2E8B57")

# Đường dẫn sprite (sẽ dùng ở Đợt sau)
@export var sprite_path: String = ""

# Đường dẫn scene cây (VD: "res://scenes/entities/ShooterPlant.tscn")
@export var scene_path: String = ""

# ============================================================
# SECTION 6: METADATA
# ============================================================

# Thời đại (VD: "NHÀ TÂY SƠN")
@export var era: String = ""

# Tags (VD: ["thi_ca", "truyen_thong"])
@export var tags: Array[String] = []

# Kỹ năng Thức Tỉnh (Plant Food) — lưu dạng Dictionary
var plant_food_skill: Dictionary = {}

# ============================================================
# STATIC FACTORY — Tạo PlantData từ JSON Dictionary
# ============================================================
# Đây là "cầu nối" giữa JSON (raw) và Resource (typed).
# ============================================================

static func from_dict(data: Dictionary) -> PlantData:
	var plant = PlantData.new()
	
	# Gán từng trường với default value an toàn
	plant.id = data.get("id", "")
	plant.name = data.get("name", "")
	plant.title = data.get("title", "")
	plant.description = data.get("description", "")
	plant.quote = data.get("quote", "")
	
	plant.plant_type = data.get("plant_type", "shooter")
	plant.role = data.get("role", "damage_dealer")
	
	plant.cost = data.get("cost", 100)
	plant.hp = data.get("hp", 300)
	plant.damage = data.get("damage", 20)
	plant.attack_speed = data.get("attack_speed", 1.4)
	plant.attack_range = data.get("attack_range", 15)
	
	plant.generate_amount = data.get("generate_amount", 25)
	plant.explosion_radius = data.get("explosion_radius", 2.5)
	plant.slow_amount = data.get("slow_amount", 0.5)
	plant.slow_duration = data.get("slow_duration", 3.0)
	
	# Parse color từ hex string (#2E8B57)
	var color_str = data.get("color", "#2E8B57")
	if color_str.begins_with("#"):
		plant.color = Color(color_str)
	else:
		plant.color = Color("#2E8B57")
	
	plant.sprite_path = data.get("sprite_path", "")
	plant.scene_path = data.get("scene_path", "")
	
	plant.era = data.get("era", "")
	
	# Parse tags
	var tags_arr = data.get("tags", [])
	for tag in tags_arr:
		plant.tags.append(str(tag))
	
	# Lưu plant_food_skill (Dictionary gốc)
	plant.plant_food_skill = data.get("plant_food_skill", {})
	
	return plant

# ============================================================
# HELPER — In debug
# ============================================================
func _to_string() -> String:
	return "PlantData(%s — %s, cost=%d, hp=%d)" % [name, title, cost, hp]