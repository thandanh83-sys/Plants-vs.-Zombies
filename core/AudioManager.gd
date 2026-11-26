extends Node

const MIX_RATE := 22050
const MUSIC_CROSSFADE_SECONDS := 1.5
const SILENT_VOLUME_DB := -60.0
const NORMAL_MUSIC_PATH := "res://assets/audio/music-normal.ogg"
const HORDE_MUSIC_PATH := "res://assets/audio/music-horde.ogg"

const SOUND_PROFILES := {
	"plant": [520.0, 760.0, 0.14, 0.20],
	"collect": [760.0, 1120.0, 0.12, 0.18],
	"explosion": [150.0, 55.0, 0.24, 0.34],
	"hit": [210.0, 120.0, 0.08, 0.12],
	"win": [520.0, 1040.0, 0.30, 0.18],
	"lose": [300.0, 90.0, 0.35, 0.18]
}

var _normal_music: AudioStreamPlayer
var _horde_music: AudioStreamPlayer
var _music_tween: Tween
var _collect_combo_count := 0
var _last_collect_msec := -1200

func _ready() -> void:
	_normal_music = _create_music_player("NormalMusic", NORMAL_MUSIC_PATH)
	_horde_music = _create_music_player("HordeMusic", HORDE_MUSIC_PATH)
	if _normal_music.stream != null:
		_normal_music.volume_db = 0.0
		_normal_music.play()
	if _horde_music.stream != null:
		_horde_music.volume_db = SILENT_VOLUME_DB
		_horde_music.play()

func _create_music_player(player_name: String, path: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.volume_db = SILENT_VOLUME_DB
	add_child(player)
	if ResourceLoader.exists(path):
		var stream := load(path) as AudioStream
		if stream is AudioStreamOggVorbis:
			(stream as AudioStreamOggVorbis).loop = true
		player.stream = stream
	return player

func set_horde_intensity(active: bool) -> void:
	if not is_instance_valid(_normal_music) or not is_instance_valid(_horde_music):
		return
	if _normal_music.stream == null and _horde_music.stream == null:
		return
	if _music_tween != null and _music_tween.is_running():
		_music_tween.kill()
	if active and _horde_music.stream != null and not _horde_music.playing:
		_horde_music.play()
	if not active and _normal_music.stream != null and not _normal_music.playing:
		_normal_music.play()
	_music_tween = create_tween()
	_music_tween.set_parallel(true)
	var normal_target := SILENT_VOLUME_DB if active else 0.0
	var horde_target := 0.0 if active else SILENT_VOLUME_DB
	if _normal_music.stream != null:
		_music_tween.tween_property(_normal_music, "volume_db", normal_target, MUSIC_CROSSFADE_SECONDS)
	if _horde_music.stream != null:
		_music_tween.tween_property(_horde_music, "volume_db", horde_target, MUSIC_CROSSFADE_SECONDS)

func play(sound_id: String) -> void:
	var stream_path := "res://assets/audio/" + sound_id + ".ogg"
	var stream: AudioStream
	if ResourceLoader.exists(stream_path):
		stream = load(stream_path) as AudioStream
	else:
		stream = _make_tone(sound_id)
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.pitch_scale = _get_sfx_pitch(sound_id)
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func _get_sfx_pitch(sound_id: String) -> float:
	if sound_id == "collect":
		var now := Time.get_ticks_msec()
		if now - _last_collect_msec <= 1200:
			_collect_combo_count = mini(_collect_combo_count + 1, 8)
		else:
			_collect_combo_count = 0
		_last_collect_msec = now
		return 1.0 + float(_collect_combo_count) * 0.035
	if sound_id == "plant":
		return randf_range(0.96, 1.04)
	return 1.0

func _make_tone(sound_id: String) -> AudioStreamWAV:
	if not SOUND_PROFILES.has(sound_id):
		return null
	var profile: Array = SOUND_PROFILES[sound_id]
	var start_frequency := float(profile[0])
	var end_frequency := float(profile[1])
	var duration := float(profile[2])
	var volume := float(profile[3])
	var sample_count := maxi(1, int(MIX_RATE * duration))
	var samples := PackedByteArray()
	samples.resize(sample_count * 2)
	for i in range(sample_count):
		var progress := float(i) / float(sample_count)
		var frequency := lerpf(start_frequency, end_frequency, progress)
		var envelope := minf(1.0, progress * 18.0) * pow(1.0 - progress, 1.7)
		var sample := sin(TAU * frequency * float(i) / float(MIX_RATE)) * envelope * volume
		samples.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))
	var result := AudioStreamWAV.new()
	result.data = samples
	result.format = AudioStreamWAV.FORMAT_16_BITS
	result.mix_rate = MIX_RATE
	result.stereo = false
	return result
