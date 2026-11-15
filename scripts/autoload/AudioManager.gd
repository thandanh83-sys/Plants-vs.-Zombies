# ============================================================
# VĂN ĐẠO: BÚT TRẬN — AudioManager.gd
# Vị trí: scripts/autoload/AudioManager.gd
# Vai trò: Autoload Singleton — Quản lý âm thanh
# Mục đích: Play BGM và SFX mà không cần quan tâm đến source
# ============================================================
# TRIẾT LÝ:
# - AudioManager là "cổng giao tiếp" duy nhất cho âm thanh.
# - Không scene nào tự tạo AudioStreamPlayer riêng lẻ.
# - Khi BGM đổi → fade cũ → play mới (không chồng chéo).
# ============================================================
# GHI CHÚ:
# - File này dùng PLACEHOLDER cho âm thanh (chưa có file .ogg thật).
# - Nếu play BGM/SFX mà file không tồn tại → bỏ qua êm đẹp, không crash.
# - Khi có file thật → chỉ cần bỏ vào assets/audio/ và đổi path.
# ============================================================

extends Node

# ============================================================
# CHILDREN NODES — Tự tạo trong _ready()
# ============================================================
# Chúng ta tạo 2 AudioStreamPlayer:
#   - bgm_player: 1 cái duy nhất (chỉ 1 nhạc nền)
#   - sfx_player: 1 cái để play hiệu ứng (có thể chồng chéo nhẹ)
# ============================================================

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# ============================================================
# TRẠNG THÁI
# ============================================================

# Đường dẫn BGM hiện tại (để tránh play lại nếu cùng bài)
var current_bgm_path: String = ""

# Volume (0.0 → 1.0)
var master_volume: float = 0.8
var bgm_volume: float = 0.5
var sfx_volume: float = 0.8

# ============================================================
# _ready() — Khởi tạo AudioStreamPlayer
# ============================================================
func _ready() -> void:
	# Tạo BGM player
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGMPlayer"
	bgm_player.volume_db = linear_to_db(bgm_volume * master_volume)
	add_child(bgm_player)
	
	# Tạo SFX player
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.volume_db = linear_to_db(sfx_volume * master_volume)
	add_child(sfx_player)
	
	print("[AudioManager] Đã khởi tạo. BGM + SFX sẵn sàng.")
	print("[AudioManager] Lưu ý: Chưa có file âm thanh. Sẽ dùng placeholder.")

# ============================================================
# PUBLIC API — Phát BGM (Background Music)
# ============================================================

# ------------------------------------------------------------
# Phát nhạc nền. Nếu đang phát bài khác → fade rồi đổi.
# ------------------------------------------------------------
# @param path: Đường dẫn file .ogg (VD: "res://assets/audio/bgm/calm.ogg")
# @param fade_duration: Thời gian fade (giây). 0 = chuyển ngay.
# ------------------------------------------------------------
func play_bgm(path: String, fade_duration: float = 1.5) -> void:
	# Nếu cùng bài đang phát → không làm gì
	if path == current_bgm_path and bgm_player.playing:
		return
	
	# Kiểm tra file tồn tại
	if not ResourceLoader.exists(path):
		# Placeholder: File chưa có → bỏ qua êm đẹp
		push_warning("[AudioManager] BGM chưa có: %s (sẽ thêm sau)" % path)
		current_bgm_path = path
		return
	
	# Load audio stream
	var stream = load(path)
	if not stream is AudioStream:
		push_warning("[AudioManager] File không phải AudioStream: " + path)
		return
	
	# Fade out bài cũ (nếu đang phát)
	if bgm_player.playing and fade_duration > 0:
		var tween = create_tween()
		tween.tween_property(bgm_player, "volume_db", -80.0, fade_duration)
		await tween.finished
	
	# Đổi bài và play
	bgm_player.stream = stream
	bgm_player.volume_db = linear_to_db(bgm_volume * master_volume)
	bgm_player.play()
	current_bgm_path = path
	
	print("[AudioManager] Đang phát BGM: %s" % path)

