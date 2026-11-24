extends Node

signal finished

var lifetime := 1.0

func play_effect(parent: Node, world_position: Vector2, color: Color = Color.WHITE) -> void:
	var effect := Node2D.new()
	effect.position = world_position
	parent.add_child(effect)

	var circle := Polygon2D.new()
	circle.polygon = PackedVector2Array([
		Vector2(-18, 0), Vector2(-12, -12), Vector2(0, -18),
		Vector2(12, -12), Vector2(18, 0), Vector2(12, 12),
		Vector2(0, 18), Vector2(-12, 12)
	])
	circle.color = color
	effect.add_child(circle)

	var tween := effect.create_tween()
	tween.tween_property(effect, "scale", Vector2(2.0, 2.0), lifetime)
	tween.parallel().tween_property(effect, "modulate:a", 0.0, lifetime)
	tween.finished.connect(func():
		effect.queue_free()
		finished.emit()
	)
