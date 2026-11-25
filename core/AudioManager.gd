extends Node

const MIX_RATE := 22050
const SOUND_PROFILES := {
	"plant": [520.0, 760.0, 0.14, 0.20],
	"collect": [760.0, 1120.0, 0.12, 0.18],
	"explosion": [150.0, 55.0, 0.24, 0.34],
	"hit": [210.0, 120.0, 0.08, 0.12],
	"win": [520.0, 1040.0, 0.30, 0.18],
	"lose": [300.0, 90.0, 0.35, 0.18]
}

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
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

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
