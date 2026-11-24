extends Node

func play(sound_id: String) -> void:
	var stream_path := "res://assets/audio/" + sound_id + ".ogg"
	if not ResourceLoader.exists(stream_path):
		return
	var player := AudioStreamPlayer.new()
	player.stream = load(stream_path) as AudioStream
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
