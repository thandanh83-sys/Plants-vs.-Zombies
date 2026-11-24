class_name WaveManager
extends Node

signal wave_started(wave_number: int)
signal all_waves_finished

var factory: EntityFactory
var level_data: Dictionary = {}
var running := false

func setup(entity_factory: EntityFactory, data: Dictionary) -> void:
	factory = entity_factory
	level_data = data

func start() -> void:
	if running:
		return
	running = true
	_run_waves()

func _run_waves() -> void:
	var waves: Array = level_data.get("waves", [])
	for wave_index in range(waves.size()):
		var wave: Dictionary = waves[wave_index]
		wave_started.emit(int(wave.get("wave_number", wave_index + 1)))
		var zombie_ids: Array = wave.get("zombies", [])
		var count := int(wave.get("count", 1))
		var interval := float(wave.get("interval", 2.5))
		for i in range(count):
			if zombie_ids.is_empty():
				break
			var lane := i % 5
			var zombie_id := str(zombie_ids[i % zombie_ids.size()])
			if factory:
				factory.spawn_zombie(zombie_id, lane)
			await get_tree().create_timer(interval).timeout
		await get_tree().create_timer(max(3.0, interval)).timeout
	all_waves_finished.emit()
	running = false
