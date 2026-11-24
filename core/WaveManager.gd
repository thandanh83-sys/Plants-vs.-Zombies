class_name WaveManager
extends Node

signal wave_started(wave_number: int)
signal zombie_spawned(zombie_id: String, lane: int)
signal all_waves_finished

var factory: EntityFactory
var level_data: Dictionary = {}
var running := false
var _run_token := 0

func setup(entity_factory: EntityFactory, data: Dictionary) -> void:
	factory = entity_factory
	level_data = data.duplicate(true)

func start() -> void:
	if running:
		return
	if not is_instance_valid(factory):
		push_error("WaveManager needs a valid EntityFactory")
		return
	running = true
	_run_token += 1
	_run_waves(_run_token)

func stop() -> void:
	running = false
	_run_token += 1

func _run_waves(token: int) -> void:
	var waves: Array = level_data.get("waves", [])
	var row_count := maxi(1, int(DataLoader.get_setting("grid_rows", 5)))
	for wave_index in range(waves.size()):
		if not _is_run_active(token):
			return
		var wave: Dictionary = waves[wave_index]
		var wave_number := int(wave.get("wave_number", wave_index + 1))
		wave_started.emit(wave_number)
		var zombie_ids: Array = wave.get("zombies", [])
		var count := maxi(0, int(wave.get("count", 1)))
		var interval := maxf(0.1, float(wave.get("interval", 2.5)))
		for spawn_index in range(count):
			if not _is_run_active(token):
				return
			if zombie_ids.is_empty():
				push_error("Wave %d has no zombie IDs" % wave_number)
				break
			var lane := spawn_index % row_count
			if wave.has("lanes") and wave["lanes"] is Array and not wave["lanes"].is_empty():
				lane = int(wave["lanes"][spawn_index % wave["lanes"].size()])
			lane = clampi(lane, 0, row_count - 1)
			var zombie_id := str(zombie_ids[spawn_index % zombie_ids.size()])
			if factory.spawn_zombie(zombie_id, lane) != null:
				zombie_spawned.emit(zombie_id, lane)
			if spawn_index + 1 < count:
				await get_tree().create_timer(interval).timeout
		var rest := maxf(float(wave.get("rest_after", interval)), 0.0)
		if rest > 0.0:
			await get_tree().create_timer(rest).timeout
	if _is_run_active(token):
		running = false
		all_waves_finished.emit()

func _is_run_active(token: int) -> bool:
	return running and token == _run_token and GameManager.state == "playing"