# ------------------------------------------------------------
# Dừng BGM (có fade)
# ------------------------------------------------------------
func stop_bgm(fade_duration: float = 1.0) -> void:
	if not bgm_player.playing:
		return
	
	if fade_duration > 0:
		var tween = create_tween()
		tween.tween_property(bgm_player, "volume_db", -80.0, fade_duration)
		await tween.finished
	
	bgm_player.stop()
	current_bgm_path = ""

# ------------------------------------------------------------
# Tạm dừng BGM
# ------------------------------------------------------------
func pause_bgm() -> void:
	if bgm_player.playing:
		bgm_player.stream_paused = true

func resume_bgm() -> void:
	if bgm_player.stream_paused:
		bgm_player.stream_paused = false

# ============================================================
# PUBLIC API — Phát SFX (Sound Effects)
# ============================================================

# ------------------------------------------------------------
# Phát hiệu ứng âm thanh ngắn (1 lần).
# ------------------------------------------------------------
# @param path: Đường dẫn file .wav hoặc .ogg
# @param volume_scale: Hệ số volume (0.5 = nửa, 1.0 = bình thường)
# @param pitch_variation: Biến thiên pitch ngẫu nhiên (tránh nhàm chán)
# ------------------------------------------------------------
func play_sfx(path: String, volume_scale: float = 1.0, pitch_variation: float = 0.05) -> void:
	# Kiểm tra file tồn tại
	if not ResourceLoader.exists(path):
		# Placeholder: File chưa có → bỏ qua
		return
	
	var stream = load(path)
	if not stream is AudioStream:
		return
	
	# Random pitch nhẹ (0.95 → 1.05) để nghe tự nhiên hơn
	var pitch = 1.0
	if pitch_variation > 0.0:
		pitch = 1.0 + randf_range(-pitch_variation, pitch_variation)
	
	# Cấu hình SFX player và play
	sfx_player.stream = stream
	sfx_player.volume_db = linear_to_db(sfx_volume * master_volume * volume_scale)
	sfx_player.pitch_scale = pitch
	sfx_player.play()

# ------------------------------------------------------------
# Các hàm shortcut cho SFX phổ biến
# ------------------------------------------------------------
# Gọi: AudioManager.play_shoot() thay vì play_sfx("res://.../shoot.ogg")

func play_shoot() -> void:
	play_sfx("res://assets/audio/sfx/shoot.ogg", 0.6)

func play_hit() -> void:
	play_sfx("res://assets/audio/sfx/hit.ogg", 0.7)

func play_explosion() -> void:
	play_sfx("res://assets/audio/sfx/explosion.ogg", 1.0)

func play_plant() -> void:
	play_sfx("res://assets/audio/sfx/plant.ogg", 0.8)

func play_sun_pickup() -> void:
	play_sfx("res://assets/audio/sfx/sun_pickup.ogg", 0.7)

func play_click() -> void:
	play_sfx("res://assets/audio/sfx/click.ogg", 0.5)

func play_win() -> void:
	play_sfx("res://assets/audio/sfx/win.ogg", 1.0, 0.0)  # Không random pitch

func play_lose() -> void:
	play_sfx("res://assets/audio/sfx/lose.ogg", 1.0, 0.0)

# ============================================================
# QUẢN LÝ VOLUME
# ============================================================

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_update_volumes()

func set_bgm_volume(value: float) -> void:
	bgm_volume = clampf(value, 0.0, 1.0)
	_update_volumes()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_update_volumes()

func _update_volumes() -> void:
	if bgm_player:
		bgm_player.volume_db = linear_to_db(bgm_volume * master_volume)
	if sfx_player:
		sfx_player.volume_db = linear_to_db(sfx_volume * master_volume)

# ============================================================
# DEBUG
# ============================================================

func debug_print() -> void:
	print("")
	print("─".repeat(40))
	print("[AudioManager] Trạng thái:")
	print("  • BGM hiện tại: %s" % (
		current_bgm_path if current_bgm_path != "" else "Không có"
	))
	print("  • BGM đang phát: %s" % bgm_player.playing)
	print("  • Master vol: %.0f%%" % (master_volume * 100))
	print("  • BGM vol: %.0f%%" % (bgm_volume * 100))
	print("  • SFX vol: %.0f%%" % (sfx_volume * 100))
	print("─".repeat(40))
	print("")
