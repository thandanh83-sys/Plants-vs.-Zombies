# ============================================================
# VĂN ĐẠO: BÚT TRẬN — Enemy.gd
# Vị trí: scripts/entities/Enemy.gd
# Vai trò: Quái Vô Tri — đi sang trái, ăn cây, chết khi hết máu
# ============================================================

extends Node2D
class_name Enemy

# ============================================================
# SIGNALS
# ============================================================
signal died(enemy: Enemy)

# ============================================================
# BIẾN
# ============================================================
var data: Dictionary = {}
var current_hp: int = 100
var max_hp: int = 100
var speed: float = 35.0
var damage: int = 20
var attack_interval: float = 1.0
var lane: int = 0

var _attack_timer: float = 0.0
var _is_dead: bool = false
var _grid_manager: Node = null

# ============================================================
# SETUP — Gọi sau khi instantiate
# ============================================================
func setup(enemy_data: Dictionary, target_lane: int) -> void:
	data = enemy_data
	max_hp = data.get("hp", 100)
	current_hp = max_hp
	speed = data.get("speed", 35.0)
	damage = data.get("damage", 20)
	attack_interval = data.get("attack_interval", 1.0)
	lane = target_lane

# ============================================================
# _ready()
# ============================================================
func _ready() -> void:
	# Add vào group để cây tìm thấy
	add_to_group("enemies")
	
	# z_index cao hơn cây
	z_index = 5
	
	# Tìm GridManager
	_grid_manager = get_tree().get_first_node_in_group("grid_manager")

# ============================================================
# _process() — Di chuyển hoặc ăn cây
# ============================================================
func _process(delta: float) -> void:
	if _is_dead:
		return
	
	# Kiểm tra ô hiện tại có cây không
	var tile = _get_current_tile()
	
	if tile != null and tile.is_occupied:
		# Có cây → ăn
		_eat_plant(tile, delta)
	else:
		# Không có cây → đi tiếp
		_move(delta)

# ============================================================
# DI CHUYỂN
# ============================================================
func _move(delta: float) -> void:
	position.x -= speed * delta
	
	# Chạm mép trái → thua
	if position.x < 150:
		GameManager.on_level_lost()

# ============================================================
# ĂN CÂY
# ============================================================
func _eat_plant(tile: Tile, delta: float) -> void:
	_attack_timer += delta
	
	if _attack_timer >= attack_interval:
		_attack_timer = 0.0
		
		if tile.current_plant != null and is_instance_valid(tile.current_plant):
			if tile.current_plant.has_method("take_damage"):
				tile.current_plant.take_damage(damage)

# ============================================================
# LẤY TILE HIỆN TẠI
# ============================================================
func _get_current_tile() -> Tile:
	if _grid_manager == null:
		return null
	
	var gp = Const.world_to_grid(global_position)
	return _grid_manager.get_tile(gp)

# ============================================================
# NHẬN SÁT THƯƠNG
# ============================================================
func take_damage(amount: int) -> void:
	if _is_dead:
		return
	
	current_hp -= amount
	
	if current_hp <= 0:
		_die()

# ============================================================
# CHẾT
# ============================================================
func _die() -> void:
	_is_dead = true
	
	if AudioManager:
		AudioManager.play_hit()
	
	died.emit(self)
	queue_free()

# ============================================================
# API CHO CÂY
# ============================================================
func get_grid_pos() -> Vector2i:
	return Const.world_to_grid(global_position)

# Hỗ trợ cho SupportPlant
func apply_slow(_amount: float, _duration: float) -> void:
	# Tạm để trống. Đợt sau sẽ thêm StatusEffect.
	pass

func apply_stun(_duration: float) -> void:
	# Tạm để trống.
	pass